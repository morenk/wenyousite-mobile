import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtemp, mkdir, readFile, writeFile, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

test('正式发布 CI 自动复核 dev/main，保持 Windows 只读和原门禁入口', async () => {
  for (const file of ['quality.yml', 'android-debug.yml']) {
    const source = await readFile(fileURLToPath(new URL(`../../.github/workflows/${file}`, import.meta.url)), 'utf8');
    for (const event of ['push', 'pull_request']) {
      assert.match(source, new RegExp(`^  ${event}:\\r?\\n    branches: \\[dev, main\\]\\r?$`, 'm'));
    }
    assert.match(source, /^  workflow_dispatch:\s*$/m);
    assert.match(source, /^permissions:\r?\n  contents: read\r?\n\r?\nenv:/m);
    assert.match(source, /runs-on: windows-latest/);
    assert.match(source, /timeout-minutes: 60/);
    assert.match(source, /PUB_HOSTED_URL: https:\/\/pub\.flutter-io\.cn/);
    assert.match(source, /FLUTTER_STORAGE_BASE_URL: https:\/\/storage\.googleapis\.com/);
    const configure = source.indexOf('tool/ci/Set-WindowsDartUtf8.ps1');
    assert.ok(configure >= 0 && configure < source.indexOf('flutter pub get'));
    assert.doesNotMatch(source, /pull_request_target|upload-artifact|contents: write|id-token: write|--release/);
    assert.ok(source.includes(file === 'quality.yml' ? 'run: npm run check' : 'flutter build apk --debug --target-platform android-arm64'));
  }
});

test('CI 的 UTF-8 manifest 变更保留权限、兼容与既有窗口设置且可重复运行', () => {
  const script = fileURLToPath(new URL('../ci/Set-WindowsDartUtf8.ps1', import.meta.url));
  const result = spawnSync('pwsh', ['-NoProfile', '-Command', `
$ErrorActionPreference = 'Stop'
. '${script.replaceAll("'", "''")}'
[xml]$manifest = @'
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3"><security><requestedPrivileges><requestedExecutionLevel level="asInvoker" uiAccess="false" /></requestedPrivileges></security></trustInfo>
  <compatibility xmlns="urn:schemas-microsoft-com:compatibility.v1"><application><supportedOS Id="{8e0f7a12-bfb3-4fe8-b9a5-48fd50a15a9a}" /></application></compatibility>
  <application xmlns="urn:schemas-microsoft-com:asm.v3"><windowsSettings><longPathAware xmlns="http://schemas.microsoft.com/SMI/2016/WindowsSettings">true</longPathAware><activeCodePage xmlns="http://schemas.microsoft.com/SMI/2019/WindowsSettings">en-US</activeCodePage></windowsSettings></application>
</assembly>
'@
$preserved = @('trustInfo', 'compatibility', 'longPathAware')
$before = @{}
foreach ($name in $preserved) { $before[$name] = $manifest.SelectSingleNode("//*[local-name()='$name']").OuterXml }
[xml]$updated = ConvertTo-DartUtf8Manifest $manifest
foreach ($name in $preserved) {
  if ($before[$name] -cne $updated.SelectSingleNode("//*[local-name()='$name']").OuterXml) { throw "$name changed" }
}
$pages = $updated.SelectNodes('//*[local-name()="activeCodePage"]')
if ($pages.Count -ne 1 -or $pages[0].InnerText -ne 'UTF-8' -or $pages[0].NamespaceURI -ne 'http://schemas.microsoft.com/SMI/2019/WindowsSettings') { throw 'Invalid code page' }
if ((ConvertTo-DartUtf8Manifest $updated) -cne $updated.OuterXml) { throw 'Not idempotent' }
[xml]$minimal = '<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0" />'
[xml]$created = ConvertTo-DartUtf8Manifest $minimal
$settings = $created.SelectSingleNode('//*[local-name()="windowsSettings"]')
if ($settings.NamespaceURI -ne 'urn:schemas-microsoft-com:asm.v3' -or $settings.ParentNode.NamespaceURI -ne 'urn:schemas-microsoft-com:asm.v3') { throw 'Invalid application namespace' }
if ($created.SelectSingleNode('//*[local-name()="activeCodePage"]').InnerText -ne 'UTF-8') { throw 'Missing code page' }
`], { encoding: 'utf8', windowsHide: true });
  assert.equal(result.status, 0, result.stdout + result.stderr);
});

