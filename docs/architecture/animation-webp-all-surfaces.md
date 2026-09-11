# 动画 WebP 全展示场景补齐

状态：候选实现／待负责人全场景验收。负责人明确指出先前仅覆盖主题列表预览不是完整交付；本任务沿用原问题，补齐正文、编辑器、详情、大图、私聊和表情的展示资源选择。旧个人主页多播验收只证明原候选对应场景，不作为本轮全场景验收。

## 已确认事实与交付边界

审计基线 Mobile `3c3b63c0ae40fd438682a7279f2059fa6628336d`，API `5.20.1-dev.20260911.1`、Backend `062412601b3a8dbf4f64494115a2445d312dd53d`、Foundation `v6.10.0`。原主题封面预览只在 `ThreadCoverMediaResponseDto.previewVariants` 暴露；其他媒体 DTO 没有明确完整动画 WebP 描述。`MediaResponseDto.url` 仍表示 GIF 原件。

Markdown 正文和编辑器只持久化图片 URL；公开正文不能调用仅本人可读的 `GET /media/{id}` 上传状态接口解析其他用户的图片。已同步 Backend `94934be265e36e2f6dba2fbc8b53e58e2755fa52`、API `5.22.0-dev.20260912.2` 的统一可空 `display` 和授权正文 `mediaDisplays: [{sourceUrl, display}]` 投影；实现不猜测扩展名、对象 key 或追加转换参数。此处是固定契约来源，不代表该提交已部署。

正常已转码动画在正文和大图使用完整 WebP，列表使用适当小预览；不把小预览冒充高清。保持主题封面可见面积至少 50% 立即多播、激活后仍部分可见即保持、完全离屏释放的规则，保持原帧时长及循环。动态贴列表、表情选择／管理面板既有静态策略不因格式统一而改变。后台、隐藏页、路由转场、省流量和减少动态效果限制保持。

本轮只交付检查、Debug 候选和 PR；新安装、合并及发布分别等待授权，不删除原 GIF 或兼容入口。

## 场景与回归矩阵

| 场景 | 实现入口 | 资源和身份要求 | 现有回归入口 |
| --- | --- | --- | --- |
| 主题、楼层正文及正文表情 | `core/widgets/wenyou_markdown.dart`；各正文页面的 `WenyouMarkdown` 装配 | 可信正文 URL 投影选择完整动画 WebP，Markdown 原身份不变；外部未知资源保留既有路径 | `wenyou_markdown_image_actions_test.dart`、Markdown 合同／阅读测试 |
| 正文大图 | `content_image_viewer_page.dart`、`wenyou_image_viewer_page.dart` | 独立展示源；普通保存默认 display，原 ID／URI 用于收藏导入 | `content_image_viewer_page_test.dart`、`device_image_gallery_test.dart` |
| 主题封面及首页／标签／搜索／收藏／个人主页 | `thread_feed_mapper.dart`、`thread_feed_models.dart`、`thread_feed_cover.dart` | 保留尺寸／DPR 的小预览选择和多播调度，新完整源只参与契约明确的降级路径 | `thread_cover_contract_test.dart`、`cover_playback_scope_test.dart`、`public_user_cover_start_test.dart`、首页／收藏页测试 |
| 编辑器图片和表情 | `editor_embed_builders.dart`、`thread_compose_page.dart`、`post_composer_sheet.dart` | 替换直接 `Image.network` 的展示入口；插入与序列化继续使用稳定身份，重开不丢资源投影 | `editor_embed_builders_test.dart`、`thread_compose_page_publishing_media_cases.dart`、楼层上传／编辑重开测试 |
| 动态详情、主评论和楼中楼图片／表情 | `moment_models.dart`、`moment_repository.dart`、`moment_search_mapper.dart`、`moment_detail_comment_body.dart`、`moment_playback_image.dart` | 完整 WebP 播放，静态 poster 独立；所有构造／映射路径携带描述，失败记录与当前轮播判断保持 | `moment_animation_test.dart`、`moment_repository_test.dart`、`moment_pages_test.dart` |
| 动态全屏 | `moment_widgets.dart` 的 `openMomentGallery` | 显示完整 WebP，原媒体／表情身份传入收藏导入，返回恢复原播放边界 | `moment_image_actions_test.dart`、`moment_animation_test.dart` |
| 私聊图片和表情／大图 | `direct_message_models.dart`、`direct_message_repository.dart`、`direct_message_media.dart` | 有完整动画描述时不能优先误选静态 medium；不破坏权限、几何或保存行为 | `direct_message_media_test.dart`、`direct_conversation_page_sending_media_cases.dart`、私聊仓储测试 |
| 表情选择、收藏管理、正文导入 | `sticker_models.dart`、`sticker_repository.dart`、`sticker_widgets.dart`、`sticker_reorder_grid.dart` | 面板静态策略保持，正文展示用完整动画；收藏引用／返回 Markdown 不改成短期展示 URL | `sticker_repository_test.dart`、`sticker_direct_integration_test.dart`、表情网格 Golden |
| 上传完成预览和动态草稿 | `media_upload_models.dart`、`media_upload_repository.dart`、`moment_draft_store_ports.dart`、动态创作组件 | 上传响应、重新查询、临时状态和持久化往返均保留兼容描述；旧草稿可读 | `media_upload_repository_test.dart`、`moment_draft_store_ports_test.dart`、`moment_pages_compose_upload_cases.dart` |

