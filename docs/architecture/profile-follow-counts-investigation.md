# “我的”关系数量差异排查

状态：消费者回归候选，原问题待 Backend 修复及负责人复验。Mobile 应用源码未变，不生成新 APK。

## 原始现象与范围

2026-09-28 负责人反馈：底部“我的”顶部关注／粉丝数不能及时同步，下拉可见刷新转圈但数字仍旧，进入关系列表才能看到实际数量；补充怀疑与移除粉丝有关。实际截图中顶部为关注 `3`、粉丝 `13`，本人关系列表页签为关注 `2`、粉丝 `12`。本记录不包含账号名、账号 ID、Token 或原始用户列表。

Mobile 排查基线为 `origin/dev` 的 `f551d3eb92990a8dcf79760362c3bc1426d4d6c5`，契约固定 Backend `1d43b85f7aa8cd1ab03f6ab34f1851462e1a0021`／`5.27.0-dev.20260927.1`，Foundation 固定 `v7.2.1`。不修改依赖、契约、生成客户端或视觉规范。

## 已确认事实

- `MePage` 下拉同时刷新本人资料、钱包与当前内容；`MeProfileController.refresh` 重新读取 `usersGetMe`，资料头直接采用该响应的关注／粉丝数。
- 本人列表确认移除后，生产组合根失效本人资料及公开资料；迟到的旧资料读取不能覆盖重新加载的计数。
- 治理任务通过既有 VPS 管理入口，在只读角色与只读事务内进行匿名聚合核对，得到顶部计数 `3 / 13`、列表计数 `2 / 12`、已注销关注对象 `1`、已注销粉丝 `1`、已注销互关对象 `1`，与负责人截图一致。未执行业务写入。Backend 的资料统计与列表过滤已注销用户的口径差异由对应 Backend 任务修正。

目前未在 Mobile 的上述路径发现计数同步缺陷。客户端不追加无效刷新，不以列表长度覆盖资料响应来掩盖服务端计数差异。

## 消费者测试与证据边界

新增 `test/features/users/me_page_relation_counts_test.dart` 使用真实 `MePage`、下拉手势、粉丝管理菜单、确认框、返回路由及生产组合根；网络、会话存储和能力启动使用内存测试端口，不连接真实服务。

覆盖：

1. 从资料头下拉，新的资料响应由 `3 / 13` 更新为 `2 / 12`。
2. 从当前主题内容区下拉，采用相同的新计数。
3. 从“我的”进入粉丝管理，移除互关粉丝，仅将粉丝数 `1` 更新为 `0`，关注数仍为 `1`；返回后再下拉仍保持正确值。
4. 移除前发出的旧资料刷新晚于移除后新资料到达，顶部粉丝数不回退。

前两项中的 `3 / 13 → 2 / 12` 是根据截图数字构造的消费者输入，不能视为已抓取到的真实 HTTP 响应。上述测试在原应用实现上通过，属于消费者防退化证据；不存在 Mobile“旧实现失败、新实现通过”的修复证据，不将其冒充原问题已解决。

以下 7 个文件同次定向执行共 52 项通过（`flutter test --no-pub --concurrency=2`）：

- `test/features/users/me_page_relation_counts_test.dart`
- `test/features/users/me_profile_repository_test.dart`
- `test/features/users/me_profile_controller_test.dart`
- `test/features/users/me_profile_refresh_boundary_test.dart`
- `test/features/social/own_relation_lists_controller_test.dart`
- `test/features/social/own_relation_lists_page_test.dart`
- `test/app/production_overrides_test.dart`

全仓 Dart 格式检查 1129 文件无变化，应用与生成客户端全量静态分析零问题，21 个模块文档检查通过。应用、Android/iOS、生成包、依赖与契约相对上述基线的 `git diff --exit-code` 为空。

没有启动 App、安装 APK、执行线上登录或线上写入 E2E；未重跑全量 Flutter 测试，也不等待已停用的 GitHub CI。测试搭建时曾出现缺少会话账号声明而走只读列表，以及启动能力夹具漏填必填字段的失败；均只涉及新增测试夹具，修正后的最终定向执行完整通过，不是原问题的 Mobile 失败复现。

## 负责人复验

待 Backend 候选完成其检查并按独立授权上线后，负责人使用现有应用进入“我的”，下拉应看到与本人关系列表一致的数量。进入列表再返回，数字不应回到旧值。原问题必须由负责人明确复验通过，本记录及自动测试均不代替该结果。自动化移除／关注写入只允许在本轮核验过的隔离环境进行。
