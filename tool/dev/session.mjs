import fs from 'node:fs';
import path from 'node:path';
import http from 'node:http';
import { fileURLToPath } from 'node:url';
import { randomBytes, timingSafeEqual } from 'node:crypto';
import { FlutterMachine, serialQueue } from './machine.mjs';
import { inspectSessionHealth, applyAvailability } from './health.mjs';
import { withLifecycleMutex, requireLaunchOwnership } from './lifecycle.mjs';
import { PACKAGE, run, canonical, hash, privateDirectory, readJson, writeJson, processIdentity, sameProcess, killOwnedProcess, acquireLock, releaseLock, assertOwner, sourceEvidence, discoverDevice, findAdb, flutterCommand, ownedSpawn, jobSpawn, sleep, assertNoCompetingFlutter, installedPackageEvidence, assertDebugPackageConfiguration } from './runtime.mjs';
import { loadDescriptor, verifyIdentity, connectPreview, removeOwnedReverse, CONTRACT_SHA } from './preview.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const worktree = canonical(path.resolve(here, '../..'));
const root = path.join(process.env.LOCALAPPDATA ?? '', 'Wenyou', 'live-debug');
const directory = path.join(root, hash(worktree).slice(0, 20));
const stateFile = path.join(directory, 'state.json');
const eventsFile = path.join(directory, 'events.jsonl');
function event(type, fields = {}) { fs.appendFileSync(eventsFile, `${JSON.stringify({ at: new Date().toISOString(), type, ...fields })}\n`, { mode: 0o600 }); }
function visible(state) {
  if (!state) return { status: 'stopped', worktree };
  const { status, task, sessionId, runId, device, package: appPackage, source, loadedSource, snapshotAt, borrowedTunnel, changedAt, failure, progress, flutterAppId, installedApp } = state;
  return { status, task, sessionId, runId, device, package: appPackage, source, loadedSource, snapshotAt, borrowedTunnel, changedAt, failure, progress, flutterAppId, installedApp, worktree, eventsFile };
}
function taskName() {
  const branch = run('git', ['branch', '--show-current'], { cwd: worktree });
  if (!branch.startsWith('codex/')) throw new Error('Debug 会话必须绑定 codex/ 任务分支。');
  return branch;
}
function argsOf(values) {
  const result = {};
  for (let i = 0; i < values.length; i += 2) {
    if (!['--session', '--device'].includes(values[i]) || !values[i + 1] || values[i + 1].startsWith('--')) throw new Error('参数为 --session <consumer.json> [--device <设备序号>]。');
    result[values[i].slice(2)] = values[i + 1];
  }
  return result;
}
async function control(state, action) {
  if (!sameProcess(state)) throw new Error('会话控制器已停止或 PID 已变化。');
  const response = await fetch(`http://127.0.0.1:${state.controlPort}/control`, { method: 'POST', headers: { Authorization: `Bearer ${state.token}`, 'Content-Type': 'application/json' }, body: JSON.stringify({ action, worktree, task: taskName(), runId: state.runId }), signal: AbortSignal.timeout(150_000) });
  const body = await response.json();
  if (response.status !== 200) throw new Error(body.error ?? '会话操作失败。');
  return body;
}
async function recoverStopped(state) {
  if (sameProcess(state)) throw new Error('已有控制器仍在运行，拒绝恢复。');
  if (state.task !== taskName() || state.worktree !== worktree) throw new Error('遗留会话属于其他任务。');
  for (const child of state.children ?? []) killOwnedProcess(child);
  if ((state.reverse ?? []).length) removeOwnedReverse(state.adb, state.device, state.reverse);
  releaseLock(state.lockFile, state.token);
  state.status = 'stopped'; state.reverse = []; state.children = []; state.changedAt = new Date().toISOString();
  writeJson(stateFile, state);
  event('recovered-stale-controller', { runId: state.runId, device: state.device });
}
async function cli(action, values) {
  if (action === 'start') return withLifecycleMutex(worktree, () => cliLocked(action, values));
  if (action !== 'stop') return cliLocked(action, values);
  const current = await withLifecycleMutex(worktree, async () => {
    const state = readJson(stateFile);
    if (!state) throw new Error('当前任务没有 Debug 会话。');
    if (state.task !== taskName() || state.worktree !== worktree) throw new Error('无法核验停止命令的任务归属。');
    if (!sameProcess(state)) { await recoverStopped(state); return { stopped: visible(readJson(stateFile)) }; }
    if (readJson(state.lockFile)?.token !== state.token) throw new Error('设备锁已变化，拒绝停止。');
    return { state };
  });
  if (current.stopped) return current.stopped;
  try { return await control(current.state, 'stop'); }
  catch {
    return withLifecycleMutex(worktree, async () => {
      const latest = readJson(stateFile);
      if (latest?.token !== current.state.token || latest.pid !== current.state.pid) throw new Error('停止期间控制器已变化，保留新会话。');
      killOwnedProcess(latest);
      await recoverStopped(readJson(stateFile));
      return visible(readJson(stateFile));
    });
  }
}
async function cliLocked(action, values) {
  if (process.platform !== 'win32') throw new Error('Mobile Debug 控制仅允许 Windows。');
  if (!process.env.LOCALAPPDATA) throw new Error('LOCALAPPDATA 缺失。');
  const options = argsOf(values);
  const existing = readJson(stateFile);
  if (action === 'status') {
    if (existing && sameProcess(existing)) return existing.controlPort ? control(existing, 'status') : visible(existing);
    return { ...visible(existing), status: existing && !['stopped', 'failed'].includes(existing.status) ? 'disconnected' : existing?.status ?? 'stopped' };
  }
  if (action !== 'start') {
    if (!existing) throw new Error('当前任务没有 Debug 会话。');
    return control(existing, action);
  }
  if (!options.session) throw new Error('dev:start 必须显式指定 --session <已核验的 consumer.json>，不提供线上默认值。');
  const descriptorFile = path.resolve(options.session);
  const descriptor = loadDescriptor(descriptorFile);
  assertDebugPackageConfiguration(worktree);
  const adb = findAdb();
  const device = discoverDevice(adb, options.device);
  const owner = { worktree, task: taskName(), sessionId: descriptor.sessionId, device, package: PACKAGE };
  if (existing && sameProcess(existing)) {
    assertOwner(existing, owner);
    if (existing.runId !== descriptor.runId) throw new Error('预览批次已重置；先停止旧 Debug 会话。');
    return existing.controlPort ? control(existing, 'status') : visible(existing);
  }
  if (existing && (!['stopped', 'failed'].includes(existing.status) || readJson(existing.lockFile)?.token === existing.token)) await recoverStopped(existing);
  assertNoCompetingFlutter(device);
  privateDirectory(root);
  privateDirectory(directory);
  const lockFile = path.join(root, `${hash(`${device}:${PACKAGE}`).slice(0, 24)}.lock.json`);
  const token = randomBytes(32).toString('hex');
  const state = { ...owner, token, lockFile, descriptorFile, runId: descriptor.runId, snapshotAt: descriptor.snapshot.capturedAt, status: 'starting', pid: process.pid, processStarted: processIdentity(process.pid), adb, source: sourceEvidence(worktree), children: [], reverse: [], contractSha: CONTRACT_SHA, changedAt: new Date().toISOString() };
  acquireLock(lockFile, state);
  try {
    writeJson(stateFile, state);
    const child = ownedSpawn(process.execPath, [fileURLToPath(import.meta.url), 'daemon', token, descriptor.runId], { detached: true, stdio: 'ignore', cwd: worktree });
    state.pid = child.pid; state.processStarted = processIdentity(child.pid);
    if (!state.processStarted) throw new Error('无法核验新控制器进程，保留设备锁。');
    writeJson(stateFile, state);
    child.unref();
    return visible(state);
  } catch (error) {
    // 已启动 daemon 时保留其锁，避免启动确认超时导致另一任务接管。
    const current = readJson(stateFile);
    if (current?.pid === process.pid) releaseLock(lockFile, token);
    throw error;
  }
}
async function daemon(launchToken, launchRunId) {
  const state = await withLifecycleMutex(worktree, async () => {
    const claimed = requireLaunchOwnership(stateFile, launchToken, launchRunId);
    if (claimed.worktree !== worktree || claimed.pid !== process.pid || !sameProcess(claimed)) throw new Error('控制器启动归属已变化。');
    return claimed;
  });
  const descriptor = loadDescriptor(state.descriptorFile);
  let machine;
  let stopping = false;
  let healthTimer;
  let healthRunning = false;
  let finishStartup;
  const startupFinished = new Promise(resolve => { finishStartup = resolve; });
  const enqueue = serialQueue();
  const save = () => {
    if (readJson(stateFile)?.token !== state.token) throw new Error('会话已变化，旧控制器不得覆盖状态。');
    state.changedAt = new Date().toISOString(); writeJson(stateFile, state);
  };
  async function stop(failure) {
    if (stopping) return;
    stopping = true; clearInterval(healthTimer);
    await startupFinished;
    return withLifecycleMutex(worktree, async () => {
    requireLaunchOwnership(stateFile, state.token, state.runId);
    state.status = 'stopping'; save();
    if (machine) { try { await Promise.race([machine.stop(), sleep(3000)]); } catch {} }
    const errors = [];
    for (const child of [...state.children].reverse()) { try { killOwnedProcess(child); } catch { errors.push('进程停止失败'); } }
    try { removeOwnedReverse(state.adb, state.device, state.reverse); state.reverse = []; } catch { errors.push('设备 reverse 尚未清理（设备可能离线）'); }
    state.status = failure || errors.length ? 'failed' : 'stopped';
    state.failure = [failure, ...errors].filter(Boolean).join('；') || undefined;
    if (!errors.length) { state.children = []; releaseLock(state.lockFile, state.token); }
    save(); event(state.status, { runId: state.runId, device: state.device, failure: state.failure });
    server.close();
    setTimeout(() => process.exit(errors.length || failure ? 1 : 0), 300).unref();
    });
  }
  const server = http.createServer((request, response) => {
    const auth = Buffer.from(request.headers.authorization ?? '');
    const expected = Buffer.from(`Bearer ${state.token}`);
    if (request.method !== 'POST' || request.url !== '/control' || auth.length !== expected.length || !timingSafeEqual(auth, expected)) { response.writeHead(403); response.end(); return; }
    let raw = '';
    request.on('data', chunk => { raw += chunk; if (raw.length > 2048) request.destroy(); });
    request.on('end', () => enqueue(async () => {
      try {
        const input = JSON.parse(raw);
        if (input.worktree !== worktree || input.task !== state.task || input.runId !== state.runId) throw new Error('控制命令所有权不匹配。');
        if (!['status', 'reload', 'restart', 'stop'].includes(input.action)) throw new Error('未知控制命令。');
        if (input.action === 'stop') { await startupFinished; await stop(); }
        if (['reload', 'restart'].includes(input.action)) {
          if (stopping || !machine?.ready || !['ready', 'unavailable'].includes(state.status)) throw new Error('会话未就绪；先检查 dev:status。');
          try { await verifyIdentity(descriptor); }
          catch {
            applyAvailability(state, false, machine.ready); save();
            throw new Error('预览身份当前不可用；保留页面，等待恢复后重试。');
          }
          applyAvailability(state, true, machine.ready);
          discoverDevice(state.adb, state.device);
          const source = sourceEvidence(worktree);
          await machine.restart(input.action === 'restart');
          const after = sourceEvidence(worktree);
          if (source.sourceDigest !== after.sourceDigest) throw new Error('热重载期间源码变化，请稳定修改后重试以绑定正确画面。');
          state.source = source; state.loadedSource = source; save();
          const installed = installedPackageEvidence(state.adb, state.device);
          state.installedApp = { ...state.installedApp, ...installed }; save();
          event(input.action, { ...source, runId: state.runId, device: state.device, flutterAppId: machine.appId, installed });
        }
        response.writeHead(200, { 'Content-Type': 'application/json' }); response.end(JSON.stringify(visible(state)));
      } catch (error) { response.writeHead(409, { 'Content-Type': 'application/json' }); response.end(JSON.stringify({ error: error.message })); }
    }));
  });
  await new Promise((resolve, reject) => { server.once('error', reject); server.listen(0, '127.0.0.1', resolve); });
  state.controlPort = server.address().port; save();
  for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => stop());
  process.on('uncaughtException', () => stop('控制器异常退出；未输出敏感运行日志。'));
  process.on('unhandledRejection', () => stop('控制器异步异常；检查状态与设备。'));
  try {
    state.borrowedTunnel = (await connectPreview(descriptor, {
      adb: state.adb, device: state.device,
      onOwnedProcess: record => { state.children.push(record); save(); },
      onReverse: port => { state.reverse.push(port); save(); },
    })).borrowedTunnel;
    if (stopping) return;
    const command = flutterCommand();
    const child = jobSpawn(command.file, [...command.prefix, 'run', '--machine', '--debug', '-d', state.device,
      `--dart-define=API_BASE_URL=${descriptor.backend.apiBase}`,
      `--dart-define=WENYOU_PREVIEW_SESSION=${descriptor.sessionId}`,
      `--dart-define=WENYOU_PREVIEW_RUN=${descriptor.runId}`,
      `--dart-define=WENYOU_PREVIEW_SNAPSHOT_AT=${descriptor.snapshot.capturedAt}`,
      `--dart-define=WENYOU_PREVIEW_SNAPSHOT_SHA=${descriptor.snapshot.sha256}`,
      `--dart-define=WENYOU_PREVIEW_MEDIA_ORIGIN=${descriptor.media.origin}`,
    ], { cwd: worktree });
    state.children.push({ pid: child.pid, processStarted: processIdentity(child.pid), role: 'flutter', jobProtected: true }); save();
    machine = new FlutterMachine(child);
    machine.on('progress', progress => { state.progress = progress; save(); });
    machine.on('ready', () => {
      if (stopping) return;
      const after = sourceEvidence(worktree);
      if (state.status !== 'unavailable') state.status = 'ready';
      state.flutterAppId = machine.appId;
      state.installedApp = installedPackageEvidence(state.adb, state.device, { includeHash: true });
      state.loadedSource = state.source.sourceDigest === after.sourceDigest ? state.source : null;
      state.progress = state.loadedSource ? undefined : { needsReload: true };
      save();
      event('ready', { source: state.loadedSource, runId: state.runId, device: state.device, flutterAppId: machine.appId, installed: state.installedApp, needsReload: !state.loadedSource });
    });
    machine.on('closed', reason => { if (!stopping) void stop(reason); });
    healthTimer = setInterval(async () => {
      if (stopping || healthRunning) return;
      healthRunning = true;
      try {
        const connectivity = await inspectSessionHealth({
          verifyDevice: () => discoverDevice(state.adb, state.device),
          verifyOwnedTunnel: () => { if (state.children.some(child => child.role === 'ssh' && !sameProcess(child))) throw new Error('owned tunnel closed'); },
          verifyEnvironment: () => verifyIdentity(descriptor),
        });
        if (stopping) return;
        if (connectivity === 'disconnected') await stop('真机或本任务SSH已失联，已停止调试；禁止回落线上。');
        else if (applyAvailability(state, connectivity === 'available', machine.ready)) { save(); event(state.status, { runId: state.runId, device: state.device }); }
      }
      finally { healthRunning = false; }
    }, 15_000);
  } catch { finishStartup(); await stop('预览启动失败：核对独立资源身份、端口、SSH 与设备；未启动线上连接。'); }
  finally { finishStartup(); }
}

const [action = 'status', ...values] = process.argv.slice(2);
try {
  if (action === 'daemon') await daemon(...values);
  else {
    if (!['start', 'status', 'reload', 'restart', 'stop'].includes(action)) throw new Error('未知 Debug 命令。');
    console.log(JSON.stringify(await cli(action, values), null, 2));
  }
} catch (error) { console.error(error.message); process.exitCode = 1; }
