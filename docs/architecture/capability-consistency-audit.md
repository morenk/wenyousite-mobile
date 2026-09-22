# Web／Mobile／Backend 能力一致性：Mobile 候选盘查

状态：候选修复／待负责人验收。本报告覆盖 Mobile，Web 与 Backend 的证据由治理任务汇总；不把生成客户端或入口存在当作行为通过。

## 基线与入口覆盖

- Mobile 起点 `c5ba66683a6ad5004878d50fb19468211b261747`，独立分支 `codex/20260921-mobile-capability-audit`。
- Backend 与公网 `/meta` 均为 `fc88ea09a808af9c54c1f5b971e116b3be4a471b`，API `5.24.0-dev.20260920.1`。先以独立 chore `761c2437` 同步契约与 Foundation 正式 `v7.1.0`（`dcf75d385e39cc0c55d550a6f35921cd9a7aa508`）。5.24 新增三个管理接口，既有非管理接口未改变。properties 中历史 Markdown=4 不代表客户端缺少 Markdown5；实际门控与兼容由生产契约检查验证。
- [逐 operationId 索引](capability-operation-inventory.json)列出全部 223 个后端操作、方法、路径、请求 DTO、Mobile 调用位置、已有测试索引及排除原因。`audit_api_coverage --require-complete` 为 158/158 适用入口，另 65 项明确排除；此计数只表示调用覆盖。
- 排除项：53 个管理接口、未来 FCM、运维 health、已废弃加入方式、被聚合／授权范围查询替代的操作，以及已独立登记的管理隐藏、同媒体续签、本人协作主题、公开动态收藏等待产品接入能力。未将它们当成此次缺陷。

## 规则与行为核查矩阵

“已验证一致”仅表示下列静态规则与自动回归维度；真实服务、设备、账号权限变化仍按最后一节验收。每个操作的消费者位置可由上述索引定位。

