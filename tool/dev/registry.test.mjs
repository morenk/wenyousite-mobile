import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import http from 'node:http';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { PACKAGE, hash, writeJson, processIdentity } from './runtime.mjs';
import { listSessions, authenticatedStatus, inspectProcess } from './registry.mjs';

function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-registry-'));
  t.after(() => { assert.equal(path.dirname(fs.realpathSync(root)), fs.realpathSync(os.tmpdir())); assert.match(path.basename(root), /^wenyou-registry-/); fs.rmSync(root, { recursive: true }); });
  const worktree = path.join(root, 'worktree');
  const directory = path.join(root, hash(worktree).slice(0, 20));
  fs.mkdirSync(directory);
  const record = { status: 'ready', task: 'codex/20260926-example', worktree, sessionId: 'test-preview', runId: `preview_${'a'.repeat(24)}`, device: 'one', package: PACKAGE, token: 'b'.repeat(64), pid: 1234, processStarted: 'time', controlPort: 43219, borrowedTunnel: true, children: [], reverse: [] };
  record.lockFile = path.join(root, `${hash(`${record.device}:${PACKAGE}`).slice(0, 24)}.lock.json`);
  const stateFile = path.join(directory, 'state.json');
  const save = () => { writeJson(stateFile, record); writeJson(record.lockFile, record); };
  save();
  return { root, record, stateFile, save };
}
const verified = { processState: () => 'same', status: async record => record };

test('跨Worktree列表仅输出归属摘要，活动会话必须核对进程、设备锁和authenticated status', async t => {
  const { root, record } = fixture(t);
  let probes = 0;
  const value = await listSessions(root, { ...verified, status: async input => { probes++; assert.equal(input.token, record.token); return input; } });
  assert.equal(probes, 1); assert.equal(value.blocked, false);
  assert.deepEqual(value.sessions[0], { state: 'ready', task: record.task, worktree: record.worktree, sessionId: record.sessionId, runId: record.runId, device: 'one', borrowedTunnel: true, active: true, blocked: false, reason: 'active' });
  const output = JSON.stringify(value);
  for (const privateValue of [record.token, 'controlPort', 'processStarted', 'lockFile', 'descriptorFile']) assert.equal(output.includes(privateValue), false);
});

test('停止/失败记录只有控制器和全部子进程退出、锁与reverse释放才安全', async t => {
  const { root, record, save } = fixture(t);
  record.status = 'stopped'; save();
  const options = { processState: () => 'absent' };
  assert.equal((await listSessions(root, options)).sessions[0].reason, 'owned-lock-retained');
  fs.unlinkSync(record.lockFile);
  assert.equal((await listSessions(root, options)).sessions[0].blocked, false);
  assert.equal((await listSessions(root, { processState: () => 'reused' })).sessions[0].blocked, false);
  assert.equal((await listSessions(root, { processState: () => 'unknown' })).sessions[0].blocked, true);
  record.children = [{ pid: 5, processStarted: 'child' }]; writeJson(path.join(root, hash(record.worktree).slice(0, 20), 'state.json'), record);
  assert.equal((await listSessions(root, { processState: value => value.pid === 5 ? 'same' : 'absent' })).sessions[0].reason, 'child-unverified');
  record.reverse = [14311]; writeJson(path.join(root, hash(record.worktree).slice(0, 20), 'state.json'), record);
  assert.equal((await listSessions(root, options)).sessions[0].reason, 'reverse-retained');
});

test('PID复用、进程未知、失联、错误鉴权/归属和变化中的登记都阻止切换', async t => {
  const { root, record, stateFile } = fixture(t);
  for (const processState of [() => 'reused', () => 'unknown', () => 'absent']) assert.equal((await listSessions(root, { ...verified, processState })).blocked, true);
  for (const status of [async () => { throw new Error(record.token); }, async () => ({ ...record, runId: `preview_${'c'.repeat(24)}` }), async () => { writeJson(stateFile, { ...record, token: 'd'.repeat(64) }); return record; }]) {
    writeJson(stateFile, record);
    const result = await listSessions(root, { ...verified, status });
    assert.equal(result.blocked, true); assert.equal(JSON.stringify(result).includes(record.token), false);
  }
});

