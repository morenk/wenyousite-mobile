import { readJson, portOpen, jobSpawn, sleep, run, processIdentity } from './runtime.mjs';

export const CONTRACT_SHA = '5d02f6cf0d927f83f122c71ffcf53dc7c15bcc1b';
const forbiddenPorts = new Set([3000, 3001, 5432, 6379]);
export function validateDescriptor(value) {
  if (!value || value.version !== 1 || value.kind !== 'wenyou-dev-preview' || value.state !== 'ready'
    || !/^[a-z][a-z0-9-]{2,47}$/.test(value.sessionId) || !/^preview_[a-f0-9]{24}$/.test(value.runId)
    || !/^[a-f0-9]{64}$/.test(value.snapshot?.sha256) || !Number.isFinite(Date.parse(value.snapshot?.capturedAt))
    || !/^\d{4}-\d{2}-\d{2}$/.test(value.snapshot?.businessDate) || !/^[a-f0-9]{40}$/.test(value.snapshot?.sourceSha)
    || typeof value.snapshot?.migrationVersion !== 'string' || !/^[a-f0-9]{40}$/.test(value.source?.backendSha)
    || typeof value.source?.worktree !== 'string' || !Number.isInteger(value.ownership?.uid) || value.ownership.uid < 1
    || value.ownership?.resourceId !== value.runId || value.identity?.header !== 'X-Wenyou-Preview-Run' || value.identity.value !== value.runId) {
    throw new Error('开发预览描述缺失或不符合已固定的 Backend 协议；禁止回退线上。');
  }
  const ports = new Set();
  for (const role of ['backend', 'media', 'web']) {
    const item = value[role];
    if (!item || !Number.isInteger(item.port) || item.port < 1024 || item.port > 65535 || forbiddenPorts.has(item.port)
      || ports.has(item.port) || item.origin !== `http://127.0.0.1:${item.port}`
      || (role !== 'web' && item.identityUrl !== `${item.origin}/__preview/identity`)
      || (role === 'backend' && item.apiBase !== `${item.origin}/api/v1`)) throw new Error('开发预览端口或服务地址无效。');
    ports.add(item.port);
  }
  return value;
}
export function loadDescriptor(file) {
  let value;
  try { value = readJson(file); } catch { throw new Error('无法读取 consumer.json；拒绝输出私有文件内容。'); }
  return validateDescriptor(value);
}
export async function verifyIdentity(descriptor, fetcher = fetch) {
  validateDescriptor(descriptor);
  for (const role of ['backend', 'media']) {
    const response = await fetcher(descriptor[role].identityUrl, { redirect: 'manual', signal: AbortSignal.timeout(8000) });
    if (response.status !== 200 || !response.headers.get('content-type')?.startsWith('application/json') || response.headers.get('X-Wenyou-Preview-Run') !== descriptor.runId) throw new Error(`${role} 身份核验失败。`);
    const body = await response.json();
    const expected = { version: 1, kind: 'wenyou-dev-preview', sessionId: descriptor.sessionId, runId: descriptor.runId, role, resourceId: descriptor.runId, snapshotSha256: descriptor.snapshot.sha256 };
    if (Object.keys(body).length !== Object.keys(expected).length || Object.entries(expected).some(([key, value]) => body[key] !== value)) throw new Error(`${role} 实际资源身份与当前批次不一致。`);
  }
}
export async function connectPreview(descriptor, { adb, device, onOwnedProcess, onReverse }) {
  const ports = [descriptor.backend.port, descriptor.media.port];
  const occupied = await Promise.all(ports.map(portOpen));
  let tunnel;
  if (occupied.some(Boolean) && !occupied.every(Boolean)) throw new Error('预览端口部分占用，拒绝混用不同隧道。');
  if (!occupied.every(Boolean)) {
    tunnel = jobSpawn(run('pwsh.exe', ['-NoProfile', '-NonInteractive', '-Command', '(Get-Command ssh.exe -CommandType Application -ErrorAction Stop).Source']), ['-N', '-T', '-o', 'BatchMode=yes', '-o', 'ExitOnForwardFailure=yes', '-o', 'ServerAliveInterval=15', '-o', 'ServerAliveCountMax=2', ...ports.flatMap(port => ['-L', `127.0.0.1:${port}:127.0.0.1:${port}`]), 'wenyou-dev-vps']);
    tunnel.stdout.resume(); tunnel.stderr.resume();
    tunnel.on('error', () => {});
    const record = { pid: tunnel.pid, processStarted: processIdentity(tunnel.pid), role: 'ssh', jobProtected: true };
    onOwnedProcess(record);
    for (let i = 0; i < 40; i++) { if ((await Promise.all(ports.map(portOpen))).every(Boolean)) break; await sleep(250); }
  }
  await verifyIdentity(descriptor);
  // 已有 reverse 不接管；匹配同一目标仅借用，其他映射拒绝覆盖。
  const reverse = run(adb, ['-s', device, 'reverse', '--list']);
  for (const port of ports) {
    const entry = reverse.split(/\r?\n/).map(line => line.trim().split(/\s+/)).find(fields => fields[1] === `tcp:${port}`);
    if (entry) {
      if (entry[2] !== `tcp:${port}`) throw new Error('设备 reverse 端口属于其他映射，拒绝覆盖。');
    } else {
      run(adb, ['-s', device, 'reverse', '--no-rebind', `tcp:${port}`, `tcp:${port}`]);
      onReverse(port);
    }
  }
  return { borrowedTunnel: !tunnel };
}
export function removeOwnedReverse(adb, device, ports) {
  for (const port of ports) {
    const lines = run(adb, ['-s', device, 'reverse', '--list']).split(/\r?\n/).map(line => line.trim().split(/\s+/));
    if (lines.some(fields => fields[1] === `tcp:${port}` && fields[2] === `tcp:${port}`)) run(adb, ['-s', device, 'reverse', '--remove', `tcp:${port}`]);
  }
}
