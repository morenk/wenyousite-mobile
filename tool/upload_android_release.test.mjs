import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { createServer } from 'node:http';
import { S3Client } from '@aws-sdk/client-s3';
import test from 'node:test';
import {
  assertPublicApkHeaders,
  parseArguments,
  parseSha256Sidecar,
  releaseConfig,
  releaseObjectPlan,
  ensureUploaded,
  verifyPrivateArtifacts,
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

test('凭据只能用于 APK 目录，拒绝图片桶与携带凭据的 URL', () => {
  const env = { WENYOU_RELEASE_S3_ACCESS_KEY_ID: 'fixture-key',
    WENYOU_RELEASE_S3_SECRET_ACCESS_KEY: 'fixture-secret' };
  for (const invalid of [{ WENYOU_RELEASE_S3_BUCKET: 'images' },
    { WENYOU_RELEASE_S3_PREFIX: 'mobile/android/../images' },
    { WENYOU_RELEASE_S3_ENDPOINT: 'https://user:password@example.invalid' },
    { WENYOU_RELEASE_PUBLIC_BASE_URL: 'https://example.invalid?token=secret' }]) {
    assert.throws(() => releaseConfig({ ...env, ...invalid }));
  }
});

test('SDK 故障日志不回显签名请求或凭据', async () => {
  const client = { send: async () => { throw Object.assign(new Error('fixture-secret Authorization=private'),
    { $metadata: { httpStatusCode: 403 } }); } };
  await assert.rejects(verifyPrivateArtifacts(client, { bucket: 'wenyou-apk' }, [{ key: 'mobile/android/fixture' }]),
    (error) => error.message === '鉴权对象存储请求失败 (HTTP 403)');
});

// 只绑定本机随机端口，使用虚构凭据；不读取发布配置，不调用真实对象存储。
async function privateStore(run, mutate = () => {}) {
  const requests = [];
  const buffers = [Buffer.from(`${digest}  wenyou-1.0.0-42.apk\n`),
    Buffer.from(JSON.stringify({ apkSha256: digest })), Buffer.from('fixture-apk')];
  const names = ['wenyou-1.0.0-42.apk.sha256', 'wenyou-1.0.0-42.json', 'wenyou-1.0.0-42.apk'];
  const artifacts = buffers.map((body, index) => {
    const artifactSha256 = createHash('sha256').update(body).digest('hex');
    return {
      key: `mobile/android/${names[index]}`, fileName: names[index], size: body.length,
      artifactSha256, apkSha256: digest, attachment: index === 2,
      contentType: ['text/plain; charset=utf-8', 'application/json; charset=utf-8',
        'application/vnd.android.package-archive'][index],
      metadata: { 'artifact-sha256': artifactSha256, 'apk-sha256': digest,
        'application-id': 'site.wenyou.app', 'version-code': '42', 'version-name': '1.0.0',
        'certificate-sha256': 'b'.repeat(64), 'source-commit': 'c'.repeat(40) },
    };
  });
  const server = createServer((request, response) => {
    requests.push({ method: request.method, url: request.url, headers: request.headers });
    if (!request.headers.authorization?.startsWith('AWS4-HMAC-SHA256 Credential=fixture-key/')) {
      response.writeHead(403).end();
      return;
    }
    const index = artifacts.findIndex((item) => request.url.split('?')[0] === `/wenyou-apk/${item.key}`);
    if (index < 0) { response.writeHead(404).end(); return; }
    const artifact = artifacts[index];
    const headers = {
      'Content-Type': artifact.contentType, 'Content-Length': String(artifact.size),
      'Cache-Control': 'public, max-age=31536000, immutable', ETag: '"fixture-etag"',
      ...(artifact.attachment ? { 'Content-Disposition': `attachment; filename="${artifact.fileName}"` } : {}),
      ...Object.fromEntries(Object.entries(artifact.metadata).map(([key, value]) => [`x-amz-meta-${key}`, value])),
    };
    const result = { status: 200, headers, body: buffers[index] };
    mutate(result, request, artifact);
    response.writeHead(result.status, result.headers);
    response.end(request.method === 'HEAD' ? undefined : result.body);
  });
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const client = new S3Client({ endpoint: `http://127.0.0.1:${server.address().port}`,
    region: 'auto', forcePathStyle: true, maxAttempts: 1,
    credentials: { accessKeyId: 'fixture-key', secretAccessKey: 'fixture-secret' } });
  try { await run(client, { bucket: 'wenyou-apk' }, artifacts, requests); }
  finally { client.destroy(); await new Promise((resolve) => server.close(resolve)); }
}

test('私有桶用签名 HEAD 与附件 GET 验证，不发公开请求或重复下载 APK', async () => {
  await privateStore(async (client, config, artifacts, requests) => {
    await verifyPrivateArtifacts(client, config, artifacts);
    assert.deepEqual(requests.map((r) => r.method), ['HEAD', 'GET', 'HEAD', 'GET', 'HEAD']);
    assert.ok(requests.every((r) => !r.url.includes('X-Amz-Credential')));
    assert.ok(requests.filter((r) => r.method === 'GET').every((r) => r.headers['if-match'] === '"fixture-etag"'));
  });
});

test('旧制品同名同摘要保留且不覆盖', async () => {
  await privateStore(async (client, config, artifacts, requests) => {
    await ensureUploaded(client, config, artifacts[2]);
    assert.deepEqual(requests.map((r) => r.method), ['HEAD']);
  });
});

for (const metadata of ['application-id', 'version-code', 'version-name', 'certificate-sha256', 'artifact-sha256', 'apk-sha256']) {
  test(`已存对象 ${metadata} 不符时停止，不覆盖或降级到公开读取`, async () => {
    await privateStore(async (client, config, artifacts, requests) => {
      await assert.rejects(ensureUploaded(client, config, artifacts[2]), /不一致/);
      assert.deepEqual(requests.map((r) => r.method), ['HEAD']);
    }, (result) => { result.headers[`x-amz-meta-${metadata}`] = 'wrong'; });
  });
}

test('附件 GET 同长度内容被更换也必须拒绝', async () => {
  await privateStore(async (client, config, artifacts) => {
    await assert.rejects(verifyPrivateArtifacts(client, config, artifacts), /正文摘要或大小不一致/);
  }, (result, request) => {
    if (request.method === 'GET') result.body = Buffer.alloc(result.body.length, 'x');
  });
});

for (const status of [403, 404, 503]) {
  test(`鉴权读取 ${status} 时失败且不回退公开桶`, async () => {
    await privateStore(async (client, config, artifacts, requests) => {
      await assert.rejects(verifyPrivateArtifacts(client, config, artifacts));
      assert.equal(requests.length, 1);
    }, (result) => { result.status = status; result.headers = {}; result.body = Buffer.alloc(0); });
  });
}

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
