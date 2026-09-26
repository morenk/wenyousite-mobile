import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import { parseReleaseNotesPreflight } from '../release_notes_preflight.mjs';

const repository = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const result = { schemaVersion: 1, platform: 'android', versionName: '0.9.0', buildNumber: 100, confirmedRevision: 3 };

test('只接受精确身份和整数确认revision，不回显远程内容', () => {
  assert.equal(parseReleaseNotesPreflight(JSON.stringify(result), '0.9.0', 100), 3);
  for (const changed of [null, [], {}, { ...result, schemaVersion: 2 },
    { ...result, platform: 'ios' }, { ...result, versionName: '0.9.1' },
    { ...result, buildNumber: 101 }, { ...result, buildNumber: '100' },
    ...[0, -1, 1.5, '3', 2147483647].map(confirmedRevision => ({ ...result, confirmedRevision })),
  ]) {
    assert.throws(() => parseReleaseNotesPreflight(JSON.stringify(changed), '0.9.0', 100));
  }
  assert.throws(() => parseReleaseNotesPreflight('private-remote-output', '0.9.0', 100), error =>
    !error.message.includes('private-remote-output'));
});

function fixture({ mode = '', first = result, second = result, sshFailure = false, promoteFailure = false, stubBuild = true, skipChecks = true } = {}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-release-notes-'));
  const tool = path.join(root, 'tool');
  const bin = path.join(root, 'bin');
  const log = path.join(root, 'calls.log');
  fs.mkdirSync(tool);
  fs.mkdirSync(bin);
  fs.writeFileSync(path.join(root, 'pubspec.yaml'), 'name: fixture\nversion: 0.9.0+100\n');
  fs.writeFileSync(path.join(root, 'first.json'), JSON.stringify(first));
  fs.writeFileSync(path.join(root, 'second.json'), JSON.stringify(second));
  fs.copyFileSync(path.join(repository, 'tool/release_notes_preflight.mjs'), path.join(tool, 'release_notes_preflight.mjs'));
  let source = fs.readFileSync(path.join(repository, 'tool/release-mobile-from-local.sh'), 'utf8');
  if (stubBuild) {
    // 只替换耗时的构建/签名实现；执行真实参数解析、预检和晋级编排。
    const start = source.indexOf('build_android() {');
    const end = source.indexOf('\npublish_android() {', start);
    assert.ok(start > 0 && end > start);
    source = source.slice(0, start) + `build_android() {
      echo build >> "$FIXTURE_LOG"
      ANDROID_RELEASE_APK="$PROJECT_DIR/fixture.apk"
      ANDROID_RELEASE_SHA256="$PROJECT_DIR/fixture.sha256"
      ANDROID_RELEASE_MANIFEST="$PROJECT_DIR/fixture.json"
    }
` + source.slice(end);
  }
  fs.writeFileSync(path.join(tool, 'release.sh'), source);
  fs.writeFileSync(path.join(tool, 'upload_android_release.mjs'), `import fs from 'node:fs';
    fs.appendFileSync(process.env.FIXTURE_LOG, 'upload\\n');
    console.log(JSON.stringify({url:'https://example.invalid/fixture.apk',size:12,sha256:'${'a'.repeat(64)}'}));`);
  fs.writeFileSync(path.join(bin, 'npm'), '#!/usr/bin/env bash\necho npm >> "$FIXTURE_LOG"\n');
  fs.writeFileSync(path.join(bin, 'flutter'), '#!/usr/bin/env bash\necho flutter >> "$FIXTURE_LOG"\nexit 88\n');
  fs.writeFileSync(path.join(bin, 'ssh'), `#!/usr/bin/env bash
    echo "ssh $*" >> "$FIXTURE_LOG"
    if [[ "$*" == *--preflight* ]]; then
      ${sshFailure ? 'exit 37' : ''}
      if [ -f "$FIXTURE_ROOT/called" ]; then cat "$FIXTURE_ROOT/second.json"; else
        touch "$FIXTURE_ROOT/called"; cat "$FIXTURE_ROOT/first.json"; fi
    elif [[ "$*" != *--notes-revision* ]]; then exit 49;
    else ${promoteFailure ? 'exit 38' : 'exit 0'}; fi
  `);
  fs.writeFileSync(path.join(root, 'run.sh'), '#!/usr/bin/env bash\nexport PATH="$(cygpath -u "$FIXTURE_ROOT")/bin:$PATH"\nexec bash "$FIXTURE_ROOT/tool/release.sh" "$@"\n');
  try {
    const args = [path.join(root, 'run.sh'), '--version', '0.9.0', '--build', '100', '--platform', 'android'];
    if (skipChecks) args.push('--skip-checks');
    if (mode) args.push(mode);
    const gitExecPath = execFileSync('git', ['--exec-path'], { encoding: 'utf8' }).trim();
    const bashPath = path.resolve(gitExecPath, '../../../bin/bash.exe');
    const run = spawnSync(bashPath, args, {
      cwd: root, encoding: 'utf8', timeout: 30000,
      env: { ...process.env, FIXTURE_ROOT: root.replaceAll('\\', '/'), FIXTURE_LOG: log.replaceAll('\\', '/'), WENYOU_RELEASE_SSH_TARGET: 'fixture.invalid', ANDROID_SDK_ROOT: root },
    });
    if (run.error) throw run.error;
    return { ...run, calls: fs.existsSync(log) ? fs.readFileSync(log, 'utf8') : '' };
  } finally {
    assert.ok(path.resolve(root).startsWith(path.resolve(os.tmpdir()) + path.sep));
    fs.rmSync(root, { recursive: true, force: true });
  }
}