| 功能入口／请求族 | 后端事实与核查维度 | Mobile 证据与结果 |
| --- | --- | --- |
| 注册、登录、验证码、重置密码、换密／换邮 | DTO 密码码点、8–100、新密码字母数字；换邮旧密码允许非空；申诉密码只有最小8；邮箱最长254；密码不得 trim | **已证实偏差／候选**：UTF16 导致 emoji 过早拒绝或不足8被放行，邮箱未拦截超长。统一精确范围；保留换邮历史密码与密码原始内容。`credential_input_policy_test`、auth/settings 控制器与页面测试。 |
| 会话、注销、账号退出 | 单次刷新、401 会话失效、不可重放写操作、注销显式确认 | **已验证一致**：network/session 与 auth/logout、settings/account_deletion 测试；没有新增后台重试或注销联调。 |
| 资料、头像、背景 | bio 1–255，不允许清空；用户名2–24且只BMP白名单；头像/背景专用格式、裁切比例、所有权 | **已证实偏差／候选**：bio 改码点上限，可见计数和读屏剩余字数同样使用trim后码点；ZWJ组合不再显示偏小。清空已有校验及 saveSettings 保护；用户名白名单不变；背景同时提交两种裁切。users/me_profile、avatar、profile_cover 回归。 |
| 动态正文创建、编辑与草稿 | 标题2–40、正文1000码点、最多9图、封面属于图片集合、版本冲突、稳定创建请求ID | **已证实偏差／候选**：标题/正文曾按UTF16计数，信息流与搜索读取适配器也误拒合法40emoji标题；写入与读取统一码点。九图、唯一媒体、封面、冲突保留草稿、失败复用请求ID已有 controller/persistence 测试。 |
| 动态评论、回复 | trim后500码点、单mediaId、图片与表情互斥、本人已完成且未绑定媒体；内容变更需新幂等键 | **已证实偏差／候选**：已有图片重复点原图标仅短提示，必须移除后才能添加；保留选择阶段锁、移除/关闭失效、发送期间锁和500码点。取消/失败保留文字，不恢复已移除的旧图；失败任务需继续查询/重试或明确放弃后才能发送。附件变更的 requestKey 已包含媒体ID，新增回归验证请求ID分离。 |
| 动态点赞、收藏、加油与评论入口 | canInteract=false禁止新增；已有赞／收藏可取消；删除/举报按各自权限 | **已证实偏差／候选**：搜索适配器遗漏后端canInteract，现正确保留false；信息流、详情互动栏、评论/回复入口和控制器补齐门禁；保留取消已有赞藏、浏览评论、删除及举报。`moment_controllers_test`验证禁写及允许撤回。 |
| 媒体选择／上传／确认／查询 | 10MiB；JPEG/PNG/GIF/WebP/AVIF；动图WebP/APNG拒绝；用途、处理状态、所有权；处理可能超过20秒 | **已验证一致**：既有 repository/controller保留 pending mediaId，查询超时/503/401/403/404不重复PUT；`media_processing_resume_test`断言继续仅GET、POST=2/PUT=1。评论选择器新增代次保护也阻止迟到错误UI。**待验证**：AVIF 在最低Android版本的解码能力无既定依据，维持现有限制并登记，未盲放。 |
| 主题／子贴／楼层／回复 | 标题100、Markdown正文10000码点；标签最多5/每项20且BMP白名单；版本、发言策略；正文发布须有非骰子可见文字，楼层可纯骰子 | **已证实偏差／候选**：标题与正文业务校验改码点；未改 Quill UTF16位置、Markdown解析、标签白名单与不同发布语义。threads/posts repository/controller/editor回归覆盖权限、冲突和重试。 |
| 编辑器／站内传送门／骰子 | Markdown固定语料；骰子最多20节点、1–100颗、2–1000面、modifier绝对值10000 | **已验证一致**：现有 core/markdown、editor 与 posts 富文本回归；仅最终业务长度改码点，编辑范围与选区保持UTF16，新增 documentLength=2000 对应1000emoji保护。 |
| 主题草稿／独立正文草稿 | 主题草稿10；正文草稿5槽、10000码点；版本冲突和本地持久化 | **已证实偏差／候选**：正文保存及入口长度改码点。槽位读 draftsState 同一快照，未用主题10覆盖正文5。drafts/controller/repository/sheet、主题持久化测试。 |
| 收藏表情 | 服务端limit/版本、重复/并发导入、重排冲突；私信表情独立 | **已验证一致**：collection.isFull采用items+pendingImports与服务端limit，sticker controller/reorder/direct integration回归。**已证实偏差／候选**：评论表情入口此前未消费能力开关，本次按meta隐藏未开放入口。 |
| 私聊 | 文字1000码点+单图；表情与文字/图互斥；UUIDv4；查询失败保留媒体；会话能力与权限 | **已证实偏差／候选**：正文和原子输入长度改码点。附件pending队列、媒体识别、发送幂等、权限/请求收件箱已有 direct_messages 与 media回归。 |
| 关注／订阅／拉黑／收藏夹 | 幂等关系写入、权限与数量以返回事实为准；文件夹1–24码点；默认夹不可重命名删除；删除迁移收藏 | **已验证一致**：social/bookmark controllers与repository已有runes校验、默认夹门禁和失败恢复；回归不运行共享数据破坏操作。 |
| 通知／消息入口 | 类型枚举、安全目标映射、已读写入和分页代次、账号切换 | **已验证一致**：notifications contract/repository/mutation_epoch/controller与app_shell导航测试；旧游标失败重载，路由使用稳定ID。 |
| 搜索／首页／公开资料分页 | 内容至少2码点、不透明cursor、筛选变化清空、失效cursor回首屏 | **已验证一致**：search states/controller已有runes与分组epoch；search optional_auth及repository/page回归覆盖游客与分页。 |
| 举报／申诉 | 举报details≤1000码点、OTHER必填；申诉trim后10–2000码点；目标类型与原因枚举 | **已证实偏差／候选**：说明长度改码点；原有枚举双向集合测试保留，举报失败保留输入。moderation申诉仍不附加后端不存在的密码max。 |
| 温油钱包／加油／签到 | 正整数十进制字符串、不超过有符号bigint；禁止自己加油；幂等及并发余额 | **已验证一致**：WenyouAmount既有字符串比较上限；钱包state/repository/widgets和签到回执测试，未转换浮点或执行真实资金写入。 |
| 管理后台／FCM／尚未接入产品能力 | Mobile V1明确非目标 | **有依据的平台差异**：逐操作排除原因及AGENTS产品范围；无新增管理入口。 |

## 已复现差异与验证

旧实现回归：评论生命周期4项失败（更换语义、移除后迟到选择启动上传、移除未取消上传、关闭后仍启动上传）；Unicode规则3项失败；canInteract禁写1项失败；密码/邮箱2项失败；合法标题读取2项失败、搜索只读权限1项失败；补充简介可见码点计数2项在旧实现失败（含ZWJ、255提交／256不请求）。它们是已证实实现缺陷，不能用来断言历史Sentry原事件根因。

