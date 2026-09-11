import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtemp, mkdir, readFile, writeFile, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

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
    for (const step of ['flutter analyze', 'dart run tool/check_architecture.dart', 'flutter test', 'npm run test:release-tool', 'flutter build apk --debug']) {
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
