# 私密邀请与主题设置候选验收

状态：负责人已在查看本轮视觉候选后明确授权合并与清理，视觉反馈批次收敛；原问题的真机复验仍未执行，不能将合并授权记作实机验收。稳定应用源码已执行最终完整门禁：退出1，唯一失败为生产契约版本尚未交付；其余检查与新APK构建通过。合并与清理由治理任务统一执行，本记录不代表部署或正式发布。

## 本轮范围与版本

- 沿用 `codex/20261001-private-invite-reuse`、`D:/codex-worktrees/mobile-invite-reuse/wenyousite-mobile` 和 [Mobile PR #80](https://github.com/morenk/wenyousite-mobile/pull/80)，没有新建同目标 Worktree。
- 本轮独立文档来源 chore 为 `50c962919c968341ad1110afba2a6d2b9cbfc5fd`，界面、回归和本文随后作为同一个业务提交交付；最终业务 SHA 由 PR #80 头及归档 `final-delivery.json` 固定。最终门禁启动时 HEAD 为50c，应用修改尚未提交，由下述 sourceDigest 绑定；上一界面 `30b4cb215f0bb03d33718a78183736ea6c3c6c33` 仅作为红绿回归基线。
- 官方同步固定 Backend 文档源 `4db0cdf2c079fc8b66545c67849053cd74945f8a`，API 仍为 `5.29.0-dev.20261001.1`。OpenAPI、DTO、生成客户端逐字不变，`api:check` 重新生成无漂移；固定来源与模块文档检查通过。[Backend PR #38](https://github.com/morenk/wenyousite-backend/pull/38)。
- Foundation fetch 后最新正式 Tag 仍为 v7.2.1，依赖保持锁定。本轮 [Foundation PR #28](https://github.com/morenk/wenyousite-foundation/pull/28) 的 `c7af81120c147f19f0c88d3fe491a703f9f6a87d` 仅共享交互文档，不增加 Token、组件 API 或包版本。
- 最终门禁与APK对应的应用 `sourceEvidence` 摘要为 `4a10c8d899528484eeeffe7c8692fd31a0ea47994522de9b4dedff9e65eea055`；检查启动时包含未提交应用修改，之后提交不改变该源码内容。本轮画面不能用上轮 APK 哈希表示。

最终门禁开始前已 fetch：`origin/dev=84d0a0d80eb60dc07503c6a5ed7bf5eb5b4f74f3`。`git rev-list --left-right --count origin/dev...HEAD` 为 `0 3`（behind 0 / ahead 3），merge-base 与 origin/dev 完全相同，祖先核验退出0；本轮没有遗漏上游提交。

## 当前候选行为

主题设置按标题、分区、标签、招募状态／可见范围／主贴发言权限、复制邀请／导出、删除排列。名称与操作共用左起点、普通字重，当前值和尾图标右对齐；行最小56dp并支持大字增高，区域间16dp留白，无卡片、分组标题和常驻说明。删除文字与图标均为危险色，原二次确认保留。修改仅作用于主题设置。

全部标签在标题下占满宽度 Wrap，长标签可内部换行，无省略或隐藏数量；整个区域打开同一个编辑 Sheet，不跳标签页。空态只显示“添加标签”。编辑复用 WenyouTagChip 和数量，保留5标签限额、原字符／重复校验、移除、取消／完成和聚合自动保存。

“复制邀请链接”现在直接位于设置页，尾部是复制图标，不开邀请抽屉。点击后先等待自动保存收敛，再复核已保存的楼主、已发布、私密状态；保存失败不取链。每次通过 PUT 获取当前链接，不轮换 token，不回退 POST。正常成功只给短提示，不显示链接正文；唯剪贴板失败在行下保留可选、完整换行的 URL 和手动复制说明。局部 spinner 与操作锁覆盖保存、取链和剪贴板；切号、离页、路由覆盖、目标或权限变化会清理失败链接并拒绝迟到结果。

重置 UI、确认与专属 controller 状态已移除。后端 POST、原 operationId、生成 SDK 和 repository 的禁止重放策略保留兼容，本轮不删除协议或改变成员权限。旧链接与成员权限的区别仍沿用 Backend 规则。

## 检查与回归

- 首批五文件共72项通过：`thread_invitation_controls_test.dart`、`thread_invitation_controller_test.dart`、`thread_management_invite_copy_test.dart`、`thread_management_flat_layout_test.dart`、`thread_management_page_test.dart`。覆盖一次点击先保存后复制、保存失败与保存后权限变化不取链、重复操作、剪贴板失败、账号／销毁／权限／目标／路由边界、完整标签、危险色与明暗大字布局。
- 相关五文件共35项通过：`thread_invitation_repository_test.dart`、`thread_invitation_page_test.dart`、`thread_management_controller_test.dart`、`thread_management_autosave_test.dart`、`thread_management_repository_test.dart`。
- `flutter analyze --fatal-infos --fatal-warnings` 全量应用分析通过，No issues found（64.7s）。之后只补充测试和文档，应用源码未改；新增测试另作静态分析。
- 行为红绿证明使用 `thread_management_invite_copy_test.dart` 的“主题设置直接显示复制邀请行且没有私密邀请抽屉入口”。将本工作区四个应用文件暂时还原为已提交 `30b4cb21` 后，测试成功编译并运行，因期望1个“复制邀请链接”、实际0个而退出1。当前文件预先逐字备份，finally还原并逐文件核验 SHA-256，应用摘要恢复一致；没有新建 Worktree，也没有把编译失败算作红灯。当前候选的同一断言通过。
- 标签真实输入／点击回归额外覆盖移除按钮、重复拒绝、达到5个后禁用继续添加，以及完成后仅保存剩余标签；取消／完成已有回归保留。
- 首轮红灯包括旧测试未模拟剪贴板、组件类型断言未适配，以及权限样本意外回写旧标题／可见范围导致自动保存不收敛。均保留日志、修正后定向复核；没有为通过测试放宽生产门禁。

日志保留在本 Worktree：`.buildlog-settings-candidate-fixed.log`、`.buildlog-settings-related.log`、`.buildlog-settings-analyze.log`、`.buildlog-settings-red.log`、`.buildlog-settings-red-to-green.log`、`.buildlog-settings-tag-validation.log`。候选的脱敏 JSON、检查哈希和 PNG 副本位于治理 `artifacts/settings-simplification-20261001/mobile/`。

## 最终门禁与本轮 APK

- OpenAPI、固定来源、官方重新生成无漂移、全仓格式、应用与生成客户端分析、架构、21模块文档、162/162移动端范围API覆盖通过。
- Flutter完整测试 **5041 passed / 1 skipped / 0 failed**（26分钟）；唯一跳过为既有Sentry外部接收验收。Windows工具 **67/67**，无跳过或失败。
- 生产只读核验失败：期望API/bundle `5.29.0-dev.20261001.1`、build `4db0cdf2c079fc8b66545c67849053cd74945f8a`；实际API `5.28.0-dev.20260929.1`、build `21acf512285f2a21aaa831f960211780de73aafc`。Markdown实际5处于支持的3/4/5内。本轮不放宽版本或SHA比较。
- ARM64 Debug构建成功（assembleDebug 222.7s）。APK为 `build/app/outputs/flutter-apk/app-debug.apk`，`site.wenyou.app.debug`／`0.8.0-debug`／97，109445894字节，SHA-256 `6ced1611cbbfc7f7e16b4a20ae889b190d901ee3c22d8b2bf691dcc0eba1c295`。标准包仍使用公网API，新PUT未部署前仅作构建证据；本批没有安装或设备复验。
- 最终门禁、APK、output-metadata、红绿与定向日志、24张Golden和最终manifest归档至治理 `artifacts/invite-merge-cleanup-20261001/mobile/`。此前 `candidate.json` 保留为收敛前历史候选，不替代最终记录。

## 画面与实际设备边界

24张实际 Flutter Widget PNG 覆盖320/360/400/600dp、明暗、1x/2x字号；2x另含滚动到操作区画面。源码文件为 `test/features/threads/goldens/thread_management_flat_*.png`。内存样本仓储、确定性测试字体不代表真实账号或设备画面。

本批次隔离描述的 runId 为 `preview_ff8b5b1777fb76889132036a`，Backend42353、media42223、Web43931，本轮运行源码为 `cfe9621c39f9d9c8c7f764bf45293be43bab1af7`；这是合成隔离样本，不是真实用户快照。4db文档来源更新不代表运行实例升级。交付收尾时治理任务已停止该预览并保留外部数据；不再调用已停实例。没有复制账号密码、VPS sample-accounts 或私有日志到 Windows，没有自动登录或线上业务写入。

开始检查时唯一设备4b9c39b5曾连接，历史会话均已停止且无 active/blocked。调用正式 `dev:start` 时设备已断开，入口拒绝“需要唯一已连接的ARM64真机”，随即 ADB 列表为空。没有建立本任务 Debug 会话，没有安装或接管其他会话；真实设置页、原账号登录、App重启和跨端设备联验仍未覆盖。设备恢复后再按现有归属与身份核验入口启动，不轮询或改用公网验收。

现有 App 从 API origin 组合 `/join/{token}`；隔离预览 API 和 Web 分端口，未向 App 注入独立 Web origin，因此不能声称预览完整URL跨端一致。本轮不扩张预览协议。负责人已基于展示的候选确认本轮合并推进；这些截图仍只证明 Widget 渲染，不证明真实账号与设备行为。

## 尚待设备执行的关键路径

在已核验并绑定本任务的隔离 Debug 会话中，由负责人使用可访问样本账号复验；不得用公网自动写入替代。

1. 已发布私帖楼主修改标题后，点一次“复制邀请链接”，核对修改保存完成后复制；连续复制、离开再进、App重启与另一端取得同一 token，不出现邀请抽屉或重置入口。
2. 取链失败时提示重试，不轮换链接；剪贴板失败才显示完整可选URL。切号、离页再回、权限改变时手动链接清除，迟到请求不回填或复制。
3. 在明暗、窄屏与系统大字下查看所有标签；编辑移除、重复拒绝、5个上限、取消与完成，确认自动保存。删除文字及图标为危险色，取消确认后不删除。

这些路径尚未执行，自动回归、APK构建与用户合并授权不替代其结果。

## 收敛与发布边界

依赖 Backend PR #38 已合并至 dev（`6eb742502feed44df822b964b451349919b65073`），Foundation PR #28 已合并至 main（`bdd5b1caf4a4df6bb9583d053056482e76241c7e`）；本轮未部署。消费者继续固定已验证的4db文档来源，不因合并 SHA 改写当前门禁事实源。

负责人明确授权后，对稳定源码执行一次 `npm run check:apk -- -ContinueAfterFailure -TestConcurrency 2`，原始输出保存于 `.buildlog-settings-final-full.log`；该参数仅收集失败后的其余检查和构建结果，不把失败门禁改为通过。该次最终结果为退出1，唯一失败是生产兼容核验；完整输出SHA-256为 `f24ea6e838142ae0b85eb5743fe60c150abae967704c146e1b5ef6f351b2bf28`。不把结果记为整体验证通过。需先合并部署兼容 Backend，再交付消费者；如果实际部署 SHA 与固定来源不同，必须用官方同步入口登记到实际已部署 SHA，确认契约与生成内容无漂移，再复核生产门禁，不能预猜或放宽比较。

上一候选30b曾完成一次 `check:apk -ContinueAfterFailure -TestConcurrency 2`：原始退出1，仅生产仍为API5.28／build `21acf512285f2a21aaa831f960211780de73aafc` 与候选5.29／cfe不一致；Flutter5026通过、1项显式Sentry验收跳过，Windows67/67，APK构建成功。这些是**上一候选历史证据**，不是当前修改的完整门禁或安装包。原日志 `.buildlog-invite-full.log` SHA-256 `ae96292fde395f0edbcce447d605392c4e7984dc4753a8a46c86902f5ee42f0a`；旧APK `0.8.0-debug`／97／`site.wenyou.app.debug`／ARM64，SHA-256 `fb2b248eb4b3d5541b434a70a3b9cb04ba4551066a26c6959a0ab065266379d8`。本轮未合并、部署或清理现场。
