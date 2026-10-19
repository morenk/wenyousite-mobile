import test from 'node:test';
import assert from 'node:assert/strict';
import { debugArguments } from './run.mjs';

test('普通 Debug 参数直接传给 Flutter，不需要 consumer 或后台控制器', () => {
  const args = ['-d', 'device-id', '--dart-define=API_BASE_URL=https://dev.example.test/api/v1'];
  assert.deepEqual(debugArguments(args), ['run', '--debug', ...args]);
  assert.deepEqual(debugArguments([]), ['run', '--debug']);
});

test('SDK 与设备操作前拒绝卸载、非 Debug 模式和旧预览配置', () => {
  for (const argument of ['--uninstall-first', '--release', '--profile', '--release=true', '--dart-define=WENYOU_PREVIEW_RUN=old']) {
    assert.throws(() => debugArguments([argument]), /普通 Debug/);
  }
});
