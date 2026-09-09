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
    ]) {
      assert.deepEqual(
        fs.readFileSync(path.join(mobile, 'contracts', name)),
        fs.readFileSync(path.join(backend, 'contracts', name)),
        `共享行为契约必须逐字同步：${name}`,
      );
    }
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
