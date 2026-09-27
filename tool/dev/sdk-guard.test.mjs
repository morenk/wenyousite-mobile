import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync, spawn } from 'node:child_process';
import { createInterface } from 'node:readline';
import { compileAdbGuard, prepareGuardedSdk } from './sdk-guard.mjs';

function removeTestDirectory(directory) {
  assert.equal(path.dirname(fs.realpathSync(directory)), fs.realpathSync(os.tmpdir()));
  assert.match(path.basename(directory), /^wenyou-adb-guard-/);
  fs.rmSync(directory, { recursive: true });
}
test('ADB guard保留参数、双向管道、退出码，拒绝卸载与清数据回退', { skip: process.platform !== 'win32' }, () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-adb-guard-'));
  try {
    const executable = compileAdbGuard(directory, process.execPath);
    const args = ['space arg', 'double"quote', 'trailing\\'];
    const forwarded = spawnSync(executable, ['-e', "process.stdin.once('data', data=>{process.stdout.write(JSON.stringify({args:process.argv.slice(1),input:data.toString()}));process.stderr.write('stderr-ok');process.exit(23);});", '--', ...args], { input: 'machine-input\n', encoding: 'utf8', windowsHide: true, timeout: 15000 });
    assert.equal(forwarded.status, 23);
    assert.equal(forwarded.stderr, 'stderr-ok');
    assert.deepEqual(JSON.parse(forwarded.stdout), { args, input: 'machine-input\n' });
    for (const command of [['-s', 'device', 'uninstall', 'site.wenyou.app.debug'], ['shell', 'pm', 'clear', 'site.wenyou.app.debug'], ['shell', 'pm clear site.wenyou.app.debug']]) {
      const denied = spawnSync(executable, command, { encoding: 'utf8', windowsHide: true });
      assert.equal(denied.status, 73);
      assert.match(denied.stderr, /data is preserved/);
    }
    // Flutter SDK AndroidDevice.installApp 的 install-r 失败→uninstall→重装路径。
    const calls = path.join(directory, 'calls.jsonl');
    const candidate = path.join(directory, 'existing-user-data');
    fs.writeFileSync(candidate, 'retain local token and draft');
    const install = spawnSync(executable, ['-e', `require('node:fs').appendFileSync(${JSON.stringify(calls)},${JSON.stringify('install-r-failed\n')});process.exit(1);`, '--', 'install', '-r', 'candidate.apk'], { encoding: 'utf8', windowsHide: true });
    assert.equal(install.status, 1);
    const uninstall = spawnSync(executable, ['uninstall', 'site.wenyou.app.debug'], { encoding: 'utf8', windowsHide: true });
    assert.equal(uninstall.status, 73); // Flutter 返回失败，不进入第二次安装。
    assert.equal(fs.readFileSync(calls, 'utf8'), 'install-r-failed\n');
    assert.equal(fs.readFileSync(candidate, 'utf8'), 'retain local token and draft');
  } finally { removeTestDirectory(directory); }
});

test('私有SDK视图和Flutter配置覆盖显式全局android-sdk且不修改原SDK', { skip: process.platform !== 'win32' }, () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-adb-guard-'));
  try {
    const sdk = path.join(directory, 'original');
    const originalAdb = path.join(sdk, 'platform-tools', 'adb.exe');
    fs.mkdirSync(path.dirname(originalAdb), { recursive: true });
    fs.writeFileSync(originalAdb, 'original-sdk-marker');
    fs.mkdirSync(path.join(sdk, 'platforms'));
    fs.mkdirSync(path.join(sdk, 'build-tools'));
    const appData = path.join(directory, 'original-config'); fs.mkdirSync(appData);
    const settings = JSON.stringify({ 'android-sdk': sdk, 'jdk-dir': 'custom-jdk' });
    fs.writeFileSync(path.join(appData, '.flutter_settings'), settings);
    const guarded = prepareGuardedSdk(originalAdb, path.join(directory, 'private'), { APPDATA: appData });
    assert.notEqual(guarded.environment.ANDROID_HOME, sdk);
    const config = JSON.parse(fs.readFileSync(path.join(guarded.environment.APPDATA, '.flutter_settings'), 'utf8'));
    assert.equal(config['android-sdk'], guarded.view);
    assert.equal(config['jdk-dir'], 'custom-jdk');
    assert.equal(fs.readFileSync(originalAdb, 'utf8'), 'original-sdk-marker');
    assert.equal(fs.readFileSync(path.join(appData, '.flutter_settings'), 'utf8'), settings);
    assert.equal(fs.realpathSync(path.join(guarded.view, 'platforms')), fs.realpathSync(path.join(sdk, 'platforms')));
  } finally { removeTestDirectory(directory); }
});

test('marker被独占打开时guard仍正常转发并保留退出码', { skip: process.platform !== 'win32', timeout: 20000 }, async () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-adb-guard-'));
  let holder;
  try {
    const executable = compileAdbGuard(directory, process.execPath);
    const marker = path.join(directory, 'adb-guard-used');
    const literal = `'${marker.replaceAll("'", "''")}'`;
    holder = spawn('pwsh.exe', ['-NoProfile', '-NonInteractive', '-Command', `$file=[IO.File]::Open(${literal},[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None); try { [Console]::Out.WriteLine('READY'); [Console]::Out.Flush(); [void][Console]::In.ReadLine() } finally { $file.Dispose() }`], { windowsHide: true, stdio: ['pipe', 'pipe', 'ignore'] });
    const lines = createInterface({ input: holder.stdout });
    await new Promise((resolve, reject) => { lines.once('line', line => line === 'READY' ? resolve() : reject(new Error('Marker lock failed'))); holder.once('error', reject); });
    const forwarded = spawnSync(executable, ['-e', "process.stdout.write(process.argv[1]);process.exit(19);", '--', 'kept argument'], { encoding: 'utf8', windowsHide: true, timeout: 15000 });
    assert.equal(forwarded.status, 19);
    assert.equal(forwarded.stdout, 'kept argument');
    lines.close();
  } finally {
    if (holder) { const closed = new Promise(resolve => holder.once('close', resolve)); holder.stdin.end('\n'); await closed; }
    removeTestDirectory(directory);
  }
});