后端子任务在隔离数据库与测试API独立验证：500emoji评论201、501emoji400；100码点密码200、101码点400。未写入公网数据。

修复后第一批34项定向测试通过，包含上述评论、Unicode、权限、幂等以及媒体查询保留身份；补充发送同步锁、相册迟到错误、凭证及全量门禁结果在候选交付时追加。所有新增功能测试均断言最终状态或请求次数，没有以生成文件一致代替业务测试。

## 原故障与待验收

- Sentry `WENYOUSITE-MOBILE-N`、事件 `95cb7ffc0ae3469f89e36d2ce78d2732`：0.7.1/build95，2026-09-20T16:38:52.792Z，`mediaUpload.request`约25937ms，经过上传确认和多次处理查询后`HttpException`未收到响应。requestId `23965826-5d4c-410a-b465-3870bc16ca8e`。现有证据不足以认定是单图数量限制；不关闭问题。
- 真机候选依次复验：首次单图→重复点上传图标（不选图/不上传且文字附件不变）→删除后重选（含同图）；取消选择；上传失败后保留文字→原输入重试；处理中断网→继续查询；移除后重选；图片/表情切换；关闭重开；快速双击选图/发送；发送失败后保留草稿。确认最终只发送当前附件，不出现重复评论，不复活已移除图片。
- 使用含emoji、组合emoji的边界输入验证动态40/1000/500与私聊1000；超限应在提交前明确阻止。普通用户只读动态不能新增互动，仍可撤销旧赞藏。密码测试只能专用测试账号，不修改负责人凭证。
- 未执行公网批量写入、真实账号权限撤销、最低API26 AVIF、真实Android断网/相册Activity重建、原Sentry场景复现。它们保持待验证，不因静态核查、模拟自动测试或APK构建成功记为负责人验收通过。
- 本次默认Auto-review偏好已传递；宿主实际策略为never且无受支持设置参数，未宣称已启用Auto-review。无合并、部署、Sentry关闭或任务归档。

## 门禁执行记录

探索性首轮全量运行在修复尚未冻结时启动，不能作为最终交付证据。运行到最后钱包／iOS阶段时为4547通过、1个显式真实Sentry收件用例跳过、29失败：诊断端点索引未重生成1项；运行中增加的新标题／权限测试读到旧编译产物3项；Foundation v7.1普通内容日期短显造成25项旧golden不匹配（私聊2、独立讨论1、收藏12、主题10）。索引已按新契约生成，新业务测试已在最终源码单独通过；这25条用例涉及37张图（收藏用例各含列表和管理面板），均经逐图检查，只有日期移除时分及因此释放作者栏宽度，未发现新增布局溢出。按已发布规范定向更新基线后冻结源码，完整门禁另行执行。

第一轮冻结门禁完整执行Flutter测试：4645通过、1项真实Sentry收件跳过，末尾仅`foundation_brand_assets_test`旧版7.0预期失败。对正式v7.0.0→v7.1.0的品牌manifest逐行比较，仅version变化、全部hash不变；更新测试预期，不修改图标资产。其后只补个人简介的可见／读屏码点计数及2条反证回归，重新冻结并完整执行最终门禁；前轮不计为成功交付。
逐操作状态采用保守口径：32个受已确认偏差影响的操作标“已证实偏差”（候选已修，尚待负责人验收）；61项有V1范围、运维／废弃用途或替代接口依据，标“有依据的平台差异”；其余130项标“待验证”，其中126项已实现入口有分组核查与自动测试，但未逐操作穷举所有真实服务边界，另4项为已登记未接入的协作主题、公开动态收藏、移动管理隐藏、同媒体续签。适用性仍为158适用／65排除，与行为通过数无关。

## 2026-09-21 原候选自动门禁与候选包

最终冻结源码执行 `npm run check:apk -- -TestConcurrency 2`，退出码0：OpenAPI校验、固定来源、API重新生成、线上API／Markdown兼容性、1040文件格式、应用与生成包静态分析、架构、21模块文档、158适用接口覆盖均通过。Flutter全量4648项通过、1项显式真实Sentry收件用例跳过、0失败；Windows发布工具18项通过；Android Debug APK构建通过。最终日志为`build/capability-final-check-2.log`，之前的失败轮不会混入本轮结果。

