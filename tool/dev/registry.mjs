import fs from 'node:fs';
import path from 'node:path';
import { PACKAGE, hash, readJson, run } from './runtime.mjs';

const terminalStates = new Set(['stopped', 'failed']);
const knownStates = new Set(['starting', 'ready', 'unavailable', 'stopping', ...terminalStates]);
const keys = ['task', 'worktree', 'sessionId', 'runId', 'device'];
function summary(record) {
  return { state: knownStates.has(record?.status) ? record.status : 'unknown',
    ...Object.fromEntries(keys.map(key => [key, typeof record?.[key] === 'string' ? record[key] : null])),
    borrowedTunnel: typeof record?.borrowedTunnel === 'boolean' ? record.borrowedTunnel : null,
    active: false, blocked: true, reason: 'unverified' };
}
function owned(record) {
  return record && keys.every(key => typeof record[key] === 'string' && record[key].length > 0)
    && record.package === PACKAGE && /^[a-f0-9]{64}$/.test(record.token)
    && /^[a-z][a-z0-9-]{2,47}$/.test(record.sessionId) && /^preview_[a-f0-9]{24}$/.test(record.runId)
    && record.task.startsWith('codex/') && path.isAbsolute(record.worktree);
}
function sameOwner(left, right) { return keys.every(key => left[key] === right?.[key]) && left.package === right?.package; }

// null/unknown 必须与确认不存在的进程区分，避免权限失败变成“可切换”。
export function inspectProcess(record) {
  if (!Number.isSafeInteger(record?.pid) || record.pid < 1) return 'unknown';
  try {
    const value = JSON.parse(run('pwsh.exe', ['-NoProfile', '-NonInteractive', '-Command', `$ErrorActionPreference='Stop'; try { $p=Get-Process -Id ${record.pid}; @{exists=$true;started=$p.StartTime.ToUniversalTime().Ticks.ToString()} | ConvertTo-Json -Compress } catch { if ($_.CategoryInfo.Category -eq 'ObjectNotFound') { '{"exists":false}' } else { '{"exists":null}' } }`]));
    if (value.exists === false) return 'absent';
    if (value.exists !== true) return 'unknown';
    if (typeof record.processStarted !== 'string' || !record.processStarted || typeof value.started !== 'string') return 'unknown';
    return value.started === record.processStarted ? 'same' : 'reused';
  } catch { return 'unknown'; }
}

