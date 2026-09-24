# 全屏图片图集候选验收

状态：首轮真机验收发现正文图片来源定位失败；二轮修正已通过完整门禁，Mobile PR #54 已合并到 `dev`，待负责人在正式发布候选上复验。当前尚未发布 build 96。兼容 Backend 已部署，当前不增加系统后台服务，不改变图片上传、正式 Markdown 或完成状态含义。

## 最新 `dev` 冲突整合候选

图集分支与图片上传、动态评论长按及关系管理等已合并切片同时修改模块文档、评论图片入口和少量组合根/测试文件，PR 因而出现文本冲突。整合提交 `eb2ff0a039fde1aac5131f4d41efc6d79e0622ed` 包含 `dev` 的 `c9d29567f833bc409cada3057b797cf23e309240`：评论图片点按进入分组图集，图片同行空白长按打开评论操作；作者行仅头像可跳主页。发布时读屏采用新版时间组件。图集读取与已接入的移除粉丝均不再列入 API 待实现排除。

在整合源码上执行 `npm run check:apk -- -TestConcurrency 4` 退出 0：Flutter 4832 项通过、1 项既有 Sentry 线上回执验收按默认配置跳过，Windows 工具 18 项通过；格式、应用及生成客户端分析、架构、21 个模块文档、API 覆盖、生产 API/Markdown 兼容性和 Debug APK 构建均通过。此结果取代此前二轮仅定向验证的交付证据；自动测试不代替负责人对正文指南针定位和真机手势的复验。

合并前 Debug 候选 APK：`D:/code/wenyousite/artifacts/mobile-image-gallery/image-gallery-merged-eb2ff0a0-debug.apk`，109242520 字节，SHA-256 `9ECE1C450664A8FC9CED1FA2B12E2FF8DB6B04429CF10335588DF09A810818A0`；包名 `site.wenyou.app.debug`、版本 `0.7.1-debug` / versionCode 95，minSdk 26、targetSdk 36，均从实际 APK 核验。完整门禁日志为同目录 `check-apk-merged-eb2ff0a0.log`，SHA-256 `B23D07085EE7EB7BDA53A1B0617663E221F0493E2BFFADFC05FBE474B053E939`。此包仅为合并前验收证据；正式签名 build 96 须重新构建和核验。

## 首轮反馈与二轮候选

负责人实测：在主贴或其他子贴正文点击图片进入全屏，点右上角来源定位按钮后提示“目标楼层已经发生变化，请返回搜索后重试”；普通楼层和楼中楼图片可以定位。代码核对确认，旧按钮把正文 `BODY` 的来源 ID 传给只接受 `FLOOR` 的 `?post=` 路由，且使用了容易被看成分享的外链图标。新候选将无父楼层且无楼层号的正文图片路由到所属 `?subthread=`，保留普通楼层 `?post=` 和楼中楼独立讨论坐标，并与主题页“跳到最新发言”共用 Foundation 指南针图标。按钮 tooltip 分别说明正文、楼层或回复目标。

回归在旧实现先复现主贴/其他子贴正文的错误路由与旧图标；修改后 `test/features/media/reading_gallery_page_test.dart` 覆盖两类正文、普通楼层和楼中楼，四种实际点击路径及图标均通过。自动回归不代替负责人复验，尤其需检查非默认子贴切换后是否落在目标正文、普通关闭是否仍保留原阅读位置。

二轮按普通定位 Bug 候选门禁执行 `npm run candidate:apk -- test/features/media/reading_gallery_page_test.dart test/features/threads/thread_image_gallery_test.dart -TestConcurrency 2`，全仓格式检查、应用与生成客户端全量静态分析、9 项直接相关测试及 Debug APK 构建均退出 0；`docs:check` 和 `architecture:check` 另行通过。本次没有重跑全量 Flutter 测试；上一轮 4,665 项全量通过只对应修改前的源码，不能充作二轮集成门禁。负责人验收通过后、合并前须对二轮最终应用源码运行完整门禁。