表中简称测试位于 `test/core` 或对应 `test/features` 目录。头像／主页背景当前上传策略只接受静态图片，不扩展为新的动图功能；本地尚未上传素材使用本地输入预览，不凭空等待服务器变体。

## 公共选择器设计

消费的固定描述为 `display: {url, contentType: 'image/webp', width, height, bytes, animated, frameCount, durationMs, loopCount} | null`，动画 `loopCount=0` 表示无限、`1` 表示一次；静态描述固定 `frameCount=1`、`durationMs=0`、`loopCount=1`。各媒体 DTO 使用同形描述；正文／草稿／引用按授权返回精确源 URL 的 `mediaDisplays`。新 GIF 处理成功必须具有 display；历史 null 只表示兼容，不能宣称已完成 WebP 转换。Foundation 对应业务接入说明为 PR10／`22a1c4d8880944b4ecebe55475674fc2c776a080`，不改机器数值或正式依赖 Tag，运行时继续锁定 `v6.10.0`。应用层通过 `MediaDisplay`、严格 DTO mapper 和 `selectFullMediaUrls` 承接生成类型，职责如下：

1. 在公共媒体领域层承接可信资源描述，区分稳定身份、静态 poster、完整动画资源和列表小预览，记录契约 MIME、尺寸、字节及帧时序。各 feature 的 DTO 映射转为同一个内部类型，不在页面各自拼接 URL。
2. 完整资源纯选择器只接受原身份、display 和历史回退链，已知 display 的结果只包含其 URL；列表继续由独立的既有尺寸／DPR 选择器挑选小预览。正文／大图不能选择列表小预览；是否允许播放由既有播放控制器决定，选择函数不请求网络、不订阅滚动或改变播放数量。
3. Markdown 按后端可信投影解析原 URL，允许上传会话立即注入已确认描述；保持原文、剪贴板、草稿身份和收藏导入参数，不把渲染优化写回正文。公开正文与私聊的投影权限不能混用。
4. 旧数据缺新字段仍按兼容路径工作；处理中窗口结束保留媒体身份，只允许继续查询原媒体；明确处理失败和 401／403／404 查询错误分别显示失败，不伪装为仍在处理。已选 WebP 下载／解码失败的行为必须与“根本没有变体”分开，不能悄悄触发大 GIF 重复下载；保留可追溯的失败静态图和显式重试。
5. URL／变体版本变化使对应播放器和错误状态失效；账号切换取消旧解析和在途请求。公共展示缓存不继承未经证明的私有资源可共享性。主题封面既有 16MiB 编码缓存不是全应用解码内存上限。
6. 通用大图项分离展示与持久身份。大图和普通保存／下载默认 display，收藏导入和编辑／草稿仍按原 ID／URI；仅用户明确要求原件的操作才访问原身份，不能将静态 poster 当成动画下载降级。

## 不依赖新 API 的素材与验证

`test/fixtures/animation-webp-all-surfaces` 提供独立合成的原 GIF、同尺寸完整动画 WebP、小尺寸预览 WebP和静态 poster；原／完整尺寸 320×180、预览 80×45。两帧颜色不同，首帧 120ms、第二帧 240ms，有限循环元数据用于后续实际解码核验。素材不含用户内容，生成器与 SHA-256 清单同目录保存；不依赖业务 DTO 生成预期。

HTTP fixture 分别记录各资产 URL 的请求次数和实际返回字节；WebP 失败仅显式重试同资源，覆盖无 poster／poster 加载与失败时准备及后台取消，确认正常正文、大图、编辑器、私聊和动态详情请求完整 WebP、不请求 GIF，列表请求小预览或静态 poster。独立 codec 测试读取 Backend 实际编码器产物，验证尺寸、逐帧像素、帧时长及有限循环；播放生命周期沿用真实动画回归。

候选精确提交、统一门禁与正常入口 Debug 构建结果以本任务 PR 记录为准；线上旧契约不兼容时保留严格门禁失败，不能用候选来源冒充已部署 SHA。全场景性能另以 Profile／Release 测量，不用 Debug 数字或先前仅列表的 Profile 报告代替本轮证据。