候选包经aapt核实：`site.wenyou.app.debug`、`0.7.1-debug`／build95、最低API26，183448298字节；SHA-256为`F3BE004DAFB865EB20001DA8BE7221776394294509D7726297AC4E2B8816D65D`。没有安装、签发Release或发布。

制品独立归档至`D:/code/wenyousite/artifacts/mobile-capability-audit-20260921/`；`candidate.json`记录最终提交、带短SHA的APK文件名、包摘要与日志。现有Debug构建不内嵌Git提交或dirty指纹；本次不新增构建功能，以外部manifest和`application-inputs.json`绑定身份。1643个应用输入文件的SHA-256聚合指纹为`142416194197545368f240ad0b1a8e59660e49e9607d07c5258cd90ddbbf620a`，提交后再次核对输入未变。负责人需按该候选及摘要复验，不能只凭同为build95判断已更新。

## 2026-09-23 单图交互纠正候选

本次用户明确纠正覆盖原“更换图片”方案：不常驻说明或更换按钮，已有图再次点原上传图标只显示现有样式短横栏“评论只能添加一张图片”，不选择、不上传、不替换，需先删除。API、Foundation 和上传网络链路不变。评论局部 OverlayPortal 复用共享横栏构造，按真实弹层布局与 FlutterView 系统安全区重定位；键盘 inset 仅用于可视区域边界，不再次加到 dock。重复点击不排队，提示不抢焦点，移除、切换附件、发送、关闭或路由释放均清理。

真实 `showWenyouComposerSheet` 回归覆盖 320×760 双倍字号（键盘280/460）、390×844（340）、760×390横屏（150），顶部24／底部34安全区、键盘高度变化、实际点击命中、编辑焦点、0次picker/0次上传、附件文字保留及关闭清理。反证将评论 composer 替回 `05c6f192`，同一“已有图片重复点击”用例明确失败：选择器调用预期0、实际1；候选恢复后通过。反证日志为 `build/comment-single-image-old-behavior.log`。9月21日包仅保留历史证据，不代表此纠正已实现。

本轮只运行本机fake picker/gateway/widget测试；没有线上自动化写入，也没有复用旧隔离服务。仍为修复候选／待负责人真机验收，原Sentry问题不关闭。

本轮首次 `candidate:apk` 在 analyze 因临时反证备份的 Dart 文件名与测试 import 顺序两条 info 停止，未计为成功；备份改为 `.txt`、import 排序后重新冻结，最终结果只采用 `build/comment-single-image-candidate-final.log`。

最终冻结源码采用按 UI 风险选择的 `npm run candidate:apk -- test/features/moments/moment_comment_attachment_lifecycle_test.dart test/features/moments/moment_pages_test.dart test/core/widgets/wenyou_snack_bar_test.dart test/core/widgets/wenyou_reliable_snack_bar_test.dart -TestConcurrency 2`：1040文件格式、应用及生成包静态分析通过，57项相关Flutter测试通过。未改网络／上传底层，不重复9月21日4648项完整门禁。

本轮真机验收：打开评论并输入文字、选一图；保持软键盘弹出后连续点击原上传图标，确认仅一条横栏提示、原附件/文字不变、相册不出现、键盘不收起；切换键盘高度及横屏、大字号，确认提示在可见安全区；删除图片后重选、取消选择、失败重试；打开表情面板或关闭再打开评论，确认短提示不残留。自动用例不是负责人真机验收。

最终 `candidate:apk` 退出0，Debug APK构建成功；独立 `docs:check`（21模块）与 `architecture:check` 通过。新包为 `site.wenyou.app.debug`、`0.7.1-debug`／95、最低API26、183448298字节，SHA-256 `B6015AEA72AEFBF2071FBE9D8E0994D4A3D4F1CA8226FF53A35D3251AA89807A`。归档目录 `D:/code/wenyousite/artifacts/mobile-capability-audit-20260923/` 的 `candidate.json` 绑定最终提交、带短SHA的APK文件名及日志；`application-inputs.json` 固定1643项应用输入，构建后无变化。输入聚合指纹 `838b9d043b8c2ac8c7c978cc2195c1857a96226a77d0b5ab64299bcd87bbaed8`，算法为每行路径、TAB、文件SHA-256，以LF连接且末尾无换行后的SHA-256。原05c6包不适用于本次交互纠正。仍未安装、发布或合并。