二轮原本机包：`D:/code/wenyousite/artifacts/mobile-image-gallery/image-gallery-locate-v2-debug.apk`，`site.wenyou.app.debug`，`0.7.1-debug+95`，183,539,770 字节，SHA-256 `7f867a5c1de69ba3c83e4b76efd3d757eb5f3ae9558b9324070b8fec99aa4ab2`。此包未包含最新 `dev`，已由上方整合候选替代；更早的旧包哈希 `fa7787e5…` 不含正文来源修正。当前没有连接的 ADB 设备，未代负责人安装。

## 图集范围与操作

| 入口 | 浏览范围 | 顺序 |
| --- | --- | --- |
| 子贴正文或主楼层 | 本子贴正文、置顶及普通主楼层 | 当前正倒序及作者筛选；正文内部正序 |
| 楼层内嵌回复或回复讨论 | 当前主楼层全部楼中楼 | 讨论页当前顺序/作者；内嵌预览按原正序 |
| 动态正文 | 本动态完整配图 | 发布排序，从点击图片开始 |
| 动态一级评论 | 本动态一级评论图片 | 当前评论正倒序 |
| 动态评论回复 | 该根评论全部回复图片 | 当前回复阅读正序 |

只收普通已发布图片，重复 URL 保留独立出现位置，不含表情、头像、代码示例或本机待上传文件。点击立即显示已加载图片，完整范围通过独立双向游标加载；不会推进正文列表分页。当前来源通过单段位置“第 12 楼 · 2 / 3”表达，不将加载数量冒充总量。

双指沿手势中心缩放 1–5 倍，双击点击处放大 2 倍或复位。适屏时单指横拖跟手切换一张，下滑关闭；放大时只平移。两指减为一指不能在本次触摸转为切图或关闭；关闭按钮和系统返回始终可用。每次切图复位，首尾不循环。

普通关闭回到原阅读位置；来源按钮主动跳到当前图片所在楼层/评论。保存与收藏绑定当前来源，不使用最初点击项的闭包。动态动画继续保留播放失败状态和显式重试；相邻图片预取首帧，只让当前图片播放。

## 自动回归

真实 Pointer 手势覆盖双指缩放、平移、双指落单、双击位置、跟手翻页、首尾、下滑及前插分页与触摸竞争。独立 controller 覆盖双向分页、重复 URL、取消迟到、权限失效、版本冲突、索引未就绪与重试。共享 12 条正文 fixtures 覆盖贴纸、代码、转义、引用链接、对齐分段、实体与 Unicode；仓储测试使用 Dio 拦截器检查实际 GET 与不透明游标，没有访问线上写接口。

图片位置回调接入仍经过统一行内 builder：收藏表情沿用居中 WidgetSpan，普通图片保留原块尺寸和对齐。首轮完整门禁发现的统一入口注册回归已修复，原有布局门禁保留并复验。

所有本地测试使用假仓储或拦截的 HTTP；没有在线上创建账号、草稿、媒体、评论或进行签到。真实写入 E2E 仅由治理和 Backend 核验独立资源后执行；此处不把本地测试通过等同于已完成联网隔离验收。

后端部署后将来源固定为合并提交 `92b030a81f8957386e324fed477bd1e46faf65ea`，在冻结源码 `a1b9352252c4ca11c1d06b36b7c5e3a26f61bc76` 上执行 `npm run check:apk -- -TestConcurrency 2`，完整门禁**退出码 0**。4,665 项 Flutter 测试通过，1 项既有 Sentry 线上回执验收因未显式启用而跳过；18 项 Windows 工具测试通过。格式、应用及生成包分析、固定来源、API 重复生成、架构、21 个模块文档、消费端 API 覆盖 159/159 和 Debug APK 构建均通过。

生产契约现已精确通过：API/bundle `5.26.0-dev.20260922.3`、build `92b030a81f8957386e324fed477bd1e46faf65ea`，契约 Markdown 4、部署 Markdown 5 均在客户端支持范围，匿名 `GET /threads` Schema 兼容。治理任务另确认后端迁移及历史索引回填完成；移动端没有执行数据库操作或线上写入。

