# 帖内身份

状态：`in_progress`

## 1. 模块目标与非目标

为每个账号在每个主题提供最多十套头像、昵称及历史身份展示。每条新发言可选其中一个 RP 或站内身份；角色按主题隔离，不改变账号权限和全站资料。

## 2. 用户角色与使用场景

楼主开启功能；楼主、协作者和已标记玩家可设置。普通读者可查看身份卡与站内账号，无设置权限。

## 3. 页面、入口和导航关系

主题设置提供无附加说明的开关；资料表单统一从编辑器身份栏打开，主题右上角菜单不重复提供入口。楼层、正文及楼中楼按该条发言的投影导航：站内身份头像直接进入账号主页，不读取身份卡接口；RP 头像打开身份卡。结构化角色提及按链接中的明确 identityId 打开同一角色卡；显式站内账号提及直接进入个人主页。

帖内身份入口候选／待负责人验收：编辑器只有在主题开启功能且本人具备楼主、协作者或已标记玩家资格时，左上角的身份下拉框才替代“发表楼层”等新发言标题；关闭或无资格时隐藏整个身份区域，恢复原标题并保留拖拽与展开按钮，不留身份占位。资料表单预览和身份卡继续复用 `ThreadIdentitySummary`。顶部统一为 28dp 头像、单行昵称和下拉箭头，最小触区保持 48dp；不显示帖内／站内模式副标题，读屏保留模式。功能开启且有资格但没有有效 RP 时沿用站内真实头像和用户名，不显示身份变化提示。菜单昵称单行省略，完整名称保留在读屏语义；粉色选中背景止于选择区，行尾编辑笔在独立触区。菜单紧贴锚点下方，按下方剩余空间限高滚动并显示滚动条，避让键盘；不按最大菜单高度把短菜单移成居中浮窗。十个角色及账号末项均可达。资料设置收进菜单：有资格但未配置时显示加号占位，每个 RP 身份项右侧提供笔形按钮，不另加编辑项；未满十个时保留加号新增，空资料角色仍占名额，点该行补全资料。点击主区域选择身份，点击笔或键盘激活编辑按钮只编辑，两者保持独立读屏语义；没有资格的普通读者不展示身份入口，即使集合仍含旧角色或恢复了 RP 草稿。已发布正文编辑仍保留原身份及编辑标题，原草稿模式与发布确认机制不因展示回退而改写。

自己的资料表单不嵌套预览卡片，不重复显示站内账号或解释作用范围。头像本身可点击，右下角显示笔形标记；`WenyouAvatarEditButton` 保留完整头像点击区域和读屏名称，与个人资料复用 `WenyouMediaEditBadge`。仅保留昵称约束、操作状态、必要错误和未保存确认；他人身份卡继续展示站内账号以便辨认。

## 4. 用户操作流程

昵称和头像可分别留空。头像使用原裁切与 AVATAR 上传入口，保存仅写帖内资料。各 RP 身份平级，不设主身份。新编辑器按当前账号和主题沿用最近明确选择或成功发表的身份；没有历史选择或原角色已不可用时使用站内身份，每次读取最新角色资料与 token；已恢复草稿保留所选稳定 identityId，不随列表排序、旧默认值或其他编辑会话变化。新增成功明确选中新角色，编辑既有角色不切换。删除角色释放名额且 ID 不复用，关闭或撤权仍可删除本人角色。保存资料只影响后续发言，清除资料不清除旧快照。

关闭有未保存修改的资料表单时先确认；遮罩和拖拽不关闭表单，保存及头像处理期间锁定退出。连续点关闭只退出一次，不影响底层主题页面。主题关闭 RP 前说明全帖恢复站内展示、历史资料保留与重新开启的效果，取消不写入。

身份卡保留发言头像、昵称及系统角色；站内真实头像、用户名与右箭头组成面板首行的可点击账号入口，直接进入该账号主页，不另列主页按钮或提供提及、筛选操作。没有 RP 展示时合并为一行。旧楼层通过快照 identityId 读取同角色资料，账号行下仍只显示历史头像昵称，不再追加当前角色对照行；清除后保留历史与账号行，不重复说明回退状态。昵称按 Unicode 码点校验并显示行内错误，长名字与大字号允许换行。

