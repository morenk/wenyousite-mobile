# 帖内身份

状态：`in_progress`

## 1. 模块目标与非目标

为每个账号在每个主题提供最多十套头像、昵称及历史身份展示。每条新发言可选其中一个 RP 或站内身份；角色按主题隔离，不改变账号权限和全站资料。

## 2. 用户角色与使用场景

楼主开启功能；楼主、协作者和已标记玩家可设置。普通读者可查看身份卡与站内账号，无设置权限。

## 3. 页面、入口和导航关系

主题设置提供无附加说明的开关；资料表单统一从编辑器身份栏打开，主题右上角菜单不重复提供入口。楼层、正文及楼中楼按该条发言的投影导航：站内身份头像直接进入账号主页，不读取身份卡接口；RP 头像打开身份卡。结构化角色提及按链接中的明确 identityId 打开同一角色卡；显式站内账号提及直接进入个人主页。

编辑器左上角的身份下拉框替代“发表楼层”等新发言标题；资料表单预览和身份卡继续复用 `ThreadIdentitySummary`。顶部统一为 28dp 头像、单行昵称和下拉箭头，最小触区保持 48dp；不显示帖内／站内模式副标题，读屏保留模式。没有有效 RP 时沿用站内真实头像和用户名，不显示身份变化提示。菜单昵称单行省略，完整名称保留在读屏语义；粉色选中背景止于选择区，行尾编辑笔在独立触区。菜单紧贴锚点下方，按下方剩余空间限高滚动并显示滚动条，避让键盘；不按最大菜单高度把短菜单移成居中浮窗。十个角色及账号末项均可达。资料设置收进菜单：有资格但未配置时显示加号占位，每个 RP 身份项右侧提供笔形按钮，不另加编辑项；未满十个时保留加号新增，空资料角色仍占名额，点该行补全资料。点击主区域选择身份，点击笔或键盘激活编辑按钮只编辑，两者保持独立读屏语义；没有资格的普通读者不展示无效选项。已发布正文编辑仍保留原身份及编辑标题，原草稿模式与发布确认机制不因展示回退而改写。

自己的资料表单不嵌套预览卡片，不重复显示站内账号或解释作用范围。头像本身可点击，右下角显示笔形标记；`WenyouAvatarEditButton` 保留完整头像点击区域和读屏名称，与个人资料复用 `WenyouMediaEditBadge`。仅保留昵称约束、操作状态、必要错误和未保存确认；他人身份卡继续展示站内账号以便辨认。

## 4. 用户操作流程

昵称和头像可分别留空。头像使用原裁切与 AVATAR 上传入口，保存仅写帖内资料。各 RP 身份平级，不设主身份。无历史选择的新编辑器使用站内身份；已恢复草稿保留所选稳定 identityId，不随列表排序、旧默认值或其他编辑会话变化。新增成功明确选中新角色，编辑既有角色不切换。删除角色释放名额且 ID 不复用，关闭或撤权仍可删除本人角色。保存资料只影响后续发言，清除资料不清除旧快照。

关闭有未保存修改的资料表单时先确认；遮罩和拖拽不关闭表单，保存及头像处理期间锁定退出。连续点关闭只退出一次，不影响底层主题页面。主题关闭 RP 前说明全帖恢复站内展示、历史资料保留与重新开启的效果，取消不写入。

身份卡保留发言头像、昵称及系统角色；站内真实头像、用户名与右箭头组成可点击的账号行，直接进入该账号主页，不另列主页按钮或提供提及、筛选操作。没有 RP 展示时合并为一行。旧楼层通过快照 identityId 读取同角色资料，顶部仍只显示历史头像昵称，不再追加当前角色对照行；清除后保留历史与账号行，不重复说明回退状态。昵称按 Unicode 码点校验并显示行内错误，长名字与大字号允许换行。

资料楼层候选：原表单在昵称下增加可选链接，能力 `rpIdentityProfileSupported` 缺失时隐藏。解析复制楼层的站内主楼／楼中楼定位格式（允许 order/subthread 展示参数），只取稳定 post ID，再通过已授权读取验证真实主题。允许本主题各子贴、回复与他人代贴，不按作者限制；失败保留输入并显示字段错误。清空后保存显式解绑；未修改字段省略，不能因当前访客不可见而误解绑本人原引用。

阅读卡仍用底部面板，去掉可见标题和 X；小字“帖内身份”在昵称下，系统标记紧邻昵称，关闭保留外部点击、下滑、返回与无障碍 dismiss。资料正文直接位于身份与账号行之间，不加内层卡片或标题；未绑定不占位，只有资料区加载／重试。`NONE` 隐藏、`UNAVAILABLE` 显示统一“资料暂不可用”、`AVAILABLE` 继续授权读取。旧发言头像昵称保持快照，引用读取同一个角色当前绑定，不换成别的角色。

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

通过 `identity_models.dart`、`identity_ports.dart`、`identity_mapping.dart`、`identity_widgets.dart` 分别开放领域、应用、映射和 UI 入口。模块只依赖 media，不反向依赖 threads/posts/social/search/notifications；身份卡沿用账号 ID 的共享主页路由。Foundation 样式依赖保持正式 `v7.2.1`。

## 11. 测试场景与验收条件

覆盖生成 API 的清除标记和禁重放、卡片历史／当前／ACCOUNT 区分、关闭投影、长昵称与 Unicode、窄屏大字及深浅色布局、资料变化和草稿冻结。人工检查身份选择、两种身份交替、撤权和真实头像裁切。候选尚待负责人验收，见 [验收记录](../architecture/rp-identity-acceptance.md)。

## 12. 已知限制和后续功能

每账号每帖最多十个未归档身份；不提供跨主题角色共享、匿名账号隐藏和旧发言换身份。@ 候选平级列出站内账号与全部角色，同名项按 candidateKey 区分；原单身份兼容锚点只服务旧接口。头像治理移除优先于历史快照保留。未连接设备时自动测试不能代替真机验收。

## 13. 最近审查的契约版本和后端提交

OpenAPI `5.36.0-dev.20261005.1`；Backend `eb9ff12c770b14501eb1d9daa19f4d823728eba6`（已提交兼容契约，未部署）。Markdown 6 为可选扩展，结构化提及按原 sourceHref + 原标签映射；账号、角色和旧裸链接各自保持语义。全局 Markdown 仍为 5，新增提及写开关默认关闭。

## 14. 相关代码与架构文档

- `lib/features/thread_identity/`；`lib/features/posts/application/post_identity_selection.dart`。
- [主题](threads.md)、[帖子](posts.md)、[兼容与弃用登记](../deprecation-register.md)。
- `contracts/thread-identity.md`、`contracts/thread-identity.v1.fixtures.json`。


### 已知单身份环境兼容

仅 `/meta` 明确为 5.33 时复用原 single 读取和有版本的既有资料维护：菜单显示站内账号及已有角色，不提供集合新增或归档。角色卡按账号读取后核对原角色 ID。集合 404、网络失败、未知版本和新写开关关闭均不触发此降级；5.34 及以后的集合路径不变。旧写入不发送 identityId，新版请求仍明确携带角色 ID；本地草稿保留选择，首次请求在持久化前冻结省略 ID 的旧载荷，升级后的未知结果重试不能自动补 ID。
