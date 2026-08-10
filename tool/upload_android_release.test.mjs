import assert from 'node:assert/strict';
import test from 'node:test';
import {
  assertPublicApkHeaders,
  parseArguments,
  parseSha256Sidecar,
  releaseConfig,
  releaseObjectPlan,
} from './upload_android_release.mjs';

const digest = 'a'.repeat(64);

test('RainS3 默认使用独立发布桶与固定下载域名', () => {
  const config = releaseConfig({
    WENYOU_RELEASE_S3_ACCESS_KEY_ID: 'test-access-key',
    WENYOU_RELEASE_S3_SECRET_ACCESS_KEY: 'test-secret-key',
  });
  assert.equal(config.endpoint, 'https://cn-nb1.rains3.com');
  assert.equal(config.bucket, 'wenyou-apk');
  assert.equal(config.prefix, 'mobile/android');
  assert.equal(config.publicBaseUrl, 'https://wenyou-apk.cn-nb1.rains3.com');
});

test('解析发布参数并拒绝非法构建号', () => {
  assert.equal(
    parseArguments([
      '--apk', 'wenyou-1.0.0-42.apk',
      '--sha256-file', 'wenyou-1.0.0-42.apk.sha256',
      '--manifest', 'wenyou-1.0.0-42.json',
      '--version', '1.0.0',
      '--build', '42',
    ]).build,
    '42',
  );
  assert.throws(() => parseArguments(['--build', '0']), /缺少|构建号/);
});

test('sidecar 必须同时匹配摘要与文件名', () => {
  assert.equal(parseSha256Sidecar(`${digest}  wenyou-1.0.0-42.apk\n`, 'wenyou-1.0.0-42.apk'), digest);
  assert.throws(() => parseSha256Sidecar(`${digest}  other.apk`, 'wenyou.apk'), /不匹配/);
});

test('发布对象名称与构建摘要必须一致', () => {
  const plan = releaseObjectPlan({
    version: '1.0.0',
    build: '42',
    apkPath: '/tmp/wenyou-1.0.0-42.apk',
    shaPath: '/tmp/wenyou-1.0.0-42.apk.sha256',
    manifestPath: '/tmp/wenyou-1.0.0-42.json',
    manifest: {
      applicationId: 'site.wenyou.app',
      versionName: '1.0.0',
      versionCode: 42,
      apkFile: 'wenyou-1.0.0-42.apk',
    },
  });
  assert.deepEqual(plan.map((item) => item.fileName), [
    'wenyou-1.0.0-42.apk.sha256',
    'wenyou-1.0.0-42.json',
    'wenyou-1.0.0-42.apk',
  ]);
});

test('公网 APK 必须带不可变缓存与发布 metadata', () => {
  const headers = new Headers({
    'content-type': 'application/vnd.android.package-archive',
    'content-length': '90900000',
    'cache-control': 'public, max-age=31536000, immutable',
    'content-disposition': 'attachment; filename="wenyou-1.0.0-42.apk"',
    'x-amz-meta-apk-sha256': digest,
    'x-amz-meta-application-id': 'site.wenyou.app',
    'x-amz-meta-version-name': '1.0.0',
    'x-amz-meta-version-code': '42',
  });
  assert.doesNotThrow(() =>
    assertPublicApkHeaders(headers, {
      size: 90_900_000,
      sha256: digest,
      fileName: 'wenyou-1.0.0-42.apk',
      version: '1.0.0',
      build: 42,
    }),
  );
  headers.set('content-length', '1');
  assert.throws(() =>
    assertPublicApkHeaders(headers, {
      size: 90_900_000,
      sha256: digest,
      fileName: 'wenyou-1.0.0-42.apk',
      version: '1.0.0',
      build: 42,
    }),
  );
});
