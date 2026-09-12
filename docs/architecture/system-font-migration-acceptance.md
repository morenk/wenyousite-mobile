# 系统字体迁移候选验收

## 范围与基线

本切片仅修改 Windows Mobile，基于 `origin/dev` 的 `3758186fc66e643af9283ffc8a39da2f33d0abfb`。Foundation 正式 `v7.0.0` 的 annotated Tag 对象为 `9e14521ce83c2488a418c850b948bc7b6aee4ee1`，peeled commit 为 `a3f722bb9514712ff857065cd210c91414e907e4`；`pubspec.lock` 必须解析到后者。公网 Backend 为 `6fdfa00eaf1f3056ba30f2ffbc529d12eed1c823`、契约 `5.22.0-dev.20260912.2`，与当前源码契约一致，本切片不同步或修改 Backend。

迁移只移除 Noto Sans SC、LXGW WenKai 和 Nunito 三套生产 UI 字体。body/display/utility 继续表示正文、展示层级和数字语境，字号、行高和字重映射不变；utility 继续启用 tabular figures。KaTeX、显式 `monospace` 与 Material Icons 是功能依赖，不在删除范围，也不引入 `system-ui` 作为 Flutter 家族名。品牌文字继续使用 display 语义与系统字体，不新增字标。

## Release 包体基线

同一源码、版本、签名和 ARM64 单 APK 配置下，修改前 Release 为 52,590,637 字节，SHA-256 为 `0703397c1e72babb4ffe318f09986fd53d49814b63133a2e10bd3e1046ab8881`。ZIP 中三套字体分别为 17,772,300、13,700,636 和 276,932 字节；另有 tree-shake 后的 `MaterialIcons-Regular.otf` 2,532 字节。

修改后 Release 为 32,942,803 字节，SHA-256 为 `0ebc604b725c84401ed8611a3efb8cf3c63db6bc3e60c41ac8738023f61b7e8d`，比基线减少 19,647,834 字节（37.36%）。Release APK 保持 `site.wenyou.app`、`versionCode=94`、`versionName=0.7.0-dev.1`、`minSdk=26`、`targetSdk=36` 和 ARM64 单 ABI。ZIP 扫描只有 82 字节的 `FontManifest.json` 与 tree-shake 后 2,532 字节的 `MaterialIcons-Regular.otf` 两个字体相关条目，旧三套 UI 字体与测试字体均为 0 个。

仓库外候选制品为 `D:\code\wenyousite\artifacts\system-font-mobile\20260912\candidate-system-font-app-release.apk`；同目录 Debug 候选为 `candidate-system-font-app-debug.apk`，183,169,122 字节，SHA-256 为 `44ba610aaaaaaf6638dd66ab1da789f78c2ec835a4b88c149a24b7e2e16188dd`。两者均不提交、不上传、不发布。

## 自动验证与 Golden 审查

Widget/Golden 使用 `test/support/fonts/WenyouGoldenText-Variable.ttf` 确定性子集；测试运行时将它注册为 Flutter 测试默认的 `Ahem`、Material 默认的 `Roboto` 与显式 `monospace`，另加载 Flutter SDK 的 Material Icons。字体及许可证不声明到 `pubspec.yaml`，发布门禁同时拒绝旧三套 UI 字体和测试字体出现在 APK。

自动验证覆盖 320dp 下 100% 与 200% 文字缩放的代表性布局；重点审查长标题、按钮、数字计数、中英数字与 Emoji 混排、Markdown 行内代码／提及／表情及编辑器基线。迁移产生 52 张严格像素差异候选；逐张审查候选后更新对应测试，同文件中另有 12 张容差内收藏管理面板基准被重写并补充逐图审查，共 64 张实际变更 Golden。独立复跑 33 个直接声明 Golden 的测试文件、326 个用例全部通过；随后对通过辅助 cases 注册 Golden 的 5 个真实测试根按 15 个精确用例名复跑，也全部通过。未发现新增裁切、按钮溢出、行内元素阶梯错位或点击区变化。

最终完整 `npm run check` 通过：契约验证、975 个 Dart 文件格式检查（0 变更）、应用与生成 API 包静态分析（0 问题）、架构边界、21 个模块文档、移动端 API 覆盖 154/154、Flutter 4,367 项测试（另 1 项按预期跳过）及 Windows 发布工具 17/17 均通过。

## 负责人真机验收清单

当前状态为“候选／待负责人验收”。自动测试不能模拟设备实际系统字体，负责人需在本任务候选 APK 上完成：

1. Android 8 与一台较新 Android，分别保持 100% 和系统最大文字缩放。
2. 至少两种厂商系统字体，覆盖首页长标题、主题详情、按钮、弹层、设置与管理页。
3. 打开含中文、英文、数字和 Emoji 的正文，检查换行、基线、裁切及 48dp 点击区。
4. 打开 Markdown 行内代码、提及、表情、骰子与长引用，并进入编辑器输入、保存、重开。
5. 检查启动页和认证页品牌文字仍保持 display 层级，没有新增图片字标或缺字。

负责人明确反馈前，不把跨 Android 版本和厂商字体兼容性记为已通过。
