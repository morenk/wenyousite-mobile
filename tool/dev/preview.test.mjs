import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import net from 'node:net';
import { createHash } from 'node:crypto';
import { acquireLock, releaseLock, assertOwner, PACKAGE, selectDevice, portOpen, sameProcess, competingFlutter, privateDirectory, run } from './runtime.mjs';
import { validateDescriptor, verifyIdentity, CONTRACT_SHA } from './preview.mjs';

export function descriptor() {
  const runId = 'preview_' + 'a'.repeat(24);
  const service = port => ({ port, origin: `http://127.0.0.1:${port}`, identityUrl: `http://127.0.0.1:${port}/__preview/identity` });
  return { version: 1, kind: 'wenyou-dev-preview', state: 'ready', sessionId: 'test-preview', runId,
    snapshot: { capturedAt: '2026-09-26T00:00:00Z', businessDate: '2026-09-26', sha256: 'a'.repeat(64), sourceSha: 'b'.repeat(40), migrationVersion: 'migration-1' },
    source: { backendSha: CONTRACT_SHA, worktree: '/srv/wenyousite/worktrees/backend-preview' },
    backend: { ...service(23080), apiBase: 'http://127.0.0.1:23080/api/v1' }, media: service(23081), web: { port: 23082, origin: 'http://127.0.0.1:23082' },
    identity: { header: 'X-Wenyou-Preview-Run', value: runId }, ownership: { uid: 1000, resourceId: runId } };
}
function identityResponse(value, role, change = {}) {
  return new Response(JSON.stringify({ version: 1, kind: value.kind, sessionId: value.sessionId, runId: value.runId, role, resourceId: value.runId, snapshotSha256: value.snapshot.sha256, ...change }), { status: 200, headers: { 'Content-Type': 'application/json', 'X-Wenyou-Preview-Run': value.runId } });
}
test('固定 Backend 协议 SHA 与拷贝 schema 保持一致', () => {
  const source = JSON.parse(fs.readFileSync(new URL('../../contracts/dev-preview-session-source.json', import.meta.url), 'utf8'));
  assert.equal(source.revision, CONTRACT_SHA);
  for (const [name, digest] of Object.entries(source.files)) assert.equal(createHash('sha256').update(fs.readFileSync(new URL(`../../contracts/${name}`, import.meta.url))).digest('hex'), digest);
});
test('缺失配置、线上端口、不同签名端口与不完整身份均拒绝', () => {
  assert.throws(() => validateDescriptor(null));
  for (const mutation of [v => v.backend.port = 3000, v => v.media.port = 3001, v => v.media.origin = 'https://wenyou.site', v => v.backend.apiBase += '?other', v => v.ownership.resourceId = 'other', v => v.state = 'stopped']) {
    const value = descriptor(); mutation(value); assert.throws(() => validateDescriptor(value));
  }
  assert.equal(validateDescriptor(descriptor()).backend.port, 23080);
});
test('身份探测逐一核验 backend/media 且禁止重定向', async () => {
  const value = descriptor(); const visited = [];
  await verifyIdentity(value, async (url, options) => { assert.equal(options.redirect, 'manual'); const role = url === value.backend.identityUrl ? 'backend' : 'media'; visited.push(role); return identityResponse(value, role); });
  assert.deepEqual(visited, ['backend', 'media']);
});
test('v1消费者兼容单活动批次的固定入口且保留旧安全端口描述', () => {
  const value = descriptor();
  for (const [role, port] of Object.entries({ backend: 14311, media: 14312, web: 14310 })) {
    const origin = `http://127.0.0.1:${port}`;
    value[role] = { port, origin, ...(role !== 'web' ? { identityUrl: `${origin}/__preview/identity` } : {}), ...(role === 'backend' ? { apiBase: `${origin}/api/v1` } : {}) };
  }
  assert.equal(validateDescriptor(value).backend.port, 14311);
  assert.equal(validateDescriptor(descriptor()).backend.port, 23080);
});
test('实际资源、快照、角色、响应头或重定向不符 fail closed', async () => {
  const value = descriptor();
  for (const change of [{ runId: 'other' }, { snapshotSha256: 'b'.repeat(64) }, { role: 'media' }, { resourceId: 'other' }]) await assert.rejects(verifyIdentity(value, async () => identityResponse(value, 'backend', change)));
  await assert.rejects(verifyIdentity(value, async () => new Response(null, { status: 302, headers: { Location: 'https://wenyou.site' } })));
  await assert.rejects(verifyIdentity(value, async () => { const response = identityResponse(value, 'backend'); response.headers.delete('X-Wenyou-Preview-Run'); return response; }));
});
test('设备锁原子互斥，其他 owner 不能释放', t => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-lock-')); t.after(() => { assert.equal(path.dirname(dir), path.resolve(os.tmpdir())); fs.rmSync(dir, { recursive: true }); });
  const file = path.join(dir, 'device.json'); acquireLock(file, { token: 'first' });
  assert.throws(() => acquireLock(file, { token: 'other' })); releaseLock(file, 'other'); assert.ok(fs.existsSync(file)); releaseLock(file, 'first'); assert.equal(fs.existsSync(file), false);
});
test('跨任务、跨批次、跨Worktree与设备不能接管', () => {
  const owner = { worktree: 'd:/task', task: 'codex/task', sessionId: 'preview-one', device: 'arm64', package: PACKAGE };
  assert.doesNotThrow(() => assertOwner(owner, owner));
  for (const key of Object.keys(owner)) assert.throws(() => assertOwner({ ...owner, [key]: 'different' }, owner));
  assert.equal(sameProcess({ pid: 12345, processStarted: null }), false);
});
test('自动选择唯一 ARM64 真机，多设备显式指定且离线拒绝', () => {
  const devices = [{ id: 'one', state: 'device', abi: 'arm64-v8a' }, { id: 'two', state: 'device', abi: 'arm64-v8a' }];
  assert.throws(() => selectDevice(devices)); assert.equal(selectDevice(devices, 'two'), 'two'); assert.throws(() => selectDevice([{ ...devices[0], state: 'offline' }]));
});
test('已有 IDE 或命令行 Flutter run 会话不能被接管', () => {
  assert.equal(competingFlutter('dart.exe flutter_tools.snapshot run --machine -d one', 'one'), true);
  assert.equal(competingFlutter('dart.exe flutter_tools.snapshot run --machine', 'one'), true);
  assert.equal(competingFlutter('dart.exe flutter_tools.snapshot run -d two', 'one'), false);
  assert.equal(competingFlutter('dart.exe flutter_tools.snapshot test', 'one'), false);
});
test('Windows 控制目录移除继承，只授权当前用户与 SYSTEM', { skip: process.platform !== 'win32' }, t => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-acl-'));
  t.after(() => { assert.equal(path.dirname(dir), path.resolve(os.tmpdir())); fs.rmSync(dir, { recursive: true }); });
  privateDirectory(dir);
  privateDirectory(dir);
  const literal = `'${dir.replaceAll("'", "''")}'`;
  const permissions = JSON.parse(run('pwsh.exe', ['-NoProfile', '-NonInteractive', '-Command', `$acl=Get-Acl -LiteralPath ${literal}; @{protected=$acl.AreAccessRulesProtected; count=@($acl.Access).Count; inherited=@($acl.Access | Where-Object IsInherited).Count} | ConvertTo-Json -Compress`]));
  assert.deepEqual(permissions, { protected: true, count: 2, inherited: 0 });
});
test('实际 loopback 端口占用可以探测，禁止悄悄换签名端口', async t => {
  const server = net.createServer(socket => socket.end()); await new Promise(resolve => server.listen(0, '127.0.0.1', resolve)); t.after(() => server.close());
  assert.equal(await portOpen(server.address().port), true);
});