test('直接shell入口预检失败在构建/上传前停止，skip-checks不能绕过', { skip: process.platform !== 'win32' }, () => {
  for (const skipChecks of [false, true]) {
    for (const configuration of [{ sshFailure: true }, { first: { ...result, versionName: 'wrong' } }, { first: {} }]) {
      const run = fixture({ ...configuration, stubBuild: false, skipChecks });
      assert.notEqual(run.status, 0, run.stdout + run.stderr);
      assert.match(run.calls, /--preflight --version 0.9.0 --build 100/, run.stdout + run.stderr);
      assert.doesNotMatch(run.calls, /flutter|upload|npm|--recover/);
    }
  }
});

test('build-only与upload-only不联系预检或晋级', { skip: process.platform !== 'win32' }, () => {
  const build = fixture({ mode: '--build-only' });
  assert.equal(build.status, 0, build.stdout + build.stderr);
  assert.equal(build.calls, 'build\n');
  const upload = fixture({ mode: '--upload-only' });
  assert.equal(upload.status, 0, upload.stdout + upload.stderr);
  assert.match(upload.calls, /upload/);
  assert.doesNotMatch(upload.calls, /ssh|--notes-revision/);
});

test('晋级前复核revision，变化停止，成功携带同一revision', { skip: process.platform !== 'win32' }, () => {
  const changed = fixture({ second: { ...result, confirmedRevision: 4 } });
  assert.notEqual(changed.status, 0, changed.stdout + changed.stderr);
  assert.match(changed.calls, /upload/);
  assert.equal((changed.calls.match(/--preflight/g) ?? []).length, 2);
  assert.doesNotMatch(changed.calls, /--notes-revision/);
  const success = fixture();
  assert.equal(success.status, 0, success.stdout + success.stderr);
  assert.ok(success.calls.indexOf('--preflight') < success.calls.indexOf('build\n'));
  assert.equal((success.calls.match(/--preflight/g) ?? []).length, 2);
  assert.match(success.calls, /--notes-revision 3/);
});

test('晋级失败保留非零结果且不自动执行恢复', { skip: process.platform !== 'win32' }, () => {
  const failed = fixture({ promoteFailure: true });
  assert.notEqual(failed.status, 0);
  assert.match(failed.calls, /--notes-revision 3/);
  assert.doesNotMatch(failed.calls, /--recover/);
});
