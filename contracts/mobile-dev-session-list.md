# Mobile 开发会话只读登记协议 v1

治理入口从已经提交的 Mobile Worktree 执行 `node tool/dev/list.mjs --json`（等价于 `npm run dev:list -- --json`）。直接执行 Node 时 stdout 是一个 JSON 对象；npm 自身可能输出命令前缀。命令只支持 Windows，不要求当前分支为任务分支，不启动 Flutter、ADB、SDK 或 SSH，不停止、恢复、清理任何会话，也不修改登记。

登记根目录固定为当前用户的 `%LOCALAPPDATA%\Wenyou\live-debug`。不存在时返回空数组；无法读取根目录或归属信息时必须 fail closed。治理不得根据另一个用户或指定的临时空目录判断可以切换。

输出结构：

```json
{
  "version": 1,
  "kind": "wenyou-mobile-dev-sessions",
  "blocked": false,
  "sessions": [
    {
      "state": "ready",
      "task": "codex/20260926-example",
      "worktree": "d:\\code\\example",
      "sessionId": "example-preview",
      "runId": "preview_aaaaaaaaaaaaaaaaaaaaaaaa",
      "device": "device-serial",
      "borrowedTunnel": true,
      "active": true,
      "blocked": false,
      "reason": "active"
    }
  ]
}
```

- `state` 是控制器登记的状态；不明状态为 `unknown`。无法核实的 `task/worktree/sessionId/runId/device/borrowedTunnel` 为 `null`。
- `active` 表示控制器 PID 和进程开始时间相符；即使登记声称 stopped，只要原控制器仍存活也不能认为已经释放。
- `blocked` 表示无法证明登记安全，例如损坏状态、PID 复用、缺失或不匹配的设备锁、无法通过带控制 token 的 status 核验、存活子进程、遗留 reverse 或孤立设备锁。根级 `blocked` 是任一条目 blocked 的汇总。
- 活动控制器必须经 loopback `/control` 的 authenticated status 核验任务、Worktree、设备、sessionId 和 runId；控制 token、controlPort、descriptorFile、ADB 路径、私有登记和原始错误永不输出。
- 治理在暂停、断开共享隧道或切换批次前，必须拒绝相关 `active || blocked` 条目。无法识别 runId 的 blocked 条目对所有切换生效。提示在返回的原 Worktree 执行 `npm run dev:status` / `npm run dev:stop`；不要代替另一任务停止设备会话。
- 列表只是瞬时核验，不是授权或排他租约。治理需要串行自己的切换操作，切换前后重查；并发 Mobile start 的客户端仍由每请求 runId 门禁阻止写入其他批次。不得以一次旧列表长期授权切换。

干净停止的历史登记仍列出为 `active: false, blocked: false`。遗留状态只能通过所属任务的正常 stop 恢复；列表不删除文件，也不将失联自动视为停止成功。消费方遇非零退出、无效 JSON 或未知协议版本也必须停止切换。
