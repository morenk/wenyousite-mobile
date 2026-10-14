import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { flutterCommand } from './runtime.mjs';
import { prepareGuardedSdk, verifyGuardSelected } from './sdk-guard.mjs';

export function debugArguments(args) {
  if (args.some(value => /^--(?:release|profile|uninstall-first)(?:=|$)/.test(value)
    || value.includes('WENYOU_PREVIEW_'))) {
    throw new Error('此入口仅运行保留应用数据的普通 Debug；请移除旧预览配置、卸载或其他构建模式参数。');
  }
  return ['run', '--debug', ...args];
}

export function main(args = process.argv.slice(2)) {
  const forwarded = debugArguments(args);
  if (process.platform !== 'win32') throw new Error('Mobile 开发仅支持 Windows。');
  const repository = path.resolve(fileURLToPath(new URL('../..', import.meta.url)));
  const gradle = fs.readFileSync(path.join(repository, 'android/app/build.gradle.kts'), 'utf8');
  if (!/defaultConfig\s*\{[^}]*applicationId\s*=\s*"site\.wenyou\.app"/.test(gradle)
    || !/getByName\("debug"\)\s*\{[^}]*applicationIdSuffix\s*=\s*"\.debug"/.test(gradle)) {
    throw new Error('无法核验 Debug 包名，停止安装。');
  }
  const command = flutterCommand();
  const adb = [process.env.ANDROID_SDK_ROOT, process.env.ANDROID_HOME, 'D:\\sdk\\android']
    .filter(Boolean).map(root => path.join(root, 'platform-tools/adb.exe')).find(fs.existsSync);
  if (!adb) throw new Error('找不到 Android SDK；请设置 ANDROID_SDK_ROOT。');
  const guarded = prepareGuardedSdk(adb, path.join(repository, 'build/debug-sdk'));
  verifyGuardSelected(command, guarded);
  const result = spawnSync(command.file, [...command.prefix, ...forwarded], {
    cwd: repository, env: guarded.environment, stdio: 'inherit', windowsHide: true,
  });
  if (result.error) throw result.error;
  return result.status ?? 1;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try { process.exitCode = main(); }
  catch (error) { console.error(error.message); process.exitCode = 1; }
}