资料楼层候选：原表单在昵称下增加可选链接，能力 `rpIdentityProfileSupported` 缺失时隐藏。解析复制楼层的站内主楼／楼中楼定位格式（允许 order/subthread 展示参数），只取稳定 post ID，再通过已授权读取验证真实主题。允许本主题各子贴、回复与他人代贴，不按作者限制；失败保留输入并显示字段错误。清空后保存显式解绑；未修改字段省略，不能因当前访客不可见而误解绑本人原引用。

阅读卡仍用底部面板，去掉可见标题和 X；小字“帖内身份”在昵称下，系统标记紧邻昵称，关闭保留外部点击、下滑、返回与无障碍 dismiss。站内账号行位于最上方，其次为 RP 身份，资料正文直接接在 RP 身份下方，不加内层卡片或标题；未绑定不占位，只有资料区加载／重试。`NONE` 隐藏、`UNAVAILABLE` 显示统一“资料暂不可用”、`AVAILABLE` 继续授权读取。旧发言头像昵称保持快照，引用读取同一个角色当前绑定，不换成别的角色。

## 5. API operationId 与生成类型

- `rpIdentitiesList` 返回 `RpIdentityCollectionDto`；`rpIdentitiesCreate/Find/Update/Remove` 返回 `RpIdentityStateDto`，Create/Update/Delete DTO 分别承载新建资料、version 更新与 JSON version 归档。
- `threadIdentitiesMine`、`threadIdentitiesFindUser` 仅供旧接口和缺角色 ID 的旧 RP 草稿迁移读取，不作为新版默认、排序或账号代表。
- `threadIdentitiesUpdate` 使用 `UpdateThreadIdentityDto`，独立清除标记和 version 防止误覆盖。
- `threadIdentitiesClear` 清除本人资料；`threadIdentitiesSetEnabled` 使用 `SetThreadIdentityEnabledDto` 设置主题开关。
- 作者消费可选 `RpIdentityResponseDto`，正文消费 `MentionIdentityDisplayDto`，操作目标 userId 保持账号含义；identityId 标识主题内稳定角色。

## 6. 状态模型和数据流

domain 只包含不可变 RP 展示值、身份模式和更新输入。application ports 定义读取结果 `ThreadIdentityState`、`ThreadIdentityCollection` 及仓储；data 校验主题和账号范围、映射头像治理投影。presentation 持有未提交表单，失败时不丢失。组合根绑定生成 API 仓储。

资料接口兼容新增 `profilePostId`、`clearProfilePost`；更新沿用 version，并区分本人 `identity.profilePostId` 与访客投影 `profilePostStatus/profilePostId`。资料只改变编辑版本，不影响未变头像昵称的发表 token。`identity_profile.dart` 暴露纯链接解析、授权查询 port 与 UI builder port；组合根绑定 posts 的正文预览，避免 thread_identity 反向依赖 posts。

## 7. 鉴权、权限和隐私规则

账号始终是提及、筛选、订阅、举报目标。服务端判定资格及可见性；卡片不得展示错主题／错账号结果。会话变化使旧表单失效。身份写入禁止自动重放，不修改站内头像。

## 8. 本地存储、缓存及失效规则

身份模块不单独持久化资料。每次打开卡片重新获取角色与正文，刷新先撤下旧正文，读取范围绑定 viewerScope 和本次打开标识；403/404/删除、切号与晚响应不能回退旧内容。读缓存绑定 viewerScope，保存或开关变化使阅读投影失效；编辑器的 mode/identityId/token 和未知结果载荷由 posts 的账号隔离草稿保存，不随阅读缓存销毁。

## 9. 加载、空数据、错误、重试和冲突状态

加载错误可重试；撤权后保留输入并禁用保存。并发更新失败重新读取资格/version，不覆盖未保存文本，再次保存须明确确认。新建结果不明时保留输入，先返回原菜单查看集合，不按同名猜测成功或自动重试；再次新建需要明确确认。40013 显示已满十个，不覆盖角色。发言的 `40011` 要求明确确认新身份，`40012` 提示重新选择提及；由 posts 负责重试状态。

