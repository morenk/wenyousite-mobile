import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { run, hash, privateDirectory } from './runtime.mjs';

const guardSource = fileURLToPath(new URL('./adb-guard.cs', import.meta.url));
export function compileAdbGuard(directory, target) {
  privateDirectory(directory);
  const compiler = path.join(process.env.WINDIR ?? 'C:\\Windows', 'Microsoft.NET', 'Framework64', 'v4.0.30319', 'csc.exe');
  const executable = path.join(directory, 'adb.exe');
  run(compiler, ['/nologo', '/target:exe', `/out:${executable}`, guardSource]);
  fs.writeFileSync(path.join(directory, 'adb-target.txt'), target, { mode: 0o600 });
  return executable;
}

export function prepareGuardedSdk(adb, directory, environment = process.env) {
  const realAdb = fs.realpathSync(adb);
  if (path.basename(realAdb).toLowerCase() !== 'adb.exe' || path.basename(path.dirname(realAdb)).toLowerCase() !== 'platform-tools') throw new Error('需要已安装 Android SDK 的真实 adb.exe 路径。');
  const sdk = path.dirname(path.dirname(realAdb));
  const view = path.join(directory, `sdk-${hash(sdk + fs.readFileSync(guardSource)).slice(0, 16)}`);
  privateDirectory(view);
  for (const entry of fs.readdirSync(sdk, { withFileTypes: true })) {
    if (!entry.isDirectory() || entry.name === 'platform-tools') continue;
    const link = path.join(view, entry.name);
    const target = path.join(sdk, entry.name);
    if (!fs.existsSync(link)) fs.symlinkSync(target, link, 'junction');
    if (fs.realpathSync(link).toLowerCase() !== fs.realpathSync(target).toLowerCase()) throw new Error('私有 SDK 视图归属不匹配。');
  }
  const platformTools = path.join(view, 'platform-tools');
  const guardedAdb = compileAdbGuard(platformTools, realAdb);
  for (const name of ['package.xml', 'source.properties']) {
    const metadata = path.join(sdk, 'platform-tools', name);
    if (fs.existsSync(metadata)) fs.copyFileSync(metadata, path.join(platformTools, name));
  }
  const configDirectory = path.join(view, 'flutter-config');
  privateDirectory(configDirectory);
  const original = environment.APPDATA && path.join(environment.APPDATA, '.flutter_settings');
  const settings = original && fs.existsSync(original) ? JSON.parse(fs.readFileSync(original, 'utf8')) : {};
  settings['android-sdk'] = view;
  fs.writeFileSync(path.join(configDirectory, '.flutter_settings'), JSON.stringify(settings), { mode: 0o600 });
  return { view, guardedAdb, environment: { ...environment, ANDROID_HOME: view, ANDROID_SDK_ROOT: view, APPDATA: configDirectory } };
}

export function verifyGuardSelected(command, guardedSdk, device) {
  const marker = path.join(path.dirname(guardedSdk.guardedAdb), 'adb-guard-used');
  const previous = fs.existsSync(marker) ? fs.readFileSync(marker, 'utf8') : null;
  const output = run(command.file, [...command.prefix, 'devices', '--machine', '--device-timeout', '1'], { env: guardedSdk.environment, timeout: 45000 });
  if (!fs.existsSync(marker) || fs.readFileSync(marker, 'utf8') === previous) throw new Error('无法证明 Flutter 通过保留数据的 ADB guard，拒绝安装。');
  const devices = JSON.parse(output);
  if (!Array.isArray(devices) || (device && !devices.some(item => item.id === device))) throw new Error('Flutter 未识别当前真机，拒绝安装。');
}
