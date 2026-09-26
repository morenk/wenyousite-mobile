import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { withTransitionLock } from './transition-lock.mjs';

function temporary(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-transition-'));
  t.after(() => { assert.equal(path.dirname(fs.realpathSync(root)), fs.realpathSync(os.tmpdir())); assert.match(path.basename(root), /^wenyou-transition-/); fs.rmSync(root, { recursive: true }); });
  return { root, file: path.join(root, 'transition.lock') };
}
test('治理切换持锁时Mobile start拒绝进入，异常出口释放且同PID不重入', async t => {
  const { root, file } = temporary(t);
  let started = 0;
  await assert.rejects(withTransitionLock(async () => {
    assert.equal(fs.readFileSync(file, 'utf8'), String(process.pid));
    await assert.rejects(withTransitionLock(() => { started++; }, { root }));
    throw new Error('startup failure');
  }, { root }), /startup failure/);
  assert.equal(started, 0); assert.equal(fs.existsSync(file), false);
  await withTransitionLock(() => { started++; }, { root });
  assert.equal(started, 1);
});
test('只恢复确认不存在PID的锁；活PID、未知PID、空文件与坏内容保留', async t => {
  const { root, file } = temporary(t);
  fs.writeFileSync(file, '99999999');
  await withTransitionLock(() => assert.equal(fs.readFileSync(file, 'utf8'), String(process.pid)), { root, processAlive: () => false });
  for (const content of ['', 'broken', '-1', '0', '1\n', String(process.pid)]) {
    fs.writeFileSync(file, content);
    await assert.rejects(withTransitionLock(() => assert.fail('must not enter'), { root }));
    assert.equal(fs.readFileSync(file, 'utf8'), content);
  }
  fs.writeFileSync(file, '1234');
  await assert.rejects(withTransitionLock(() => assert.fail(), { root, processAlive: () => undefined }));
  await assert.rejects(withTransitionLock(() => assert.fail(), { root, processAlive: () => { throw new Error('unknown'); } }));
  assert.equal(fs.readFileSync(file, 'utf8'), '1234');
});
test('recovery互斥存在时不恢复；释放时发现替换保留新锁', async t => {
  const { root, file } = temporary(t);
  fs.writeFileSync(file, '1234'); fs.writeFileSync(`${file}.recovery`, '4567');
  await assert.rejects(withTransitionLock(() => assert.fail(), { root, processAlive: () => false }));
  assert.equal(fs.readFileSync(file, 'utf8'), '1234');
  fs.unlinkSync(`${file}.recovery`); fs.unlinkSync(file);
  await assert.rejects(withTransitionLock(() => { fs.unlinkSync(file); fs.writeFileSync(file, '9999'); }, { root }), /归属已变化/);
  assert.equal(fs.readFileSync(file, 'utf8'), '9999');
});
test('并发恢复者不能删除已被首个操作领取的新锁', async t => {
  const { root, file } = temporary(t); fs.writeFileSync(file, '99999999');
  let resolveFirst;
  const held = new Promise(resolve => { resolveFirst = resolve; });
  const first = withTransitionLock(() => held, { root, processAlive: pid => pid === process.pid });
  await assert.rejects(withTransitionLock(() => assert.fail(), { root, processAlive: pid => pid === process.pid }));
  assert.equal(fs.readFileSync(file, 'utf8'), String(process.pid)); resolveFirst(); await first;
  assert.equal(fs.existsSync(file), false);
});
test('真实dev:start入口在治理锁占用时先拒绝，不读取consumer或启动设备', { skip: process.platform !== 'win32' }, t => {
  const { root } = temporary(t);
  const controlRoot = path.join(root, 'Wenyou', 'preview-control');
  fs.mkdirSync(controlRoot, { recursive: true });
  const lock = path.join(controlRoot, 'transition.lock');
  fs.writeFileSync(lock, String(process.pid));
  assert.throws(() => execFileSync(process.execPath, [fileURLToPath(new URL('./session.mjs', import.meta.url)), 'start', '--session', 'nonexistent-consumer.json'], {
    cwd: root, windowsHide: true, stdio: 'pipe', encoding: 'utf8', env: { ...process.env, LOCALAPPDATA: root },
  }), error => /另一预览操作仍在运行/.test(error.stderr));
  assert.equal(fs.readFileSync(lock, 'utf8'), String(process.pid));
  assert.equal(fs.existsSync(path.join(root, 'Wenyou', 'live-debug')), false);
});