## 10. 跨模块约束

字体作用域候选：帖子中的角色身份资料弹层使用默认字体，明确关闭 PostReadingBody 的字体加载作用域，保留资料原始 Markdown/fontId；完整主题帖正文的字体能力不扩展到身份资料预览。 具体边界与待验收证据见[作用域候选](../architecture/thread-fonts-mobile-scope-candidate.md)。

通过 `identity_models.dart`、`identity_ports.dart`、`identity_mapping.dart`、`identity_widgets.dart` 分别开放领域、应用、映射和 UI 入口。模块只依赖 media，不反向依赖 threads/posts/social/search/notifications；身份卡沿用账号 ID 的共享主页路由。Foundation 样式依赖保持正式 `v7.2.1`。

## 11. 测试场景与验收条件

覆盖生成 API 的清除标记和禁重放、卡片历史／当前／ACCOUNT 区分、关闭投影、长昵称与 Unicode、窄屏大字及深浅色布局、资料变化和草稿冻结。人工检查身份选择、两种身份交替、撤权和真实头像裁切。候选尚待负责人验收，见 [验收记录](../architecture/rp-identity-acceptance.md)。

## 12. 已知限制和后续功能

每账号每帖最多十个未归档身份；不提供跨主题角色共享、匿名账号隐藏和旧发言换身份。@ 候选平级列出站内账号与全部角色，同名项按 candidateKey 区分；原单身份兼容锚点只服务旧接口。头像治理移除优先于历史快照保留。未连接设备时自动测试不能代替真机验收。

## 13. 最近审查的契约版本和后端提交

本轮字体样张契约来源：Backend `2db4ef1254c7738966dc28b1cd1fc10dcb19da47`／API `5.44.0-dev.20261024.3`。HTTP 形状不变，仅统一后台自动样张文案；本模块运行逻辑不变。离线格式验证范围见[验证说明](../architecture/font-format-offline-probe.md)。


2026-10-24 交付前来源复核：线上更新至 Backend `31f39ff317e56d6eb49b4c5e60ecdb93dfc9ec06`／API `5.44.0-dev.20261024.2`。机器契约零差异，仅字体 Worker 运维说明新增 8 行；同步来源与说明，应用及构建源码不变。完整门禁和窄复核分别见[集成验收记录](../architecture/alignment-font-integration-acceptance.md)。

2026-10-24 行距合并集成：保留已合并 PR #114 的完整字体能力与本次标题间距修复。固定 Backend `c80f015402e22647bbc85aecc9513d3d1a026096`／API `5.44.0-dev.20261024.2`；相对字体基线 `f1025db4`，同步脚本全部导出契约及说明字节无变化，仅来源 SHA 更新。历史候选的旧端无字体能力说明不再代表集成后客户端。详见[集成验收记录](../architecture/alignment-font-integration-acceptance.md)。

2026-10-24 契约兼容同步：固定 Backend `bc1135b72557eb6025a541dbd10119cf528ff989`／API `5.43.0-dev.20261022.3`，完整同步机器契约、字体资源契约与生成客户端。新增字体能力均为可选；本候选不声明字体读写能力，服务端安全投影旧端正文并拒绝降级覆盖，拒绝时保留编辑内容。字体选择与缓存继续由独立 PR 114 验收，详见[兼容同步记录](../architecture/alignment-contract-compatibility-sync.md)。

2026-10-24 字体管理契约审查：Backend `f1025db4ef0d4986f53a4beffac6514d7ee16357`／API `5.44.0-dev.20261024.2`。新增管理字体提交、分页和顺序接口；公开字体v2协议与本模块业务操作不变，Mobile不新增管理入口。产品候选已完成本地检查与构建，公网精确兼容随部署复核，真机验收未完成，见[持续加载记录](../architecture/thread-fonts-mobile-continuous-loading.md)。