export async function authenticatedStatus(record, fetcher = fetch) {
  if (!Number.isInteger(record.controlPort) || record.controlPort < 1024 || record.controlPort > 65535) throw new Error('invalid control port');
  const response = await fetcher(`http://127.0.0.1:${record.controlPort}/control`, {
    method: 'POST', redirect: 'manual', headers: { Authorization: `Bearer ${record.token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ action: 'status', worktree: record.worktree, task: record.task, runId: record.runId }), signal: AbortSignal.timeout(3000),
  });
  if (response.status !== 200 || !response.headers.get('content-type')?.startsWith('application/json')) throw new Error('status unavailable');
  const status = await response.json();
  if (!sameOwner(record, status) || !knownStates.has(status.status)) throw new Error('status ownership changed');
  return status;
}

export async function listSessions(root, { processState = inspectProcess, status = authenticatedStatus } = {}) {
  const sessions = [];
  const consumedLocks = new Set();
  let entries;
  try {
    if (!fs.lstatSync(root).isDirectory()) throw new Error('registry is not a directory');
    entries = fs.readdirSync(root, { withFileTypes: true });
  }
  catch (error) {
    if (error.code === 'ENOENT') return { version: 1, kind: 'wenyou-mobile-dev-sessions', blocked: false, sessions };
    return { version: 1, kind: 'wenyou-mobile-dev-sessions', blocked: true, sessions: [{ ...summary(), reason: 'registry-unreadable' }] };
  }
  for (const entry of entries) {
    if (!entry.isDirectory() && !entry.isSymbolicLink()) continue;
    const directory = path.join(root, entry.name);
    const file = path.join(directory, 'state.json');
    if (entry.isSymbolicLink()) { sessions.push({ ...summary(), reason: 'registry-link' }); continue; }
    let record;
    try {
      if (!fs.lstatSync(file).isFile()) { sessions.push({ ...summary(), reason: 'state-not-regular' }); continue; }
      record = readJson(file);
    }
    catch (error) { if (error.code !== 'ENOENT') sessions.push({ ...summary(), reason: 'state-unreadable' }); continue; }
    const view = summary(record);
    sessions.push(view);
    if (!owned(record) || entry.name !== hash(record.worktree).slice(0, 20)
      || !knownStates.has(record.status) || !Array.isArray(record.children) || !Array.isArray(record.reverse)) { view.reason = 'state-invalid'; continue; }
    const lockFile = path.join(root, `${hash(`${record.device}:${PACKAGE}`).slice(0, 24)}.lock.json`);
    if (path.resolve(record.lockFile ?? '') !== path.resolve(lockFile)) { view.reason = 'lock-path-mismatch'; continue; }
    let lock;
    try {
      if (fs.existsSync(lockFile) && !fs.lstatSync(lockFile).isFile()) { view.reason = 'lock-not-regular'; continue; }
      lock = readJson(lockFile);
    }
    catch { view.reason = 'lock-unreadable'; continue; }
    if (lock?.token === record.token && sameOwner(record, lock)) consumedLocks.add(path.basename(lockFile));
    const identity = await processState(record);
    view.active = identity === 'same';
    if (view.active) {
      if (!consumedLocks.has(path.basename(lockFile))) { view.reason = 'lock-mismatch'; continue; }
      try {
        const current = await status(record);
        if (!sameOwner(record, current) || !knownStates.has(current.status)) throw new Error('owner');
        if (JSON.stringify(readJson(file)) !== JSON.stringify(record) || readJson(lockFile)?.token !== record.token
          || await processState(record) !== 'same') { view.reason = 'state-changed'; continue; }
        view.state = current.status;
        view.borrowedTunnel = typeof current.borrowedTunnel === 'boolean' ? current.borrowedTunnel : view.borrowedTunnel;
        view.blocked = false; view.reason = 'active';
      } catch { view.reason = 'controller-unverified'; }
      continue;
    }
    // PID 被复用证明原进程已退出；只有已完整释放资源的终态可据此放行。
    if (!['absent', 'reused'].includes(identity)) { view.reason = 'process-unverified'; continue; }
    if (!terminalStates.has(record.status)) { view.reason = 'controller-disconnected'; continue; }
    if (lock?.token === record.token) { view.reason = 'owned-lock-retained'; continue; }
    if (record.reverse.length) { view.reason = 'reverse-retained'; continue; }
    const childStates = await Promise.all(record.children.map(processState));
    if (childStates.some(value => !['absent', 'reused'].includes(value))) { view.reason = 'child-unverified'; continue; }
    // 读取过程中可能开始新会话；宁可要求重查，不把旧 stopped 当作新会话证明。
    try {
      if (JSON.stringify(readJson(file)) !== JSON.stringify(record)) { view.reason = 'state-changed'; continue; }
    } catch { view.reason = 'state-unreadable'; continue; }
    view.blocked = false; view.reason = 'stopped';
  }
  for (const entry of entries) {
    if (!entry.name.endsWith('.lock.json') || consumedLocks.has(entry.name)) continue;
    let lock;
    try { lock = !entry.isSymbolicLink() && readJson(path.join(root, entry.name)); } catch {}
    sessions.push({ ...summary(lock), reason: 'orphan-lock' });
  }
  return { version: 1, kind: 'wenyou-mobile-dev-sessions', blocked: sessions.some(value => value.blocked), sessions };
}