兼容后端发布后，正常同步主来源为 `6fdfa00eaf1f3056ba30f2ffbc529d12eed1c823`、API `5.22.0-dev.20260912.2`；OpenAPI、共享黄金用例与实际编码器二进制相对 94934be 不变。下文 94934be 保留为最初稳定契约及编码器语料来源，线上严格验证使用 6fdfa 的精确部署 SHA。

## 实际接入与身份边界

- 正文、楼层、回复、编辑用 PostDetail、草稿以及搜索／最近回复 DTO 在各自仓储映射授权 `mediaDisplays`。搜索和个人最近回复当前仍是文本摘要，不新增图片加载。头像与背景只映射显示 URL，修改操作继续提交媒体 ID，不扩展动态头像上传策略。
- `RichEditorSession` 在上传／表情插入时接受展示描述，编辑重开从原 PostDetail／ThreadRemoteDraft 取得映射；Markdown、剪贴板、收藏参数保持原 URL。剪贴板由 Markdown／Delta 模型生成，不临时创建图片 Widget，不因复制原身份发起 GIF HTTP 请求。
- 云草稿恢复先校验账号／编辑器存活，再替换展示映射并装入正文；线程本地快照与动态草稿持久化辅助描述。旧无字段可读，整个映射畸形或其中单项无效只丢弃辅助项，标题、原正文、owner、remoteDraft 和原媒体 ID 仍可恢复。网络 DTO 的坏 display 严格报错，不按历史 null 自动请求 GIF。
- 通用大图、正文图片和编辑嵌入展示完整 WebP。默认保存用大图项的显示 URL；收藏／编辑使用原 URL 和 ID。私聊／动态图片、表情详情和大图走同一完整资源选择。静态表情选择／管理缩略图和动态列表海报保持原策略。
- 已验证完整 display 的主题封面无需等待海报。海报缺失、尚未完成或失败均用占位底图；达到 50% 可见后按现有规则加载合适小 WebP，否则完整 WebP。历史无 display 保持原资格与回退规则。切入后台、减少动态效果等仍禁止加载动画。已知 WebP 解码失败保留静态并提供显式同 URL 重试。

## 上传等待、权限与取消

每次上传确认后仍按原有界轮询窗口查询；窗口耗尽进入 `processingPending`，保留 `mediaId` 和用途。用户点“继续查询”只调用 `GET /media/{id}`，不重新准备、POST 或 PUT；仍未完成则继续保留身份。动态批次和私聊独立待发送队列也复用原媒体身份。私聊只有完成后才发送带该媒体 ID 的消息；查询失败保留原错误类型，用户明确重试仍只查询。

确定性 401／403／404 与业务处理失败不显示成处理中；通用上传控制器禁止对上述不可访问结果直接续查，503／网络错误允许同 ID 查询。取消、任务替换和账号范围失效撤销在途请求，迟到回调先核验运行代次，不能清掉新任务的待查询身份。当前进程退出不自动恢复在途上传，不增加后台队列。

## 实际编码器证据与验收限制

`contracts/fixtures/media-display` 固定于 Backend `94934be265e36e2f6dba2fbc8b53e58e2755fa52`：GIF 144 字节，完整 WebP 316 字节，24×16，红／红／蓝三帧，300／600／600ms，两轮。WebP SHA-256 为 `4be3e3ca66868c69d3352c2b72c6eaf1c4a8e8c05d8d3198eebcdebe9eef2fd6`。Flutter 实际 codec 验证帧数、颜色、尺寸、时间与 repetitionCount=1，未把重复帧合并成错误时间线。治理任务另外以最终 Backend 候选 `7fbb45d9` 编译后的 worker 重编码同一 GIF，逐字节输出一致；记录见治理归档 `backend-checks/compiled-fixture-equivalence.json`。

新增回归入口为 `media_display_selection_test.dart`、`media_display_http_test.dart`、`media_display_surfaces_test.dart`、`media_display_draft_test.dart`、`media_processing_resume_test.dart`，云草稿实际面板另由 `content_drafts_sheet_test.dart` 验证恢复先映射后原正文的顺序；另有共享黄金用例与实际编码器 codec 测试。资源缺少 display 的旧实现会在完整 WebP HTTP URL／字节、禁止 GIF 回退和编辑重开断言失败；新等待状态的续查测试会在旧轮询超时／重复上传路径失败。尚未取得负责人原资源和本候选全场景真机结果，不能把构造素材通过称为负责人问题已解决。

负责人复验顺序：上传 GIF 插入主题正文并查看大图／保存；编辑保存重开与云／本地草稿恢复；动态详情和回复、私聊图片及表情；个人主页／首页／收藏主题封面多播；验证后台、省流量、完全离屏重入与 WebP 错误显式重试。历史 null 原 GIF 与已知 display 的路径必须分开观察。新候选安装待本轮明确授权。