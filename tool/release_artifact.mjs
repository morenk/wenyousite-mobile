import { pathToFileURL } from 'node:url';

export const LEGACY_APK_ORIGIN = 'https://wenyou-apk.cn-nb1.rains3.com';

// 与 Backend manifest v1 同名字段；publicUrl 独立于不可改写的源对象/历史身份。
export function createReleaseArtifact({ versionName, buildNumber, sizeBytes, sha256 }) {
  if (typeof versionName !== 'string' || !/^[0-9A-Za-z][0-9A-Za-z._-]{0,63}$/.test(versionName) ||
      !Number.isSafeInteger(buildNumber) || buildNumber < 1 || buildNumber > 2100000000 ||
      !Number.isSafeInteger(sizeBytes) || sizeBytes < 1 || sizeBytes > 250 * 1024 * 1024 ||
      typeof sha256 !== 'string' || !/^[0-9a-f]{64}$/.test(sha256)) {
    throw new Error('发布制品版本、构建、大小或摘要无效。');
  }
  const key = `mobile/android/wenyou-${versionName}-${buildNumber}.apk`;
  return {
    schemaVersion: 1,
    applicationId: 'site.wenyou.app',
    versionName, buildNumber, sizeBytes, sha256,
    bucket: 'wenyou-apk', key,
    legacyUpdateUrl: `${LEGACY_APK_ORIGIN}/${key}`,
    publicUrl: `https://wenyou.site/api/v1/app-downloads/android/${buildNumber}/file`,
  };
}

export function parseReleaseArtifact(input, versionName, buildNumber) {
  let value;
  try { value = JSON.parse(input); }
  catch { throw new Error('上传工具未返回有效制品 JSON，停止晋级。'); }
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    throw new Error('上传工具缺少制品身份，停止晋级。');
  }
  const expected = createReleaseArtifact({ versionName, buildNumber,
    sizeBytes: value.sizeBytes, sha256: value.sha256 });
  for (const [key, required] of Object.entries(expected)) {
    if (value[key] !== required) throw new Error('上传制品身份或下载地址不匹配，停止晋级。');
  }
  // 只返回已核验字段；不输出未知字段或远端原文。
  return expected;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    const [versionName, build] = process.argv.slice(2);
    const chunks = [];
    let size = 0;
    for await (const chunk of process.stdin) {
      size += chunk.length;
      if (size > 16384) throw new Error('上传制品 JSON 过大，停止晋级。');
      chunks.push(chunk);
    }
    const artifact = parseReleaseArtifact(Buffer.concat(chunks).toString('utf8'), versionName, Number(build));
    process.stdout.write([artifact.legacyUpdateUrl, artifact.publicUrl, artifact.sizeBytes, artifact.sha256].join('\t'));
  } catch (error) {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  }
}
