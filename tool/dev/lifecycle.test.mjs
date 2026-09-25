import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { randomUUID } from 'node:crypto';
import { spawn } from 'node:child_process';
import { withLifecycleMutex, requireLaunchOwnership } from './lifecycle.mjs';
import { readJson, writeJson, releaseLock, jobSpawn, sleep, killOwnedProcess } from './runtime.mjs';

function removeTestDirectory(directory) {
  assert.equal(path.dirname(fs.realpathSync(directory)), fs.realpathSync(os.tmpdir()));
  assert.match(path.basename(directory), /^wenyou-(lifecycle|launch|job|mutex)-/);
  fs.rmSync(directory, { recursive: true });
}

test('并发旧会话恢复串行重读，不删除新锁或清理新reverse', { skip: process.platform !== 'win32' }, async () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-lifecycle-'));
  const stateFile = path.join(directory, 'state.json');
  const lockFile = path.join(directory, 'device.lock');
  writeJson(stateFile, { token: 'old', runId: 'old-run', lockFile });
  writeJson(lockFile, { token: 'old' });
  const actions = [];
  const recover = () => withLifecycleMutex(directory, async () => {
    const current = readJson(stateFile);
    if (current.token !== 'old') return;
    actions.push('clean-old-reverse');
    await sleep(100);
    releaseLock(lockFile, current.token);
    writeJson(lockFile, { token: 'new' });
    writeJson(stateFile, { token: 'new', runId: 'new-run', lockFile });
  });
  await Promise.all([recover(), recover(), recover()]);
  assert.deepEqual(actions, ['clean-old-reverse']);
  assert.equal(readJson(lockFile).token, 'new');
  assert.throws(() => requireLaunchOwnership(stateFile, 'old', 'old-run'), /启动令牌/);
  assert.equal(requireLaunchOwnership(stateFile, 'new', 'new-run').token, 'new');
  removeTestDirectory(directory);
});

test('延迟旧daemon不能领取新state或覆盖PID', () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-launch-'));
  const stateFile = path.join(directory, 'state.json');
  const lockFile = path.join(directory, 'device.lock');
  writeJson(stateFile, { token: 'new', runId: 'new-run', lockFile, pid: 123 });
  writeJson(lockFile, { token: 'new' });
  assert.throws(() => requireLaunchOwnership(stateFile, 'old', 'old-run'), /启动令牌/);
  assert.equal(readJson(stateFile).pid, 123);
  assert.throws(() => requireLaunchOwnership(stateFile, 'new', 'old-run'), /启动令牌/);
  removeTestDirectory(directory);
});

async function waitFor(check) {
  for (let i = 0; i < 120; i++) { const value = check(); if (value) return value; await sleep(100); }
  throw new Error('Windows Job behavior check timed out');
}
function alive(pid) { try { process.kill(pid, 0); return true; } catch { return false; } }

for (const exitKind of ['wrapper-killed', 'flutter-root-killed']) {
  test(`Windows Job 在${exitKind}时回收已启动的编译后代`, { skip: process.platform !== 'win32', timeout: 40000 }, async () => {
    const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-job-'));
    const marker = path.join(directory, 'descendants.json');
    const script = `const {spawn}=require('node:child_process'); const fs=require('node:fs'); const c=spawn(process.execPath,['-e','setInterval(()=>{},1000)'],{stdio:'ignore',windowsHide:true}); fs.writeFileSync(${JSON.stringify(marker)},JSON.stringify({root:process.pid,descendant:c.pid}));setInterval(()=>{},1000);`;
    const child = jobSpawn(process.execPath, ['-e', script, `quote-"-${randomUUID()}\\`]);
    child.stdout.resume(); child.stderr.resume();
    let owned;
    try {
      const ids = await waitFor(() => fs.existsSync(marker) && readJson(marker));
      owned = ids;
      assert.equal(alive(ids.root), true); assert.equal(alive(ids.descendant), true);
      // 模拟真正强杀，不通过 taskkill /T，只有 Job handle 负责后代。
      process.kill(exitKind === 'wrapper-killed' ? child.pid : ids.root);
      await waitFor(() => !alive(ids.root) && !alive(ids.descendant));
    } finally {
      if (alive(child.pid)) process.kill(child.pid);
      if (owned) for (const pid of Object.values(owned)) if (alive(pid)) process.kill(pid);
      removeTestDirectory(directory);
    }
  });
}