test('CI 编码脚本拒绝本机运行与 runner 工具缓存外的 SDK', () => {
  const script = fileURLToPath(new URL('../ci/Set-WindowsDartUtf8.ps1', import.meta.url));
  const base = { ...process.env, GITHUB_ACTIONS: '', RUNNER_OS: 'Windows' };
  const local = spawnSync('pwsh', ['-NoProfile', '-File', script], {
    encoding: 'utf8', windowsHide: true, env: base,
  });
  assert.notEqual(local.status, 0);
  assert.match(local.stderr, /restricted to GitHub Windows CI/);
  const outside = spawnSync('pwsh', ['-NoProfile', '-File', script], {
    encoding: 'utf8', windowsHide: true,
    env: {
      ...base, GITHUB_ACTIONS: 'true',
      RUNNER_TOOL_CACHE: path.join(os.tmpdir(), 'wenyou-runner-tools'),
      FLUTTER_ROOT: path.join(os.tmpdir(), 'wenyou-runner-tools-outside', 'flutter'),
    },
  });
  assert.notEqual(outside.status, 0);
  assert.match(outside.stderr, /outside the temporary runner tool cache/);
});

test('门禁默认立即失败；收集模式继续全部检查但仍返回失败', async () => {
  const fixture = await mkdtemp(path.join(os.tmpdir(), 'wenyou-quality-gate-'));
  try {
    await mkdir(path.join(fixture, 'tool'));
    await mkdir(path.join(fixture, 'packages', 'wenyou_api'), { recursive: true });
    const source = await readFile(fileURLToPath(new URL('../Check-WenyouMobile.ps1', import.meta.url)), 'utf8');
    const gate = path.join(fixture, 'tool', 'Check-WenyouMobile.ps1');
    await writeFile(gate, source);
    for (const command of ['dart', 'flutter', 'npm']) {
      await writeFile(path.join(fixture, `${command}.ps1`), `
Write-Host ('STUB ${command} ' + ($args -join ' '))
$global:LASTEXITCODE = 0
if ($env:WENYOU_GATE_TEST_FAIL -eq 'yes' -and $args -contains 'api:verify:production') {
  $global:LASTEXITCODE = 7
}
`);
    }
    const run = (options, fail) => spawnSync('pwsh', ['-NoProfile', '-File', gate, ...options], {
      encoding: 'utf8',
      env: { ...process.env, PATH: fixture + path.delimiter + process.env.PATH, WENYOU_GATE_TEST_FAIL: fail },
    });
    const stopped = run([], 'yes');
    assert.notEqual(stopped.status, 0, stopped.stdout + stopped.stderr);
    assert.match(stopped.stdout, /STUB npm run api:verify:production/);
    assert.doesNotMatch(stopped.stdout, /STUB flutter test/);
    const collected = run(['-ContinueAfterFailure', '-BuildDebugApk'], 'yes');
    assert.equal(collected.status, 1, collected.stdout + collected.stderr);
    for (const step of ['flutter analyze', 'dart run tool/check_architecture.dart', 'flutter test', 'npm run test:release-tool', 'flutter build apk --debug --target-platform android-arm64']) {
      assert.ok(collected.stdout.includes(`STUB ${step}`), collected.stdout);
    }
    assert.match(collected.stdout, /quality gate FAILED \(1 steps\)/);
    assert.doesNotMatch(collected.stdout, /quality gate passed/);
    const passed = run(['-ContinueAfterFailure'], 'no');
    assert.equal(passed.status, 0, passed.stdout + passed.stderr);
    assert.match(passed.stdout, /quality gate passed/);
    assert.match(passed.stdout, /STUB flutter test --concurrency=1/);
    const parallel = run(['-TestConcurrency', '2'], 'no');
    assert.equal(parallel.status, 0, parallel.stdout + parallel.stderr);
    assert.match(parallel.stdout, /STUB flutter test --concurrency=2/);
    const invalid = run(['-TestConcurrency', '0'], 'no');
    assert.notEqual(invalid.status, 0, invalid.stdout + invalid.stderr);
    assert.doesNotMatch(invalid.stdout, /STUB flutter test/);
  } finally {
    const resolved = path.resolve(fixture);
    assert.equal(path.dirname(resolved), path.resolve(os.tmpdir()));
    assert.ok(path.basename(resolved).startsWith('wenyou-quality-gate-'));
    await rm(resolved, { recursive: true, force: true });
  }
});
