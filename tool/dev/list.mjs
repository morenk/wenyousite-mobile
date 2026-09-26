import path from 'node:path';
import { listSessions } from './registry.mjs';

try {
  if (process.platform !== 'win32' || !process.env.LOCALAPPDATA) throw new Error('Mobile 会话查询仅支持具有 LOCALAPPDATA 的 Windows 当前用户。');
  if (process.argv.slice(2).some(value => value !== '--json') || process.argv.length > 3) throw new Error('参数仅支持 --json。');
  const result = await listSessions(path.join(process.env.LOCALAPPDATA, 'Wenyou', 'live-debug'));
  console.log(JSON.stringify(result, null, 2));
} catch {
  console.error('无法核验 Mobile 会话登记；禁止暂停或切换共享预览。');
  process.exitCode = 1;
}
