import { EventEmitter } from 'node:events';
import { createInterface } from 'node:readline';

// Flutter machine 只向上暴露事件种类，丢弃 app.log 与 VM service URI。
export class FlutterMachine extends EventEmitter {
  #nextId = 0;
  #pending = new Map();
  #closed = false;
  constructor(child, { timeoutMs = 120_000 } = {}) {
    super();
    this.child = child;
    this.timeoutMs = timeoutMs;
    this.appId = null;
    this.ready = false;
    this.lines = createInterface({ input: child.stdout });
    this.lines.on('line', line => this.accept(line));
    child.stderr?.resume();
    child.on('error', () => this.close('Flutter 启动失败'));
    child.on('exit', () => this.close('Flutter 会话已退出'));
  }
  accept(line) {
    let messages;
    try { messages = JSON.parse(line); } catch { return; }
    if (!Array.isArray(messages)) return;
    for (const message of messages) {
      const pending = this.#pending.get(message.id);
      if (pending) {
        clearTimeout(pending.timer);
        this.#pending.delete(message.id);
        if (message.error) pending.reject(new Error('Flutter machine 请求失败；检查编译器与设备状态。'));
        else pending.resolve(message.result);
      }
      if (message.event === 'app.start') this.appId = message.params?.appId;
      if (message.event === 'app.started') { this.ready = true; this.emit('ready'); }
      if (message.event === 'app.stop') this.close('Flutter 应用已停止');
      if (message.event === 'app.progress') this.emit('progress', { id: message.params?.id, finished: message.params?.finished === true });
    }
  }
  request(method, params = {}) {
    if (this.#closed) return Promise.reject(new Error('Flutter 会话已断开'));
    const id = ++this.#nextId;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.#pending.delete(id);
        reject(new Error('Flutter machine 请求超时'));
      }, this.timeoutMs);
      this.#pending.set(id, { resolve, reject, timer });
      this.child.stdin.write(`${JSON.stringify([{ id, method, params }])}\n`, error => {
        if (!error) return;
        clearTimeout(timer);
        this.#pending.delete(id);
        reject(new Error('Flutter machine 输入已断开'));
      });
    });
  }
  async restart(fullRestart) {
    if (!this.ready || !this.appId) throw new Error('Flutter 尚未就绪');
    const result = await this.request('app.restart', { appId: this.appId, fullRestart, pause: false, reason: 'Wenyou visual feedback' });
    if (result?.code !== 0) throw new Error('热重载失败，当前画面仍对应上次成功源码。');
    return result;
  }
  stop() { return this.appId ? this.request('app.stop', { appId: this.appId }) : Promise.resolve(); }
  close(reason) {
    if (this.#closed) return;
    this.#closed = true;
    this.ready = false;
    for (const pending of this.#pending.values()) { clearTimeout(pending.timer); pending.reject(new Error(reason)); }
    this.#pending.clear();
    this.emit('closed', reason);
  }
}

export function serialQueue() {
  let tail = Promise.resolve();
  return operation => {
    const result = tail.then(operation);
    tail = result.catch(() => {});
    return result;
  };
}
