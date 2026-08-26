# 移动端性能基线

性能结论只来自 Android 真机 Profile 构建。Debug 使用 JIT、断言、调试服务和额外检查，适合热重载与定位问题，但不能作为动画是否流畅的验收依据。Release 不开放诊断连接；仓库因此使用独立 `site.wenyou.app.profile` 包采样，避免覆盖正式 `site.wenyou.app` 或日常 `site.wenyou.app.debug`。

## 运行入口

在 Windows 本地开发机连接一台已解锁 Android 真机后运行：

```powershell
npm run perf:android -- -DeviceSerial <serial>
```

脚本不修改设备刷新率，也不访问公网业务数据。它以固定离线内容依次覆盖外观切换、标准页面进出、动态卡片流滚动和 Markdown 长时间线滚动，预热后执行三轮 Profile 采样；每轮保存 Flutter build/raster 原始帧时间，最终报告写入 `build/performance/<timestamp>/summary.json`。脚本结束时重新安装专用 Profile APK，供维护者继续非破坏性目测；Debug 与正式包保持原样。

## 阻断预算

60 Hz 是当前强制门禁：每个场景三轮中位数必须同时满足 build 与 raster 的 p90 不超过 8 ms、p99 不超过 16.7 ms，且 build 或 raster 超过单帧 16.7 ms 的帧比例不超过 1%。设备实际刷新率会写入报告，但高刷新率结果当前只作观察，不替代 60 Hz 门禁，也不自动更改系统显示设置。

失败时先查看具体场景的 build/raster 分布：build 偏高通常意味着同步重建、布局或解析过多；raster 偏高通常意味着过度绘制、裁剪、阴影、图片解码或昂贵合成。先在 Profile 中复现并用 DevTools 时间线定位，不能仅因 Debug 目测卡顿就删除有明确交互价值的共享转场。

## 当前真机基线

2026-08-26 在 Xiaomi 2509FPN0BC、Android 16、60 Hz、Impeller、Flutter 3.44.8 上完成三轮采样，四个场景全部通过。外观切换的中位数为 build p90/p99 `2.914/4.714 ms`、raster p90/p99 `2.773/4.381 ms`，超预算率 `0%`；标准导航、动态流和 Markdown 时间线也都满足门禁。机器可读结果见 [`tool/performance/android_profile_baseline.json`](../../tool/performance/android_profile_baseline.json)。该文件记录机型与运行时，不记录设备序列号、账号或业务数据。

性能基线用于阻止明确退化，不代表所有真实页面已完成主观手感验收。涉及新动画、复杂图片、编辑器或长列表的切片仍需在目标真机用 Profile 包复查对应路径，并保留“减少动态效果”零时长行为。
