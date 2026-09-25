import test from 'node:test';
import assert from 'node:assert/strict';
import http from 'node:http';
import { inspectSessionHealth, applyAvailability } from './health.mjs';

test('真实连接超时后恢复，不改变 Flutter、包安装或最后成功源码证据', async t => {
  let available = false;
  const server = http.createServer((_, response) => {
    if (!available) { setTimeout(() => { response.writeHead(503); response.end(); }, 300); return; }
    response.writeHead(200); response.end('ready');
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(() => { server.closeAllConnections(); server.close(); });
  const state = { status: 'ready', flutterAppId: 'same-app', installedApp: { appPid: '100', lastUpdateTime: 'same-install' }, loadedSource: { sourceDigest: 'same-source' } };
  const retained = structuredClone(state);
  const dependencies = {
    verifyDevice() {}, verifyOwnedTunnel() {},
    async verifyEnvironment() { const response = await fetch(`http://127.0.0.1:${server.address().port}`, { signal: AbortSignal.timeout(available ? 2000 : 30) }); if (response.status !== 200) throw new Error('unavailable'); },
  };
  assert.equal(await inspectSessionHealth(dependencies), 'unavailable');
  assert.equal(applyAvailability(state, false, true), true);
  assert.equal(state.status, 'unavailable');
  assert.deepEqual(state.installedApp, retained.installedApp); assert.deepEqual(state.loadedSource, retained.loadedSource); assert.equal(state.flutterAppId, retained.flutterAppId);
  available = true;
  assert.equal(await inspectSessionHealth(dependencies), 'available');
  applyAvailability(state, true, true);
  assert.deepEqual(state, { ...retained, failure: undefined });
});
test('设备或自有SSH失联标记disconnected，不尝试用错误环境恢复', async () => {
  for (const fail of ['verifyDevice', 'verifyOwnedTunnel']) {
    let probed = false;
    const dependencies = { verifyDevice() {}, verifyOwnedTunnel() {}, verifyEnvironment() { probed = true; } };
    dependencies[fail] = () => { throw new Error('gone'); };
    assert.equal(await inspectSessionHealth(dependencies), 'disconnected'); assert.equal(probed, false);
  }
});