test('损坏状态与孤立设备锁不可静默跳过；list不改写文件', async t => {
  const { root, stateFile, record } = fixture(t);
  fs.writeFileSync(stateFile, '{broken');
  const before = fs.readFileSync(record.lockFile, 'utf8');
  const result = await listSessions(root, verified);
  assert.equal(result.blocked, true); assert.equal(result.sessions.length, 2);
  assert.deepEqual(result.sessions.map(value => value.reason), ['state-unreadable', 'orphan-lock']);
  assert.equal(fs.readFileSync(record.lockFile, 'utf8'), before);
  assert.equal(fs.readFileSync(stateFile, 'utf8'), '{broken');
  fs.writeFileSync(stateFile, 'null');
  assert.equal((await listSessions(root, verified)).sessions[0].reason, 'state-invalid');
});

test('进程还活着时即使stopped也保持active；锁不匹配不会发送控制请求', async t => {
  const { root, record, save } = fixture(t);
  record.status = 'stopped'; save();
  assert.equal((await listSessions(root, verified)).sessions[0].active, true);
  writeJson(record.lockFile, { ...record, token: 'e'.repeat(64) });
  let called = false;
  const result = await listSessions(root, { ...verified, status: async () => { called = true; } });
  assert.equal(result.blocked, true); assert.equal(called, false);
});

test('真实loopback status核验鉴权与runId，拒绝重定向和错误归属', async t => {
  const { record } = fixture(t);
  let mode = 'ready';
  const server = http.createServer((request, response) => {
    assert.equal(request.url, '/control'); assert.equal(request.headers.authorization, `Bearer ${record.token}`);
    let raw = ''; request.on('data', value => { raw += value; });
    request.on('end', () => {
      assert.deepEqual(JSON.parse(raw), { action: 'status', worktree: record.worktree, task: record.task, runId: record.runId });
      if (mode === 'redirect') { response.writeHead(302, { Location: 'https://wenyou.site' }); response.end(); return; }
      response.writeHead(200, { 'Content-Type': 'application/json' }); response.end(JSON.stringify({ ...record, ...(mode === 'wrong' ? { device: 'other' } : {}) }));
    });
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(() => { server.closeAllConnections(); server.close(); });
  record.controlPort = server.address().port;
  await authenticatedStatus(record);
  for (mode of ['redirect', 'wrong']) await assert.rejects(authenticatedStatus(record));
});

test('Windows进程真实开始时间不匹配不能冒认为活动会话', { skip: process.platform !== 'win32' }, () => {
  assert.equal(inspectProcess({ pid: process.pid, processStarted: processIdentity(process.pid) }), 'same');
  assert.equal(inspectProcess({ pid: process.pid, processStarted: 'wrong' }), 'reused');
  assert.equal(inspectProcess({ pid: process.pid }), 'unknown');
  assert.equal(inspectProcess({ pid: 2147483647, processStarted: 'gone' }), 'absent');
});

test('CLI在非Git目录且没有SDK时仍输出无凭据JSON，不接受替代登记目录', { skip: process.platform !== 'win32' }, t => {
  const { root } = fixture(t);
  const file = fileURLToPath(new URL('./list.mjs', import.meta.url));
  const options = { cwd: root, encoding: 'utf8', windowsHide: true, env: { ...process.env, LOCALAPPDATA: root, FLUTTER_ROOT: 'missing', ANDROID_HOME: 'missing' } };
  const value = JSON.parse(execFileSync(process.execPath, [file, '--json'], options));
  assert.deepEqual(value, { version: 1, kind: 'wenyou-mobile-dev-sessions', blocked: false, sessions: [] });
  assert.throws(() => execFileSync(process.execPath, [file, '--root', root], { ...options, stdio: 'pipe' }));
});
