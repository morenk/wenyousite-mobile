import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const repository = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');

test('固定部署祖先导出同一 SHA，拒绝远端 dev 以外提交且不改已有契约', () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'wenyou-contract-revision-'));
  const backend = path.join(root, 'backend');
  const mobile = path.join(root, 'mobile');
  const git = (...args) => execFileSync('git', ['-C', backend, ...args], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
  try {
    fs.mkdirSync(backend);
    fs.mkdirSync(path.join(backend, 'docs'));
    fs.cpSync(path.join(repository, 'contracts'), path.join(backend, 'contracts'), { recursive: true });
    const changelog = path.join(backend, 'contracts/CHANGELOG.md');
    fs.writeFileSync(changelog, '# API 合同变更\n\n## 编辑器测试语料更新\n\n' + fs.readFileSync(changelog, 'utf8'));
    fs.copyFileSync(path.join(repository, 'contracts/mobile-client-guide.md'), path.join(backend, 'docs/mobile-client-guide.md'));
    fs.copyFileSync(path.join(repository, 'contracts/media-display.md'), path.join(backend, 'docs/media-display.md'));
    git('init', '-b', 'dev');
    git('config', 'user.name', 'Contract fixture');
    git('config', 'user.email', 'fixture@example.invalid');
    git('add', '.');
    git('commit', '-m', 'deployed contract');
    const deployed = git('rev-parse', 'HEAD');
    fs.writeFileSync(path.join(backend, 'docs/handoff.md'), 'documentation only');
    git('add', '.');
    git('commit', '-m', 'unreleased documentation');
    const branchHead = git('rev-parse', 'HEAD');
    git('remote', 'add', 'origin', backend);
    fs.mkdirSync(path.join(mobile, 'tool'), { recursive: true });
    fs.mkdirSync(path.join(mobile, 'contracts'), { recursive: true });
    const listSource = JSON.parse(fs.readFileSync(path.join(repository, 'contracts/markdown-editor-list-v1-source.json'), 'utf8'));
    listSource.backendRevision = deployed;
    const sourceManifestPath = path.join(mobile, 'contracts/markdown-editor-list-v1-source.json');
    fs.writeFileSync(sourceManifestPath, JSON.stringify(listSource));
    for (const name of ['sync_backend_contract.ps1', 'normalize_synced_contract.dart']) {
      fs.copyFileSync(path.join(repository, 'tool', name), path.join(mobile, 'tool', name));
    }
    const run = (revision) => spawnSync('pwsh', ['-NoProfile', '-File', path.join(mobile, 'tool/sync_backend_contract.ps1'), '-BackendPath', backend, '-Revision', revision], { cwd: mobile, encoding: 'utf8', timeout: 120000 });
    const synced = run(deployed);
    assert.equal(synced.status, 0, synced.stderr + synced.stdout);
    const metadataPath = path.join(mobile, 'contracts/backend-contract.properties');
    const metadata = fs.readFileSync(metadataPath, 'utf8');
    assert.match(metadata, new RegExp(`backendRevision=${deployed}`));
    const apiVersion = JSON.parse(fs.readFileSync(path.join(backend, 'contracts/openapi.json'), 'utf8')).info.version;
    assert.ok(metadata.split('\n').includes(`contractVersion=${apiVersion}`));
    assert.doesNotMatch(metadata, new RegExp(branchHead));
    assert.equal(fs.readFileSync(path.join(mobile, 'contracts/CHANGELOG.md'), 'utf8'), git('show', `${deployed}:contracts/CHANGELOG.md`) + '\n');
    for (const name of [
      'rich-text-behavior-v1-fixtures.json',
      'rich-text-behavior-v1.schema.json',
      'rich-text-behavior-results-v1.schema.json',
      'media-display-v1-fixtures.json',
      'fixtures/media-display/duplicate-frames.gif',
      'fixtures/media-display/duplicate-frames.webp',
      'fixtures/media-display/manifest.json',
    ]) {
      assert.deepEqual(
        fs.readFileSync(path.join(mobile, 'contracts', name)),
        fs.readFileSync(path.join(backend, 'contracts', name)),
        `共享行为契约必须逐字同步：${name}`,
      );
    }
    assert.deepEqual(
      fs.readFileSync(path.join(mobile, 'contracts/markdown-editor-list-v1-fixtures.json')),
      fs.readFileSync(path.join(backend, 'contracts/markdown-editor-list-v1-fixtures.json')),
    );
    const listBytes = fs.readFileSync(path.join(mobile, 'contracts/markdown-editor-list-v1-fixtures.json'));
    const verifyScript = path.join(mobile, 'verify-local.ps1');
    fs.writeFileSync(verifyScript, 'param([string]$Packages,[string]$ScriptPath)\n& dart "--packages=$Packages" $ScriptPath\nexit $LASTEXITCODE\n');
    const verifyLocal = () => spawnSync('pwsh', [
      '-NoProfile', '-File', verifyScript,
      '-Packages', path.join(repository, '.dart_tool/package_config.json'),
      '-ScriptPath', path.join(repository, 'tool/check_contract_sources.dart'),
    ], { cwd: mobile, encoding: 'utf8', timeout: 120000 });
    const validLocal = verifyLocal();
    assert.equal(validLocal.status, 0, validLocal.stderr + validLocal.stdout);
    fs.writeFileSync(path.join(mobile, 'contracts/markdown-editor-list-v1-fixtures.json'), Buffer.concat([listBytes, Buffer.from(' ')]));
    const tamperedLocal = verifyLocal();
    assert.notEqual(tamperedLocal.status, 0);
    assert.match(tamperedLocal.stderr + tamperedLocal.stdout, /SHA-256/);
    fs.writeFileSync(path.join(mobile, 'contracts/markdown-editor-list-v1-fixtures.json'), listBytes);
    const syncedAgain = run(deployed);
    assert.equal(syncedAgain.status, 0, syncedAgain.stderr + syncedAgain.stdout);
    assert.deepEqual(fs.readFileSync(path.join(mobile, 'contracts/markdown-editor-list-v1-fixtures.json')), listBytes);
    fs.writeFileSync(sourceManifestPath, JSON.stringify({ ...listSource, sha256: '0'.repeat(64) }));
    const wrongHash = run(deployed);
    assert.notEqual(wrongHash.status, 0);
    assert.match(wrongHash.stderr + wrongHash.stdout, /SHA-256 mismatch/);
    assert.deepEqual(fs.readFileSync(path.join(mobile, 'contracts/markdown-editor-list-v1-fixtures.json')), listBytes);
    fs.writeFileSync(sourceManifestPath, JSON.stringify({ ...listSource, backendRevision: '0'.repeat(40) }));
    assert.notEqual(run(deployed).status, 0);
    fs.writeFileSync(sourceManifestPath, JSON.stringify(listSource));
    git('checkout', '-b', 'unpublished');
    fs.writeFileSync(path.join(backend, 'docs/private-branch.md'), 'unpublished');
    git('add', '.');
    git('commit', '-m', 'outside remote dev ancestry');
    const rejected = run(git('rev-parse', 'HEAD'));
    assert.notEqual(rejected.status, 0);
    assert.match(rejected.stderr + rejected.stdout, /must be an ancestor/);
    assert.equal(fs.readFileSync(metadataPath, 'utf8'), metadata);
    assert.notEqual(run('0'.repeat(40)).status, 0);
    assert.equal(git('branch', '--show-current'), 'unpublished');
  } finally {
    assert.equal(path.dirname(root), path.resolve(os.tmpdir()));
    assert.ok(path.basename(root).startsWith('wenyou-contract-revision-'));
    fs.rmSync(root, { recursive: true, force: true });
  }
});
