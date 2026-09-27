import test from 'node:test';
import assert from 'node:assert/strict';
import { EventEmitter } from 'node:events';
import { PassThrough } from 'node:stream';
import { FlutterMachine, serialQueue } from './machine.mjs';

function fixture(timeoutMs = 1000) {
  const child = Object.assign(new EventEmitter(), { stdout: new PassThrough(), stdin: new PassThrough(), stderr: new PassThrough() });
  const commands = [];
  child.stdin.on('data', line => commands.push(...JSON.parse(line.toString())));
  return { child, commands, machine: new FlutterMachine(child, { timeoutMs }) };
}
test('Flutter machine 匹配乱序并发 RPC，不把日志或 VM URI 输出', async () => {
  const { machine, commands } = fixture();
  const first = machine.request('one'); const second = machine.request('two');
  machine.accept('[{"event":"app.log","params":{"log":"secret"}}]');
  machine.accept('ordinary tool output');
  machine.accept(JSON.stringify([{ id: commands[1].id, result: 'second' }, { id: commands[0].id, result: 'first' }]));
  assert.deepEqual(await Promise.all([first, second]), ['first', 'second']);
  machine.close('done');
});
test('reload/restart 使用 app.restart fullRestart false/true 并拒绝失败 code', async () => {
  const { machine, commands } = fixture();
  machine.accept('[{"event":"app.start","params":{"appId":"app-1"}},{"event":"app.started"}]');
  const reload = machine.restart(false);
  assert.deepEqual(commands[0].params, { appId: 'app-1', fullRestart: false, pause: false, reason: 'Wenyou visual feedback' });
  machine.accept(JSON.stringify([{ id: commands[0].id, result: { code: 0 } }])); await reload;
  const restart = machine.restart(true);
  assert.equal(commands[1].params.fullRestart, true);
  machine.accept(JSON.stringify([{ id: commands[1].id, result: { code: 1, message: 'private compiler detail' } }]));
  await assert.rejects(restart, /热重载失败/); machine.close('done');
});
test('machine 失联拒绝在途请求与后续命令', async () => {
  const { machine, child } = fixture(); const pending = machine.request('one');
  child.emit('exit', 1);
  await assert.rejects(pending, /退出/);
  await assert.rejects(machine.request('two'), /断开/);
});
test('machine RPC 超时不被迟到响应误认成功', async () => {
  const { machine, commands } = fixture(10);
  await assert.rejects(machine.request('one'), /超时/);
  machine.accept(JSON.stringify([{ id: commands[0].id, result: { code: 0 } }]));
  machine.close('done');
});
test('控制命令串行运行，失败后仍允许 stop', async () => {
  const serial = serialQueue(); const order = [];
  const failed = serial(async () => { order.push('reload'); throw new Error('failed'); });
  const stop = serial(async () => order.push('stop'));
  await assert.rejects(failed); await stop;
  assert.deepEqual(order, ['reload', 'stop']);
});
