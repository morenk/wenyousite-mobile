import fs from 'node:fs';
import path from 'node:path';
import { privateDirectory } from './runtime.mjs';

export const TRANSITION_CONTRACT_SHA = '1338a78407ce83b9b0d039c59d411c0a67a45a39';
function alive(pid) {
  try { process.kill(pid, 0); return true; }
  catch (error) { return error.code !== 'ESRCH'; }
}
function sameFile(left, right) { return left.isFile() && right.isFile() && left.dev === right.dev && left.ino === right.ino; }
function release(file, handle, value) {
  try {
    if (!sameFile(fs.fstatSync(handle, { bigint: true }), fs.lstatSync(file, { bigint: true })) || fs.readFileSync(file, 'utf8') !== value) throw new Error('过渡锁归属已变化；保留现场。');
    fs.unlinkSync(file);
  } finally { fs.closeSync(handle); }
}
function create(file) {
  const handle = fs.openSync(file, 'wx', 0o600);
  try { fs.writeFileSync(handle, String(process.pid)); return handle; }
  catch (error) { fs.closeSync(handle); throw error; }
}
function claim(file, processAlive) {
  try { return create(file); }
  catch (error) { if (error.code !== 'EEXIST') throw error; }
  const recovery = `${file}.recovery`;
  const guard = create(recovery);
  try {
    const before = fs.lstatSync(file, { bigint: true });
    if (!before.isFile()) throw new Error('过渡锁不是普通文件。');
    const content = fs.readFileSync(file, 'utf8');
    const pid = Number(content);
    if (!/^[1-9]\d*$/.test(content) || !Number.isSafeInteger(pid) || processAlive(pid) !== false) throw new Error('另一预览操作仍在运行或锁归属不明；稍后重试。');
    if (!sameFile(before, fs.lstatSync(file, { bigint: true })) || fs.readFileSync(file, 'utf8') !== content) throw new Error('过渡锁在核验期间变化。');
    fs.unlinkSync(file);
    return create(file);
  } finally { release(recovery, guard, String(process.pid)); }
}

// 与治理入口共用短期互斥；设备会话的长期归属仍由原有状态和设备锁保护。
export async function withTransitionLock(operation, { root, processAlive = alive } = {}) {
  if (!root) {
    if (!process.env.LOCALAPPDATA) throw new Error('LOCALAPPDATA 缺失，无法核验预览操作锁。');
    root = path.join(process.env.LOCALAPPDATA, 'Wenyou', 'preview-control');
    fs.mkdirSync(root, { recursive: true, mode: 0o700 });
    if (!fs.lstatSync(root).isDirectory()) throw new Error('预览操作锁目录必须是实际目录。');
    privateDirectory(root);
  }
  const file = path.join(root, 'transition.lock');
  const handle = claim(file, processAlive);
  try { return await operation(); }
  finally { release(file, handle, String(process.pid)); }
}
