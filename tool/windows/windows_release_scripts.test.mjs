import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { mkdtemp, mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const directory = path.dirname(fileURLToPath(import.meta.url));
const read = (name) => readFile(path.join(directory, name), 'utf8');

test('桌面入口在 PATH 无 PowerShell 时仍调用系统解释器并保留失败退出码', { skip: process.platform !== 'win32' }, async () => {
  const root = await mkdtemp(path.join(os.tmpdir(), 'wenyou launcher '));
  const installed = path.join(root, 'WenyouSite', 'release');
  await mkdir(installed, { recursive: true });
  const cases = [
    ['Wenyou-Publish-Android.cmd', 'Publish-WenyouAndroid.ps1'],
    ['Wenyou-Release-Setup.cmd', 'Initialize-WenyouReleaseSsh.ps1'],
  ];
  try {
    for (const [launcher, script] of cases) {
      await writeFile(path.join(root, launcher), await read(launcher));
      // 仅运行临时标记脚本，绝不调用实际安装目录中的发布、SSH 或凭据逻辑。
      await writeFile(path.join(installed, script), 'Write-Output "WENYOU_LAUNCHER_FIXTURE"\nexit 23\n');
      const environment = { ...process.env };
      for (const key of Object.keys(environment)) {
        if (['path', 'localappdata'].includes(key.toLowerCase())) delete environment[key];
      }
      environment.PATH = '';
      environment.LOCALAPPDATA = root;
      const result = spawnSync(path.join(process.env.SystemRoot, 'System32', 'cmd.exe'), ['/d', '/c', launcher], {
        cwd: root, env: environment, encoding: 'utf8', input: '\n', timeout: 15000,
      });
      if (result.error) throw result.error;
      assert.equal(result.status, 23, `${launcher}: ${result.stdout}\n${result.stderr}`);
      assert.match(result.stdout, /WENYOU_LAUNCHER_FIXTURE/);
    }
  } finally {
    assert.ok(path.resolve(root).startsWith(path.resolve(os.tmpdir()) + path.sep));
    await rm(root, { recursive: true, force: true });
  }
});

test('正式 APK 校验拒绝其他 ABI、缺失引擎或字体以及重复条目', () => {
  execFileSync('pwsh', ['-NoProfile', '-File', path.join(directory, 'release_apk_fixtures.test.ps1')]);
});

test('仓库自动化入口统一使用 PowerShell 7', async () => {
  const packageJson = await readFile(
    path.resolve(directory, '../../package.json'),
    'utf8',
  );
  assert.match(packageJson, /"contract:sync": "pwsh /);
  assert.match(packageJson, /"check": "pwsh /);
  assert.match(packageJson, /"check:apk": "pwsh /);
  assert.match(packageJson, /"candidate:apk": "pwsh /);
  assert.doesNotMatch(packageJson, /powershell\.exe/i);
  assert.match(packageJson, /dart run build_runner build/);
  assert.doesNotMatch(packageJson, /build_runner clean/);
  const syncScript = await readFile(
    path.resolve(directory, '../sync_backend_contract.ps1'),
    'utf8',
  );
  assert.match(syncScript, /thread-category-v\[0-9\]\+-fixtures/);
  assert.doesNotMatch(syncScript, /thread-category-v1-fixtures/);
  const productionVerification = await readFile(
    path.resolve(directory, '../verify_production_api.dart'),
    'utf8',
  );
  assert.match(productionVerification, /openApiInfo\['version'\]/);
  assert.match(productionVerification, /bundle=\$expectedBundle/);
  assert.doesNotMatch(
    productionVerification,
    /expectedContract = metadata\['contractVersion'\]/,
  );
});

test('Windows 发布工具包含可重复安装的完整入口', async () => {
  const installer = await read('Install-WenyouReleaseTools.ps1');
  for (const name of [
    'WenyouRelease.Common.ps1',
    'Set-RainS3Credentials.ps1',
    'Initialize-WenyouReleaseSsh.ps1',
    'Invoke-WenyouAndroidRelease.ps1',
    'Publish-WenyouAndroid.ps1',
  ]) {
    assert.match(installer, new RegExp(name.replace('.', '\\.')));
  }
  assert.match(installer, /release-config\.json/);
  assert.match(installer, /IdentityFile \$ReleaseKeyPath/);
  assert.match(installer, /IdentitiesOnly yes/);
  assert.match(installer, /File\]::SetAccessControl\(\$ReleaseKeyPath/);
  assert.doesNotMatch(installer, /rains3-credentials\.json/);
});

test('RainS3 凭据只以 DPAPI 密文保存并收紧 ACL', async () => {
  const source = await read('Set-RainS3Credentials.ps1');
  assert.match(source, /Read-Host.+-AsSecureString/);
  assert.match(source, /ConvertFrom-SecureString/);
  assert.match(source, /SetAccessRuleProtection\(\$true, \$false\)/);
  assert.match(source, /RemoveAccessRuleAll/);
  assert.match(source, /File\]::SetAccessControl/);
  assert.doesNotMatch(source, /ConvertFrom-SecureString.+-Key/);
});

test('SSH 初始化必须比较 VPS 控制台指纹且禁止跳过主机校验', async () => {
  const source = await read('Initialize-WenyouReleaseSsh.ps1');
  assert.match(source, /ssh_host_ed25519_key\.pub/);
  assert.match(source, /Fingerprint mismatch/);
  assert.match(source, /known_hosts/);
  assert.doesNotMatch(source, /StrictHostKeyChecking=(?:no|accept-new)/i);
  assert.doesNotMatch(source, /UserKnownHostsFile=(?:NUL|\/dev\/null)/i);
});

test('一键发布读取 pubspec 并阻止脏或未推送仓库', async () => {
  const source = await read('Publish-WenyouAndroid.ps1');
  assert.match(source, /Get-WenyouPubspecVersion/);
  assert.match(source, /status --porcelain/);
  assert.match(source, /rev-parse '@\{u\}'/);
  assert.match(source, /Invoke-WenyouSshPreflight/);
  assert.match(source, /verify_production_api\.dart/);
  assert.match(source, /recommendedBuild.+-ge \$version\.Build/s);
  assert.match(source, /-Mode Publish/);
  assert.match(source, /mobileCompatibility\.android/);
});

test('正式发布在构建前运行唯一完整门禁', async () => {
  const source = await readFile(
    path.resolve(directory, '../release-mobile-from-local.sh'),
    'utf8',
  );
  assert.match(source, /npm run check/);
});

test('Android 发布同时检查 APK ZIP 与 ELF 的 16 KB 对齐', async () => {
  const source = await readFile(
    path.resolve(directory, '../release-mobile-from-local.sh'),
    'utf8',
  );
  assert.match(source, /zipalign.+-P 16 4/);
  assert.match(source, /verify_android_elf_page_alignment/);
  assert.match(source, /llvm-readelf/);
  assert.match(source, /load_alignment < 0x4000/);
});

test('发布包装器仅在进程环境解密凭据并始终清理', async () => {
  const source = await read('Invoke-WenyouAndroidRelease.ps1');
  assert.match(source, /Unprotect-DpapiString/);
  assert.match(source, /SetEnvironmentVariable\(\$accessVariable/);
  assert.match(source, /finally \{/);
  assert.match(source, /SetEnvironmentVariable\(\$secretVariable, \$previousSecret/);
  assert.doesNotMatch(source, /Write-(?:Host|Output).*(?:accessKeyPlaintext|secretKeyPlaintext)/i);
  const common = await read('WenyouRelease.Common.ps1');
  assert.ok(common.includes("-o 'SendEnv=-*'"));
});

test('运维文档覆盖安装、一键发布、密钥轮换和撤回', async () => {
  const operations = await readFile(
    path.resolve(directory, '../../contracts/mobile-release-operations.md'),
    'utf8',
  );
  assert.match(operations, /Install-WenyouReleaseTools\.ps1/);
  assert.match(operations, /Wenyou-Publish-Android\.cmd/);
  assert.match(operations, /DPAPI 密文/);
  assert.match(operations, /RainS3 密钥轮换顺序/);
  assert.match(operations, /wenyousite-promote-android --withdraw/);
});

test('桌面 SSH 预检不继承上传凭据，失败后仍恢复调用方环境', () => {
  const common = path.join(directory, 'WenyouRelease.Common.ps1').replaceAll("'", "''");
  execFileSync('pwsh', ['-NoProfile', '-Command', `
    $ErrorActionPreference = 'Stop'
    . '${common}'
    $env:WENYOU_RELEASE_S3_ACCESS_KEY_ID = 'fixture-key'
    $env:WENYOU_RELEASE_S3_SECRET_ACCESS_KEY = 'fixture-secret'
    function Test-FixtureSsh {
      if ($env:WENYOU_RELEASE_S3_ACCESS_KEY_ID -or $env:WENYOU_RELEASE_S3_SECRET_ACCESS_KEY) {
        $global:LASTEXITCODE = 71; return
      }
      if ($args -notcontains 'SendEnv=-*') { $global:LASTEXITCODE = 72; return }
      $global:LASTEXITCODE = 37
    }
    $result = Invoke-WenyouSshPreflight -SshPath Test-FixtureSsh -SshAlias fixture.invalid
    if ($result.ExitCode -ne 37) { throw 'SSH credential isolation failed' }
    if ($env:WENYOU_RELEASE_S3_ACCESS_KEY_ID -ne 'fixture-key' -or
        $env:WENYOU_RELEASE_S3_SECRET_ACCESS_KEY -ne 'fixture-secret' -or
        $ErrorActionPreference -ne 'Stop') { throw 'Caller environment was not restored' }
  `]);
});
