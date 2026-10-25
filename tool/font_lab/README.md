# Android 离线字体实验

本工具不是温油站入口。独立包 `site.wenyou.fontlab` 使用 `tool/font_lab.dart`、本目录的 `MainActivity.kt` 与 `tool/text_font_memory_vm.dart`；只读取本地正式字体、调用真实 FontLoader、采集本进程 VM/Android 内存并写入私有 `code_cache`。不导入应用 main、账号恢复或业务仓储，不改变整机网络。

临时 Flutter 工程位于 `.dart_tool/fontlab`，通过 `flutter create --platforms android --org site.wenyou --project-name fontlab --no-pub` 创建。其 pubspec 以 `../..` 引用本仓包以复用清单解析，声明 `assets/manifest.json` 和 `assets/fonts/`。当前目录 1.2.0 只放对应的 868 个 Mobile 资源（184,645,488 B），不得用此实验打包方式修改产品 pubspec。复制本目录 Activity 到实验工程 `android/app/src/main/kotlin/site/wenyou/fontlab/`。

实验 Android 配置为 compileSdk 37、minSdk 26、Java 17、`coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")`，`ndk.abiFilters` 仅 `arm64-v8a`。在实验工程内构建：

```powershell
D:\sdk\flutter\bin\flutter.bat pub get
D:\sdk\flutter\bin\flutter.bat build apk --debug --target-platform android-arm64 --target ../../tool/font_lab.dart
```

安装前用 aapt 核对包名和 ABI、记录 APK SHA-256；安装后核对该包更新时间与设备内 base.apk SHA。设备安装器拒绝时停止，等待用户明确允许，不能绕过设备限制。`am start -n site.wenyou.fontlab/.MainActivity --es font_lab_mode typical` 执行常用字符模式；`all` 执行全集压力模式。每个实验内部连续浏览实际 manifest 全部字体和五轮返回，结果记录 manifest SHA 与字体数量。测试间只停止本任务的 FontLab，不重启温油站引擎来伪装回收。`visual` 单独加载流江毛草、DotGothic16 和 Great Vibes 并保留实际画面，用于三语言效果截图，不运行内存压力循环。

结果通过 `run-as site.wenyou.fontlab cat code_cache/font-lab-typical.json` 或 `font-lab-all.json` 读取，另记录同 PID 的 `dumpsys meminfo` 与屏幕。最终屏幕在移除自定义字体 Widget 后显示默认文字，属于完成证据，不能标成 29 款字体效果。输入字节、Dart heap/external、Android native heap、PSS、RSS 分别解释，不把进程总内存等同字体内存。

2026-10-22 旧 29 款 APK、初次安装拒绝和成功重试、两个 PID 的原始记录保留在 `.dart_tool/thread-font-native-memory/android/`；当前 28 款测量与效果模式分别保存在 `android28/`，不能混用 APK 哈希或把旧目录改名。结论与边界见 `docs/architecture/thread-fonts-mobile-continuous-loading.md`。生产 service/scope 的验证由 `tool/preview_thread_font_continuous_test.dart` 独立承担。
