import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const directory = path.dirname(fileURLToPath(import.meta.url));
const read = (name) => readFile(path.join(directory, name), 'utf8');

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
  assert.match(source, /-Mode Publish/);
  assert.match(source, /mobileCompatibility\.android/);
});

test('发布包装器仅在进程环境解密凭据并始终清理', async () => {
  const source = await read('Invoke-WenyouAndroidRelease.ps1');
  assert.match(source, /Unprotect-DpapiString/);
  assert.match(source, /SetEnvironmentVariable\(\$accessVariable/);
  assert.match(source, /finally \{/);
  assert.match(source, /SetEnvironmentVariable\(\$secretVariable, \$previousSecret/);
  assert.doesNotMatch(source, /Write-(?:Host|Output).*(?:accessKeyPlaintext|secretKeyPlaintext)/i);
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