保留前轮记录：源码 `47471a8a0c206cb32e484bc286a0c6ff68d6f2cc` 使用 `-ContinueAfterFailure` 完整检查时退出码 **1**，唯一失败为生产 API `5.25.0-dev.20260922.1` / build `4850e2f456ccc452c763853641e3b2136901e237` 与候选 `5.26.0-dev.20260922.3` / `1f6a65e15dd66f88841bc80502f726804a07fa99` 不同。该结果不回写为成功，由本次完整检查消除阻塞。

首轮日志保留了两项实际失败（诊断端点索引漏生成、图片 builder 未注册统一行内入口）和当时公网 TLS 握手中断。两处源码问题修复后，使用上述冻结提交重新执行全部门禁，最终全量测试零失败。重点回归实际路径包括 `test/core/widgets/image_gallery_gestures_test.dart`、`content_image_viewer_page_test.dart`、`reading_gallery_occurrences_test.dart`，`test/features/media/reading_gallery_{controller,page,repository}_test.dart`、`test/features/threads/thread_image_gallery_test.dart`，以及动态动作、动画和页面测试。原有行内布局与对齐门禁保留，修复后 45 项相关回归另行通过。

## 首轮 Debug 候选包（已被二轮替代）

| 项目 | 结果 |
| --- | --- |
| 包名 | `site.wenyou.app.debug` |
| 版本 | `0.7.1-debug` / versionCode `95` |
| 构建源码 | `a1b9352252c4ca11c1d06b36b7c5e3a26f61bc76` |
| 大小 | `183539770` 字节 |
| SHA-256 | `fa7787e59d9b5dbb38f3c70d823e900642bed5012794c8dcca31472c48b1377b` |
| 本机归档 | `D:/code/wenyousite/artifacts/mobile-image-gallery/image-gallery-a1b93522-debug.apk` |

同目录 `candidate-a1b93522.json` 记录来源与摘要，`check-apk-deployed-a1b93522.log` 是本次全绿证据；旧 `candidate.json`、`check-apk-first.log`、`check-apk-final.log` 保留原轮次记录。本次重新构建的 APK 与旧候选字节相同：此间仅契约来源元数据与文档变化，应用代码没有变化。后续交付记录提交也不改变该受测源码。没有自动安装、发布或真机操作；本轮没有实测真机帧率、内存曲线和触控结果。

构建仍提示既有 `flutter_image_compress_common` Kotlin Gradle Plugin 未来 Flutter 兼容风险及 Android SDK XML 工具版本差异；当前构建成功，未借本切片扩展依赖升级。Debug 包不等同于正式签名包或正式应用更新。

## 负责人真机清单

1. 在五类入口分别点首张、中间、末张；验证图集范围、重复图片位置、倒序/作者筛选及楼中楼隔离。
2. 照片、长截图、透明图和 GIF 分别捏合、双击、平移、横滑、双指松一指再拖动；检查不会误切图或误关闭。
3. 慢网中先看到本图，继续滑到边缘加载；失败原位重试。单张图片失败仍能滑过；GIF 失败跨查看器不自动重试。
4. 主贴及非默认子贴正文分别点图，核对右上角为主题“跳到最新发言”同款指南针，点击后到所属子贴正文且不再报目标楼层变化；普通楼层、楼中楼及动态评论仍定位正确。普通关闭回到原滚动位置；切换图片后保存/收藏内容与来源一致。
5. 隔离环境中验证打开后内容编辑、删除、权限撤销；版本冲突要求重开，不可见和账号切换立即清除图片且迟到响应不恢复。
6. 长帖与九图检查内存、清晰度、切换帧率与动画停止；不得以自动手势测试替代真机触控和性能验收。

## 发布边界

依赖 [契约同步](image-gallery-contract-sync.md) 所列后端兼容迁移与历史索引回填。按“兼容后端 → 移动端”交付；不清理旧端点，不自动合并或部署。正式环境只做匿名只读烟雾，不能用测试账号写数据后再删除来冒充隔离。
