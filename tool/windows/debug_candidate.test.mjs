import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { mkdtemp, mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const apkContents = 'debug apk fixture';

const runCandidate = (script, fixture, options = [], fail = '') => spawnSync(
  'pwsh',
  ['-NoProfile', '-File', script, ...options],
  {
    cwd: fixture,
    encoding: 'utf8',
    env: {
      ...process.env,
      PATH: fixture + path.delimiter + process.env.PATH,
      WENYOU_CANDIDATE_TEST_FAIL: fail,
    },
  },
);

test('快速候选只运行显式相关测试，并在成功后报告 APK 哈希', async () => {
  const fixture = await mkdtemp(path.join(os.tmpdir(), 'wenyou-debug-candidate-'));
  try {
    await mkdir(path.join(fixture, 'tool'));
    await mkdir(path.join(fixture, 'packages', 'wenyou_api'), { recursive: true });
    await mkdir(path.join(fixture, 'test', 'features', 'sample'), { recursive: true });
    await mkdir(path.join(fixture, 'test', 'core'), { recursive: true });
    await mkdir(path.join(fixture, 'integration_test'));
    await mkdir(path.join(fixture, 'test_driver'));
    await mkdir(path.join(fixture, 'lib'));
    const source = await readFile(
      fileURLToPath(new URL('../Build-WenyouDebugCandidate.ps1', import.meta.url)),
      'utf8',
    );
    const script = path.join(fixture, 'tool', 'Build-WenyouDebugCandidate.ps1');
    await writeFile(script, source);
    await writeFile(path.join(fixture, 'test', 'features', 'sample', 'sample_test.dart'), '');
    await writeFile(path.join(fixture, 'test', 'core', 'core_test.dart'), '');
    await writeFile(path.join(fixture, 'outside_test.dart'), '');
    await writeFile(path.join(fixture, 'test', 'not_a_test.dart.txt'), '');

    await writeFile(path.join(fixture, 'dart.ps1'), `
Write-Host ('STUB dart ' + ($args -join ' '))
if ($env:WENYOU_CANDIDATE_TEST_FAIL -eq 'dart-analyze' -and $args[0] -eq 'analyze') { exit 7 }
exit 0
`);
    await writeFile(path.join(fixture, 'flutter.ps1'), `
Write-Host ('STUB flutter ' + ($args -join ' '))
if ($env:WENYOU_CANDIDATE_TEST_FAIL -eq 'analyze' -and $args[0] -eq 'analyze') { exit 7 }
if ($env:WENYOU_CANDIDATE_TEST_FAIL -eq 'test' -and $args[0] -eq 'test') { exit 8 }
if ($args[0] -eq 'build') {
  $apk = Join-Path (Get-Location) 'build\\app\\outputs\\flutter-apk\\app-debug.apk'
  New-Item -ItemType Directory -Force -Path (Split-Path $apk) | Out-Null
  [IO.File]::WriteAllText($apk, '${apkContents}')
}
exit 0
`);

    for (const invalidOptions of [
      [],
      ['test'],
      ['missing_test.dart'],
      ['outside_test.dart'],
      ['test/not_a_test.dart.txt'],
    ]) {
      const invalid = runCandidate(script, fixture, invalidOptions);
      assert.notEqual(invalid.status, 0, invalid.stdout + invalid.stderr);
      assert.doesNotMatch(invalid.stdout, /STUB flutter build/);
    }

    const options = [
      'test/features/sample/sample_test.dart',
      'test/core',
      '-TestConcurrency',
      '2',
    ];
    const passed = runCandidate(script, fixture, options);
    assert.equal(passed.status, 0, passed.stdout + passed.stderr);
    assert.match(passed.stdout, /STUB dart format --output=none --set-exit-if-changed/);
    assert.match(passed.stdout, /STUB flutter analyze --fatal-infos --fatal-warnings/);
    assert.match(passed.stdout, /STUB dart analyze --fatal-infos --fatal-warnings/);
    const testLine = passed.stdout.split(/\r?\n/).find((line) => line.includes('STUB flutter test'));
    assert.ok(testLine, passed.stdout);
    assert.match(testLine, /--concurrency=2/);
    assert.match(testLine, /test[\\/]features[\\/]sample[\\/]sample_test\.dart/);
    assert.match(testLine, /test[\\/]core/);
    assert.doesNotMatch(testLine, /--concurrency=2\s+test\s/);
    assert.match(passed.stdout, /STUB flutter build apk --debug/);
    assert.match(passed.stdout, /build[\\/]app[\\/]outputs[\\/]flutter-apk[\\/]app-debug\.apk/);
    assert.match(passed.stdout, new RegExp(createHash('sha256').update(apkContents).digest('hex'), 'i'));

    const analyzeFailure = runCandidate(script, fixture, options, 'analyze');
    assert.notEqual(analyzeFailure.status, 0, analyzeFailure.stdout + analyzeFailure.stderr);
    assert.doesNotMatch(analyzeFailure.stdout, /STUB flutter test/);
    assert.doesNotMatch(analyzeFailure.stdout, /STUB flutter build/);

    const testFailure = runCandidate(script, fixture, options, 'test');
    assert.notEqual(testFailure.status, 0, testFailure.stdout + testFailure.stderr);
    assert.match(testFailure.stdout, /STUB flutter test/);
    assert.doesNotMatch(testFailure.stdout, /STUB flutter build/);
  } finally {
    const resolved = path.resolve(fixture);
    assert.equal(path.dirname(resolved), path.resolve(os.tmpdir()));
    assert.ok(path.basename(resolved).startsWith('wenyou-debug-candidate-'));
    await rm(resolved, { recursive: true, force: true });
  }
});