test('未登记Job的旧Flutter根退出后保留锁与未知后代', () => {
  assert.throws(() => killOwnedProcess({ pid: 999999999, processStarted: 'old', role: 'flutter' }), /保留设备锁/);
});

test('Job wrapper保留machine双向管道与Windows参数引用', { skip: process.platform !== 'win32', timeout: 20000 }, async () => {
  const args = ['space arg', 'double"quote', 'trailing\\'];
  const child = jobSpawn(process.execPath, ['-e', "process.stdin.once('data', data=>{process.stdout.write(JSON.stringify({args:process.argv.slice(1),input:data.toString()}));process.exit(0);});", ...args]);
  const chunks = [];
  child.stdout.on('data', chunk => chunks.push(chunk)); child.stderr.resume();
  const completed = new Promise(resolve => child.once('exit', resolve));
  child.stdin.write('machine-request\n');
  assert.equal(await completed, 0);
  assert.deepEqual(JSON.parse(Buffer.concat(chunks).toString()), { args, input: 'machine-request\n' });
});

test('控制进程异常退出后系统互斥自动释放', { skip: process.platform !== 'win32', timeout: 25000 }, async () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-mutex-'));
  const marker = path.join(directory, 'held');
  const moduleUrl = new URL('./lifecycle.mjs', import.meta.url).href;
  const source = `import fs from 'node:fs';const {withLifecycleMutex}=await import(${JSON.stringify(moduleUrl)});await withLifecycleMutex(${JSON.stringify(directory)},async()=>{fs.writeFileSync(${JSON.stringify(marker)},'held');await new Promise(()=>{});});`;
  const child = spawn(process.execPath, ['--input-type=module', '-e', source], { windowsHide: true, stdio: 'ignore' });
  try {
    await waitFor(() => fs.existsSync(marker));
    process.kill(child.pid);
    let acquired = false;
    await withLifecycleMutex(directory, async () => { acquired = true; });
    assert.equal(acquired, true);
  } finally {
    if (alive(child.pid)) process.kill(child.pid);
    removeTestDirectory(directory);
  }
});

test('daemon在登记子进程前被强杀时Job仍回收全部后代', { skip: process.platform !== 'win32', timeout: 35000 }, async () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-job-'));
  const marker = path.join(directory, 'unregistered.json');
  const runtimeUrl = new URL('./runtime.mjs', import.meta.url).href;
  const childCode = `const {spawn}=require('node:child_process');const fs=require('node:fs');const c=spawn(process.execPath,['-e','setInterval(()=>{},1000)'],{stdio:'ignore',windowsHide:true});fs.writeFileSync(${JSON.stringify(marker)},JSON.stringify({root:process.pid,descendant:c.pid}));setInterval(()=>{},1000);`;
  const ownerCode = `const {jobSpawn}=await import(${JSON.stringify(runtimeUrl)});const c=jobSpawn(process.execPath,['-e',${JSON.stringify(childCode)}]);c.stdout.resume();c.stderr.resume();setInterval(()=>{},1000);`;
  const owner = spawn(process.execPath, ['--input-type=module', '-e', ownerCode], { windowsHide: true, stdio: 'ignore' });
  let ids;
  try {
    ids = await waitFor(() => fs.existsSync(marker) && readJson(marker));
    process.kill(owner.pid);
    await waitFor(() => !alive(ids.root) && !alive(ids.descendant));
  } finally {
    if (alive(owner.pid)) process.kill(owner.pid);
    if (ids) for (const pid of Object.values(ids)) if (alive(pid)) process.kill(pid);
    removeTestDirectory(directory);
  }
});