2026-10-22 28 款字体与进度超时契约同步：Backend `f27898ec3b168b9e027b5d5abef43a0d3dafa242`／API `5.42.0-dev.20261022.1`。目录更新为 1.2.0，28 款（中文 12／日文 10／英文 6）；历史小城 ID 与旧 v1 解析保留。v2 明确 15 秒无进度和 600 秒总上限，并移除原件专属字段。此提交仅同步契约与生成客户端，持续加载行为仍待候选验证。

2026-10-22 字体运行策略契约同步：Backend `d86734e5aa229c5401a092096b8845b3d17546b0`／API `5.42.0-dev.20261021.1`。新增公开 `textFontsGetRuntimePolicy` 与 v2 固定策略、schema 和夹具；旧正文、目录、manifest 字节与资源不变。此提交仅同步契约与生成客户端，持续加载行为仍待候选验证。

2026-10-21 来源同步：固定 Backend `102b825379eb5da462f0ff765b29dc8fd7fb93ad`／API `5.41.0-dev.20261021.2`，本次新增正文字体能力、目录与正文写入版本；本模块既有业务操作不变，共享网络声明字体读取版本。未将候选契约当作已部署状态，字体消费者与验收见[字体 revision 5 候选记录](../architecture/thread-fonts-mobile-r5-candidate.md)。

2026-10-18 合并来源同步：Backend PR #55 已合并，固定最终提交 `6e00c4031a8f970609eef8cbf6fdefe3e6b12126`／API `5.40.0-dev.20261018.1`。契约字节与先前候选 `da68203a` 一致，本次只更新来源元数据；消费者验证和部署核验分别记录，不改变本模块既有范围。

2026-10-18 契约来源复核：固定 Backend `da68203a494c6d0f6d377c23399390c2cee397f3`／API `5.40.0-dev.20261018.1`。本次只增加主题详情可选真实收藏与官方订阅总数，不改变本模块既有操作契约；消费者接入与验证见[统计契约同步](../architecture/thread-action-counts-contract-sync.md)。

契约复核：固定已部署 Backend `08bbf5dbcd791270764fc2152fe9b61f683d7fa1`／API `5.39.0-dev.20261017.1`，合并音频预算错误与独立文本颜色能力。主题链正文保留颜色读取头、写入声明、保存校验和取色入口；音频上传、媒体展示与可定制工具栏继续保留。Foundation 固定正式 `v7.5.0`；独占空段、相邻彩色标题与对齐边界新增共享用例，OpenAPI 与合并基线一致。

2026-10-10 合并来源复核：通过官方同步入口固定到实际部署 Backend `b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045`，OpenAPI 仍为 `5.36.0-dev.20261005.1`。相对退役实施提交，机器契约、共享语料、生成客户端及本模块行为不变；仅来源登记更新，详见[退役验收记录](../architecture/retire-development-preview-acceptance.md)。

OpenAPI `5.36.0-dev.20261005.1`；Backend `a624bed0eb2b118701bd593fbce2aabf3dea7321`（已部署兼容契约，公网精确核验通过）。Markdown 6 为可选扩展，结构化提及按原 sourceHref + 原标签映射；账号、角色和旧裸链接各自保持语义。全局 Markdown 仍为 5，新增提及写开关默认关闭，运行状态由启动能力读取。

## 14. 相关代码与架构文档

- `lib/features/thread_identity/`；`lib/features/posts/application/post_identity_selection.dart`。
- [主题](threads.md)、[帖子](posts.md)、[兼容与弃用登记](../deprecation-register.md)。
- `contracts/thread-identity.md`、`contracts/thread-identity.v1.fixtures.json`。


### 已知单身份环境兼容

仅 `/meta` 明确为 5.33 时复用原 single 读取和有版本的既有资料维护：菜单显示站内账号及已有角色，不提供集合新增或归档。角色卡按账号读取后核对原角色 ID。集合 404、网络失败、未知版本和新写开关关闭均不触发此降级；5.34 及以后的集合路径不变。旧写入不发送 identityId，新版请求仍明确携带角色 ID；本地草稿保留选择，首次请求在持久化前冻结省略 ID 的旧载荷，升级后的未知结果重试不能自动补 ID。
