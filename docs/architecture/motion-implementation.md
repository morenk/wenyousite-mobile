# 动效实现与复用边界

本文件记录 Mobile 的代码入口和验证范围，不定义第二套跨端视觉规范。颜色、密度、时长和曲线的事实源是固定发布依赖 Foundation `v7.6.0`。当前性能改动为候选／待负责人验收，详见[性能验收记录](mobile-performance-candidate.md)。

## 全项目入口矩阵

| 入口 | 共享实现／处理 | 边界 |
| --- | --- | --- |
| 全屏加载、局部列表、按钮、图片、字体、音频忙碌 | `WenyouCircularProgressIndicator` / `WenyouLinearProgressIndicator` | 独立重绘；减少动画暂停循环 ticker；真实 value 继续更新；未知值保持 null，禁止假百分比 |
| 首页、主题、动态、搜索、私信、通知、个人页等下拉刷新 | `WenyouRefreshIndicator` | 保留原生手势和 Future 生命周期；减少动画用 noSpinner 加静态忙碌提示，不暂停整个刷新控制器；失败仍由原业务界面负责 |
| 页面路由 | `wenyou_page_transitions.dart` | 现有 Foundation standard／fast 与减少动画分支，保留返回手势和栈语义 |
| 抽屉、菜单、弹层、键盘避让 | 现有共享弹层与 `wenyouMotionDuration` | 统一策略；编辑器／资料页避让时长取 Foundation，减少动画归零；没有添加等待延时 |
| 按钮按压、音频切换、内部引用 | 现有共享控件与 `wenyou_motion.dart` | 复用 fast／standard、标准曲线；减少动画不缩放／不补间；焦点、读屏、真实播放状态保留 |
| 图片查看器翻页收尾 | `wenyou_image_viewer_page.dart` | 普通使用 standard，减少动画直接 jumpToPage；拖动本身仍跟随手势 |
| 表单错误定位 | 编辑器／个人资料现有 ensureVisible | 使用 standard 与共同减少动画判断，不隐藏校验错误、不制造保存进度 |
| 主题／回复目标定位与最后收尾 | `DiscussionTargetCover` / `DiscussionTargetLoading` | 正文与循环指示器隔离重绘，现有几何稳定和 Foundation 淡出逻辑保留；无假进度、无额外强制等候 |
| 字体加载和正文更新 | 字体服务、队列、完整性 helper、Markdown builder | 复用已解析身份；大 SHA 校验离开 UI isolate；手势生命周期稳定。原有字库预算、撤回、离线与安全校验不变 |
| 图片处理和上传完成 | 媒体 normalizer、原有上传状态 | 复用可信内存 PNG，仍验证最终资产；网络请求、取消、失败、重试与发布幂等不变 |
| 阅读滑块、快捷滚动 | `ReadingScrollSpec` 与原阅读控制器 | Mobile 独有，沿用其手感与减少动画状态机，本轮不改尺寸／唤醒阈值／延时，不为此发布 Foundation |
| 排序、筛选、临时目标描边 | 现有共享组件 | 已有 Foundation 与减少动画分支；不顺带重写业务状态机 |

这张表区分已存在的共享实现和本轮修改；不是每个页面真机视觉验收通过的声明。自动测试覆盖几何、点击、减少动画、加载生命周期及既有 Golden，实际设备掉帧仍需负责人复验或独立 Profile 测量。

## 防止分散实现

`tool/architecture/presentation_checks.dart` 只允许两份共享文件直接构造原生 ProgressIndicator / RefreshIndicator，业务页面和其他共享组件必须走公共入口。既有异步按钮和 feature spinner 预算检查识别新的包装名称，不能借迁移绕过原规则。静态检查只能保证入口，不保证真实设备帧率。

新增定时／隐式／控制器动画仍需核对 Foundation 时长、共同减少动画判断，以及销毁时停止监听。网络与资源等待不能用动画长度遮盖，也不能把完成动画当作业务成功依据。

## Web 行为交接

下列是需由 VPS Web 任务按自身技术实现审查的行为，不代表 Mobile 已修改或验证 Web：

- 保存成功采用已确认的完整响应及时更新当前内容，旧请求不得覆盖新版本；权限撤回与账号变化仍清空不可见数据。
- 已解析字体身份复用，避免一个无关下载串行阻塞已加载内容；保留撤回、完整性、预算和失败重试语义。
- 重复字体／正文更新不累积事件监听；页面卸载释放监听和定时器。
- 循环忙碌动画尽量限制重绘范围，大计算不阻塞交互；按浏览器 profiling 证据验证，不照搬 Flutter RepaintBoundary。
- 减少动画下保留静态忙碌及真实进度、刷新生命周期；完成依据业务结果与布局稳定，禁止假百分比或人为等候。
- 目标定位最后阶段不闪回错误位置；路由、弹层、按钮、媒体、字体和表单反馈复用已发布 Foundation。

Mobile 专属实现包括 Flutter isolate、引擎 PNG 的进程内不可变标记、Flutter 图层／ticker、Android 独立候选包和 ReadingScrollSpec。Web 不需要逐字移植这些机制；若发现需要新共享契约，应由 Foundation 独立任务发布正式 Tag 后再消费。
