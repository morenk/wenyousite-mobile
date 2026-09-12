# 功能模块索引

状态仅允许 `planned`、`in_progress`、`implemented`、`deferred`。`implemented` 表示文档中的验收项已经由自动测试或明确记录的人工测试验证，不表示该模块永远不再变化。

Bug 的完成结论必须有项目负责人亲自复验原场景并明确通过；自动检查通过或候选安装成功不能替代该结果。存在待验收或验收失败的 Bug 时，模块保持 `in_progress`，在模块文档记录具体问题与当前结果，按 [仓库验收流程](../../AGENTS.md#bug-候选与负责人验收) 更新。

所有模块的用户可见排版统一消费 Foundation v7.0.0 的 body/display/utility 语义文字角色并继承平台系统字体；字号、行高、字重、utility 等宽数字特性、功能字体例外与架构门禁见[系统字体迁移验收](../architecture/system-font-migration-acceptance.md)。模块文档只记录业务语境中的层级选择，不维护平行字号表。

| 模块 | 状态 | 当前事实 | 文档 |
| --- | --- | --- | --- |
| app-shell | in_progress | 主壳与在线更新已交付；正式签名升级安装仍需真机验收 | [应用壳](app-shell.md) |
| auth | in_progress | 认证与账号恢复已交付；公网账号回归仍待补齐 | [认证](auth.md) |
| home | in_progress | 发现流与分类筛选已交付；持续做真实性能验收 | [首页](home.md) |
| thread-feed | in_progress | 主题卡片、DTO 映射与分类目录已统一；真机消费者回归待完成 | [只读主题信息流](thread-feed.md) |
| moments | in_progress | 动态主闭环、独立收藏夹与评论通知定位已交付；公网真机联调待补齐 | [动态](moments.md) |
| tags | in_progress | 公开标签与标签工作台已交付；公网联调待补齐 | [标签](tags.md) |
| search | in_progress | 四类搜索已交付；主题结果 cursor 分页待接入 | [搜索](search.md) |
| threads | in_progress | 阅读、创作、管理和邀请已交付；公网验收待补齐 | [主题](threads.md) |
| posts | in_progress | 楼层与楼中楼读写已交付；阅读性能专项仍待完成 | [楼层与回复](posts.md) |
| editor | in_progress | 引用标记拆分已由负责人复验通过；引用内多空行候选待验收，撤销入口仍待完成 | [编辑器](editor.md) |
| drafts | in_progress | 本地快照与云草稿已交付；进程恢复边界持续收敛 | [草稿](drafts.md) |
| media | in_progress | 图片上传、动态多选与原图查看已交付；弱网及进程恢复真机验收待补齐 | [媒体](media.md) |
| notifications | in_progress | 分类、帖子及动态评论精确定位已交付；协作者通知待接入 | [通知](notifications.md) |
| direct-messages | in_progress | 私聊主闭环已交付；公网弱网与长会话验收待补齐 | [站内私聊](direct-messages.md) |
| stickers | in_progress | 收藏表情主闭环已交付；公网处理态验收待补齐 | [表情包](stickers.md) |
| users | in_progress | 用户资料、双画幅背景与活动汇总已交付；本人协作主题列表待接入 | [用户](users.md) |
| reports | in_progress | 社区举报六类目标主闭环已交付；公网联调待补齐 | [社区举报](reports.md) |
| moderation | in_progress | 治理决定与申诉已交付；管理员隐藏能力待接入 | [治理决定与申诉](moderation.md) |
| wallet | in_progress | 钱包与加油主闭环已交付；公网账务联调待补齐 | [温油钱包](wallet.md) |
| social | in_progress | 双收藏夹、订阅与关系主闭环已交付；切号及可见性自动回归已补齐，真机联调待完成 | [社交关系](social.md) |
| settings | in_progress | 账号设置主闭环已交付；部分资料能力仍有限制 | [设置](settings.md) |
