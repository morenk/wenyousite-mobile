# 通知删除目标历史态候选验收

状态：候选修复／待负责人验收

## 原始问题与复现边界

负责人反馈：移动端对“通知所指对象已经被删除”的情况适配不完整，Web 已完成适配。

已知复现路径是打开消息中心，查看一条生成后目标内容被删除的通知，再点按该通知。负责人尚未提供具体通知 ID、对象类型、原始通知载荷或设备录屏，因此当前不能声称已经在原始数据上复现；本候选按已部署契约的真实形状 `target.kind=none`、`target.state=CONTENT_DELETED` 建立精确回归。期望与 Web 一致：列表直接说明目标已删除，不能进入失效页面，也不继续显示为未读或触发后台提醒。

## 已证实根因

移动端生成客户端已有必填 `target.state`，但仓储没有消费它，而是继续根据旧的 `target.kind` 和嵌套 DTO `deletedAt` 推断。服务端对失效目标会降为 `kind=none`，因此旧实现无法得到删除提示，也没有把状态作为导航前置条件。

Web 当前实现只允许 `ACTIVE` 导航，并按 `CONTENT_DELETED`、`USER_DEACTIVATED`、`NO_TARGET` 分别处理。移动端候选现已采用相同状态边界，同时保留适合移动端现有列表的历史态提示交互。

## 候选行为

- `ACTIVE`：按 post、thread、moment、user 的稳定坐标导航。
- `CONTENT_DELETED`：按残留坐标显示“该评论已删除”“该动态已删除”“该内容已删除”；没有可判定坐标时显示“该内容已删除或不可访问”。
- `USER_DEACTIVATED`：显示“该用户已注销”。
- `NO_TARGET`：按普通无目标系统通知展示，不显示删除提示。
- 未知状态：不根据残留坐标猜测导航。
- 删除和注销历史态按已读呈现；点按只显示同一历史态提示，不重复提交已读，不触发目标导航或后台系统提醒。

## 自动验证

开发反馈阶段已执行：

```text
flutter test test/features/notifications/notification_repository_test.dart
             test/features/notifications/notification_contract_test.dart
             test/features/notifications/notifications_page_test.dart
```

结果：24 项通过。回归覆盖旧实现失败的 `kind=none + CONTENT_DELETED` 映射，以及评论、动态、未知内容、注销用户、无目标、未知状态、页面提示、不导航和不重复标记已读。

候选验证在最新 `origin/dev` 合并基线 `536bc30652dd5d40eff9df90b2602e7c56f5e580` 上执行 `npm run check:apk`：OpenAPI 校验、固定契约来源、生成客户端一致性、公网兼容、格式、应用与生成客户端静态分析、架构、模块文档、API 覆盖均通过；Flutter 测试 4696 项通过、1 项 live Sentry 预期跳过，Windows 发布工具测试 18/18 通过，并成功构建 Debug APK。

候选 APK：

- 路径：`C:\Users\quhui\.codex\worktrees\notification-deleted-target\wenyousite-mobile\build\app\outputs\flutter-apk\app-debug.apk`
- 包名：`site.wenyou.app.debug`
- 大小：183514362 bytes（约 175.01 MiB）
- SHA-256：`EA5A24DCE62D56531BFD0B3EF42A3A690B1FD3CD07F7F9FE487602309C8199F6`
- 构建时间：2026-09-23 23:47:19 +08:00

## 负责人真机复验

负责人使用上述候选 APK、原账号和原通知复验：

1. 打开 Debug 应用 `site.wenyou.app.debug`，进入“消息 → 通知”。
2. 找到原先目标对象已经删除的通知，确认列表显示与对象类型匹配的历史态，且没有未读点。
3. 点按通知，确认只出现同样的历史态提示，不进入不存在页面。
4. 返回前台或等待一次后台检查，确认该历史通知不会再次产生系统顶部提醒。
5. 另点一条仍存在目标的通知，确认正常导航未受影响；普通无目标系统通知不显示“已删除”。

负责人明确确认原问题通过前，本记录保持“候选修复／待负责人验收”，不得标记修复完成。
