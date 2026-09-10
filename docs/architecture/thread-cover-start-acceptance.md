# 个人主页动画封面起播候选验收

状态：负责人已更改播放策略；多播候选实施及 Profile 验证中，待个人主页真机复验。下述 300 ms／120 ms 记录为已发生的历史，不代表现行产品规则。

## 本轮策略变更

负责人明确改为：所有至少半可见封面立即加载播放，无并播数量上限、不等待停稳；已经激活的封面只在完全离屏后停止。滚动时持续可见项保持时间线；重新进入从头播放并复用有效缓存。保留路由／后台／隐藏页／省流量／减少动态效果边界、原帧时长及有限循环。

旧 b163ff0 策略在新“三张半可见封面立即请求”回归中只请求中心一张而真实失败，证据为 Windows 临时日志 `wenyou-cover-multiplay-old-failure.log`。新增协调器 20 项同时激活、50%／0% 滞回、同帧滚动合并，真实个人主页／首页／收藏轻滑连续性、详情往返、分页、单卡改源／尺寸与批量 codec／帧回收测试。

Profile 专用 `site.wenyou.app.profile` 使用合成相同内容的 800×450 原 GIF（4,589,176 B）及 480×270 WebP（438,916 B），40 帧×50 ms、2秒无限循环。Windows loopback HTTP 经 ADB reverse 提供固定 80 ms 首响应延迟和每响应 8 MiB/s 的受控模型；不是生产 CDN 或公网测速。固定逻辑宽260，1／2／4张可见，仅改变视口高度，另测同 URL、2／4张快滑及持续浏览。

编码缓存冷／内存重入／清空内存后磁盘重入依次运行；缓存目录由 fixture 独立创建并仅清理自身。冷只指专用动画编码缓存，静态 poster 的缓存状态另计。4个原 GIF 总量超过16 MiB，内存淘汰和待写两项预算可能导致重入请求，统计保留真实行为。每组结束先卸载并取消，再等待请求结算，未结算标记 `httpSettled=false`。原始数据记录请求与响应体 bytes、load／完整bytes／首帧decoded／包含RawImage的帧完成绘制时点；painted不是显示屏扫描完成，也不保证像素运动（原首帧时长仍完整保留）。Flutter build/raster 帧时间按设备120Hz与60Hz预算分别汇总，不等于屏幕精确丢帧数；ADB约2秒采样PSS只报告观察到的峰值。

已通过126项相关回归（含真实首页／收藏／个人主页与全部编码缓存边界）、受影响静态分析、21模块文档及架构门禁。唯一完整检查与最终Debug APK留待受控Profile测量及结果文档收敛后执行；此处不代替负责人真机验收。Profile manifest只允许127.0.0.1的明文HTTP，其他域名保持禁止；正式应用配置未改变。

运行命令（设备操作由根任务执行）：

```powershell
flutter drive --driver=test_driver/performance_test.dart --target=integration_test/cover_animation_performance_test.dart --profile --no-dds --device-id=4b9c39b5 --dart-define=COVER_BENCHMARK_BASE_URL=http://127.0.0.1:18764
```

输出 `build/integration_response_data.json` 保留 watchPerformance 每组原始 frame_build_times／frame_rasterizer_times；`coverCases` schemaVersion1 每项包含 caseId、group、mode、format、visibleCount、logicalCoverWidth、devicePixelRatio、startedEpochMs／endedEpochMs、events、httpBefore／httpAfter／httpSettled。只有相应真实运行完成后才补性能结论。16 MiB编码缓存不限制所有活动codec、帧和在途响应内存；多播代价需实测，不把取消中心单张限制描述为免费优化。

## 历史候选与验收反馈

负责人在已核对安装 APK 的 `00cd85b77bf0f4751b6d7f16ce4351fe2443b552` 候选上，反馈个人主页列表滑动停顿后“停稳后静止一会儿才开始播放”；已明确不是播放开始后的跳帧。原 APK SHA-256 为 `0A319CBE805FB3BDC60AEDC2F97077F066CACCA3697F8F11BC141E9A1A058149`，包名 `site.wenyou.app.debug`。期望在滑动真正停止后更快看到动画开始。

已证实的实现原因：旧调度在 ScrollEnd 后固定等待 300 ms 才启动资源加载及首帧解码，相关准备完全串行；其他动画 poster 注册又重置等待。内存命中仍等待磁盘 touch，完整网络响应也等待持久化 put 返回。未获得负责人具体 GIF 原始文件、URL 或分段耗时，不能断言该次真机延迟各阶段占比。

回归先在旧实现运行“200 ms 时边缘 poster 注册”的样例，300 ms 时中心仍未选中，测试真实失败。候选将唯一候选准备与 120 ms 稳态确认并行，注册同帧合并，只有候选变化才重新计时；切换前同步释放旧租约。准备时解出第一帧但不推进时间线，真正播放后才计算原帧延迟。

测试分开核对准备调用、首帧就绪与真正激活：受控样例在80 ms交付文件并用真实两帧GIF解码，120 ms激活，无第二次加载；再经过原首帧100 ms才显示下一帧。该样例不代表真实网络请求必在0 ms发出，也不保证所有GIF在120 ms出现可见运动。冷磁盘查找、网络、解码及GIF自身首帧时长仍有实际成本。

缓存测试用未完成的 touch／put 验证可用字节返回不等待，验证晚到持久化失败、失效及切换账号不能写回旧数据；队列限制两项／32 MiB，touch合并为一项。保留冷磁盘命中路径，不通过绕过缓存额外下载来换延迟。

真实 PublicUserPage 回归使用预解码静态poster及记录请求的动画来源，经过生产卡片、CustomScrollView与Tab控制器，覆盖同一卡片轻滑停止后唯一准备、分页追加不重启、详情返回的secondary转场期间禁止准备、转场完成自动恢复及Tab切换。它隔离了图片服务耗时，不能代替原真机资源测速。

负责人复验：在新的候选 Debug 包进入原个人主页，用同一动画重复轻滑停下，再测试首次进入、连续换卡片、详情返回和切换Tab。记录冷／热缓存体感、省流量、后台恢复；出现慢起播时保留原GIF及操作顺序以分段测量。正式判定仍需负责人明确反馈，自动测试与构建不能替代验收。
