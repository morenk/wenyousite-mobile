import { pathToFileURL } from 'node:url';

// 只输出已验证的 revision；错误不回显远程原始输出或任何环境值。
export function parseReleaseNotesPreflight(input, versionName, buildNumber) {
  let value;
  try { value = JSON.parse(input); } catch {
    throw new Error('更新说明预检未返回有效 JSON。');
  }
  if (!value || Array.isArray(value) || value.schemaVersion !== 1 ||
      value.platform !== 'android' || value.versionName !== versionName ||
      value.buildNumber !== buildNumber || !Number.isSafeInteger(buildNumber) ||
      buildNumber < 1 || buildNumber > 2100000000 ||
      !Number.isSafeInteger(value.confirmedRevision) ||
      value.confirmedRevision < 1 || value.confirmedRevision > 2147483646) {
    throw new Error('更新说明预检身份或确认 revision 不匹配，停止发布。');
  }
  return value.confirmedRevision;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    const [versionName, build] = process.argv.slice(2);
    const chunks = [];
    let size = 0;
    for await (const chunk of process.stdin) {
      size += chunk.length;
      if (size > 16384) throw new Error('更新说明预检输出过大，停止发布。');
      chunks.push(chunk);
    }
    process.stdout.write(String(parseReleaseNotesPreflight(
      Buffer.concat(chunks).toString('utf8'), versionName, Number(build),
    )));
  } catch (error) {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  }
}
