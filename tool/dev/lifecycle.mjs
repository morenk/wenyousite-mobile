import { spawn } from 'node:child_process';
import { createInterface } from 'node:readline';
import { fileURLToPath } from 'node:url';
import { hash, readJson } from './runtime.mjs';

export async function withLifecycleMutex(worktree, operation) {
  const child = spawn('pwsh.exe', ['-NoProfile', '-NonInteractive', '-File', fileURLToPath(new URL('./lifecycle-lock.ps1', import.meta.url)), '-Name', `Local\\WenyouPreview-${hash(worktree)}`], { windowsHide: true, stdio: ['pipe', 'pipe', 'ignore'] });
  const lines = createInterface({ input: child.stdout });
  let exited = false;
  child.stdin.on('error', () => {});
  const done = new Promise(resolve => child.once('close', () => { exited = true; resolve(); }));
  try {
    await new Promise((resolve, reject) => {
      child.once('error', () => reject(new Error('无法获取 Windows 会话互斥。')));
      child.once('exit', () => reject(new Error('会话互斥超时或中断。')));
      lines.once('line', line => line === 'READY' ? resolve() : reject(new Error('会话互斥协议错误。')));
    });
    return await operation();
  } finally {
    lines.close();
    if (!exited) child.stdin.end('\n');
    await done;
  }
}

export function requireLaunchOwnership(stateFile, token, runId) {
  const current = readJson(stateFile);
  if (!current || current.token !== token || current.runId !== runId || readJson(current.lockFile)?.token !== token) throw new Error('启动令牌或设备锁已变化，旧控制器不得接管。');
  return current;
}

export async function startWithLifecycleMutex(worktree, prepare, status) {
  const result = await withLifecycleMutex(worktree, prepare);
  // HTTP 队列里的 stop 也需要此 mutex；任何控制 RPC 都必须在锁外等待。
  return result.reuse ? status(result.reuse) : result;
}
