# 个人主页动画封面起播候选验收

状态：多播应用候选已通过完整门禁，负责人于2026-09-11确认个人主页起播与滚动连续性“观感符合预期，可以验收”。验收限于下述精确制品和个人主页场景，不扩大到Web实景或低端设备。下述300 ms／120 ms记录为已发生的历史，不代表现行产品规则。

## 已验收应用制品

正常应用入口`lib/main.dart`的Debug源码为`a0691d6f7a603a5a2cd9561e7a68678d29edc6ea`，tree `b8119a2a7b11ed8a0b17d31b510bdae937e2c652`。APK为`build/app/outputs/flutter-apk/app-debug.apk`，243,611,125 bytes，SHA-256 `A2D24DC7837ACB90964A5D37E2132B8F8651226992E493F64A05B0142F98A125`；`site.wenyou.app.debug`／温油站 Debug／`0.7.0-dev.1-debug`（94），最低API26，v2签名通过。根任务以ADB覆盖安装并核对设备`4b9c39b5`上的完整APK哈希一致，安装时间`2026-09-11 04:59:13`，未清数据。

同一冻结应用源码唯一`npm run check`退出码0：Flutter 2541通过、1项既有Sentry外部回执跳过、0失败（测试23分17秒），Windows工具17/17；OpenAPI验证及确定性再生成、生产API精确SHA、全库／生成API分析、891文件格式、21模块文档、架构与API覆盖全部通过。生产核验为API `5.20.0-dev.20260909.1`／后端`0ee2c0de1d9c570e495e778be6661b074b7a4bef`。日志`%TEMP%/wenyou-cover-multiplay-full-gate.log`。该验收记录提交仅记录外部验收事实，不改变当时已构建应用；后续整合源码与已验收应用SHA分开记录于PR14。

## 授权合并时的基线整合

2026-09-11负责人授权合并及任务清理。PR14纳入已合并dev `f88f81c7d2e9898c4883e79f0a0efa71214f2c13`：保留动态贴列表静止／详情播放、表情网格、富文本块边界与收藏管理入口；主题封面仍按本记录多播规则。冲突按双方行为合并，模块与契约来源采用最新Backend `8bf370f6ef5357535683aa6d3f8c03bd2d08d108`；收藏页回归同时保留新管理交互／Golden与封面生命周期。

原始Profile证据、已验收Debug／Profile APK及历史失败／通过日志已在删除Worktree前逐文件SHA-256归档到治理工作区`artifacts/cover-autoplay-merge-20260911/mobile`。整合后的完整检查与构建按PR14精确SHA另行记录，不沿用旧制品的全量结果，也不把旧真机验收扩展到整合APK；本次合并清理不覆盖安装用户手机、不正式发布。
## 本轮策略变更

负责人明确改为：所有至少半可见封面立即加载播放，无并播数量上限、不等待停稳；已经激活的封面只在完全离屏后停止。滚动时持续可见项保持时间线；重新进入从头播放并复用有效缓存。保留路由／后台／隐藏页／省流量／减少动态效果边界、原帧时长及有限循环。

旧 b163ff0 策略在新“三张半可见封面立即请求”回归中只请求中心一张而真实失败，证据为 Windows 临时日志 `wenyou-cover-multiplay-old-failure.log`。新增协调器 20 项同时激活、50%／0% 滞回、同帧滚动合并，真实个人主页／首页／收藏轻滑连续性、详情往返、分页、单卡改源／尺寸与批量 codec／帧回收测试。

Profile 专用 `site.wenyou.app.profile` 使用合成相同内容的 800×450 原 GIF（4,589,176 B）及 480×270 WebP（438,916 B），40 帧×50 ms、2秒无限循环。Windows loopback HTTP 经 ADB reverse 提供固定 80 ms 首响应延迟和每响应 8 MiB/s 的受控模型；不是生产 CDN 或公网测速。固定逻辑宽260，1／2／4张可见，仅改变视口高度，另测同 URL、2／4张快滑及持续浏览。

编码缓存冷／内存重入／清空内存后磁盘重入依次运行；缓存目录由 fixture 独立创建并仅清理自身。冷只指专用动画编码缓存，静态 poster 的缓存状态另计。4个原 GIF 总量超过16 MiB，内存淘汰和待写两项预算可能导致重入请求，统计保留真实行为。每组结束先卸载并取消，再等待请求结算，未结算标记 `httpSettled=false`。原始数据记录请求与响应体 bytes、load／完整bytes／首帧decoded／包含RawImage的帧完成绘制时点；painted不是显示屏扫描完成，也不保证像素运动（原首帧时长仍完整保留）。Flutter build/raster 帧时间按设备120Hz与60Hz预算分别汇总，不等于屏幕精确丢帧数；ADB约2秒采样PSS只报告观察到的峰值。

已通过126项相关回归（含真实首页／收藏／个人主页与全部编码缓存边界）、受影响静态分析、21模块文档及架构门禁。上述为Profile测量前相关批次记录；最终Debug APK与唯一完整检查结果见PR交付记录，均不代替负责人真机验收。Profile manifest只允许127.0.0.1的明文HTTP，其他域名保持禁止；正式应用配置未改变。

运行命令（设备操作由根任务执行）：

```powershell
flutter drive --driver=test_driver/performance_test.dart --target=integration_test/cover_animation_performance_test.dart --profile --no-dds --device-id=4b9c39b5 --dart-define=COVER_BENCHMARK_BASE_URL=http://127.0.0.1:18764
```

输出 `build/integration_response_data.json` 保留 watchPerformance 每组原始 frame_build_times／frame_rasterizer_times；`coverCases` schemaVersion1 每项包含 caseId、group、mode、format、visibleCount、logicalCoverWidth、devicePixelRatio、startedEpochMs／endedEpochMs、events、httpBefore／httpAfter／httpSettled。只有相应真实运行完成后才补性能结论。16 MiB编码缓存不限制所有活动codec、帧和在途响应内存；多播代价需实测，不把取消中心单张限制描述为免费优化。

## 受控 Profile 实测结果

根任务在设备 `4b9c39b5` 运行独立 Profile，28组全部完成、exit0，所有HTTP快照完成结算。源码 `af4a4971d17dc46996f0a7566b0ae28e9079dfae`／tree `8291350d6986e50a9530a5f9610f842238a11a10`；后续只有测试与结果文档变化，应用实现与该实测版本一致。Profile APK SHA-256 `65D8A967E106C6DB4A9540664F1E2D7A3FE2447AE718650EAF4B38400229D5EC`，设备安装文件已由根任务独立核对。

原始产物目录为 `build/cover-autoplay-perf-root/run-20260911-043454/`，保留 `integration_response_data.json`、`summary.json`、`memory-samples.jsonl`、`profile-drive.log` 与 `completion.json`。原始 JSON SHA-256 `BA35EC26D8A480D691773BD9A811C1CD1296D52D7A9CF0EE640A039BCD50189E`，修正摘要 SHA-256 `81AF6DB661323110DC5EE60BB1E9DC254F41812F517CB6DB4265439EDA1D597D`。

起播口径使用每个初始卡片的 `load` 到 `painted`，下表取这些初始卡片中的最大值。Flutter SDK `watchPerformance` 在 action 前固定等待2秒冲刷旧 FrameTimings，因此原始 `firstPaintInitialMaxMs` 包含测试器等待，不能当作实际起播延迟。`memory` 只是保留编码内存后的重入，仍允许磁盘兜底；`disk` 是清空编码内存后的重入，也不保证每项已经成功持久化。

| 资源／可见数 | 冷缓存 load→paint 最大值 | 保留缓存重入 | 清内存重入 | 冷动画请求／响应体bytes | 冷组采样PSS峰值 |
| --- | ---: | ---: | ---: | ---: | ---: |
| WebP／2 | 174ms | 34ms | 49ms | 2／877,832 | 179.76MiB |
| 原GIF／2 | 716ms | 34ms | 215ms | 2／9,178,352 | 225.16MiB |
| WebP／4 | 175ms | 33ms | 241ms | 4／1,755,664 | 189.41MiB |
| 原GIF／4 | 791ms | 131ms | 896ms | 4／18,356,704 | 263.04MiB |

同URL四卡只发生一次动画请求，各codec仍独立。清内存四卡组均有两次网络请求，与最多两项待写预算一致；四原GIF超过16MiB，保留缓存重入零HTTP不代表全部纯内存命中。此合成内容的预览字节比原图少约90.4%，并非所有用户GIF都会达到该压缩率。

两张快速滚动压力组WebP为28次／12,289,648 bytes，原GIF为98次／449,739,248 bytes；四张为25次／10,972,900与106次／486,452,656 bytes。测试每150ms发起一次跨3卡滚动（100ms完成），约49次滚动动作在20项间多次往返，不是普通浏览速度。大文件频繁在完成前离屏取消，因此不进入完整编码缓存，重入又请求。以上bytes是服务端写进HTTP／ADB socket的量，不证明已全部送达手机，更不能换算普通用户每分钟资费；未测真实CDN回源或公网计费。持续组在快滑之后复用同一组缓存，WebP新增0字节、原GIF新增5个文件约22.95MB，也不能误称冷启动持续浏览结果。

补充Windows生产Source的真实慢流回归：最后订阅取消后调用IOAdapter.close(force:true)，客户端onReceiveProgress停止且保持不变，不产生完整缓存文件。首次用服务端flush必须失败作为断言的尝试真实失败，因为服务端仍可接受缓冲写入；保留 `wenyou-cover-transport-cancel.log`，最终客户端观测回归 `wenyou-cover-transport-cancel-final.log` 通过。该证据支持应用取消链有效，但不将取消前后的网络缓冲费用声称为零。

本机28组的Flutter build/raster阶段超过16.67ms比例均为0；超过8.33ms仅双原GIF持续组为0.281%，其他组为0。fixture按16ms pump驱动采样，未采集平台实际present／丢帧计数，不能据此宣称真实个人主页稳定120fps。PSS是独立Profile整个进程、约2秒采样观察峰值；缓存、组次顺序及meminfo触发的Explicit GC（日志约8–24ms）均可能影响结果。USB充电，结束电量34%、温度33.9°C；只在这一台设备和合成素材上测量，不能推广到低端机或所有GIF。

负责人已在上述最终Debug上验收个人主页起播与滚动连续性。测试未修改产品多播规则、帧率或缓存预算，未安装正式包或携带真实账号数据；根任务已停止本轮HTTP／PSS采样并移除本轮专属ADB reverse。

## 历史候选与验收反馈

负责人在已核对安装 APK 的 `00cd85b77bf0f4751b6d7f16ce4351fe2443b552` 候选上，反馈个人主页列表滑动停顿后“停稳后静止一会儿才开始播放”；已明确不是播放开始后的跳帧。原 APK SHA-256 为 `0A319CBE805FB3BDC60AEDC2F97077F066CACCA3697F8F11BC141E9A1A058149`，包名 `site.wenyou.app.debug`。期望在滑动真正停止后更快看到动画开始。

已证实的实现原因：旧调度在 ScrollEnd 后固定等待 300 ms 才启动资源加载及首帧解码，相关准备完全串行；其他动画 poster 注册又重置等待。内存命中仍等待磁盘 touch，完整网络响应也等待持久化 put 返回。未获得负责人具体 GIF 原始文件、URL 或分段耗时，不能断言该次真机延迟各阶段占比。

回归先在旧实现运行“200 ms 时边缘 poster 注册”的样例，300 ms 时中心仍未选中，测试真实失败。候选将唯一候选准备与 120 ms 稳态确认并行，注册同帧合并，只有候选变化才重新计时；切换前同步释放旧租约。准备时解出第一帧但不推进时间线，真正播放后才计算原帧延迟。

测试分开核对准备调用、首帧就绪与真正激活：受控样例在80 ms交付文件并用真实两帧GIF解码，120 ms激活，无第二次加载；再经过原首帧100 ms才显示下一帧。该样例不代表真实网络请求必在0 ms发出，也不保证所有GIF在120 ms出现可见运动。冷磁盘查找、网络、解码及GIF自身首帧时长仍有实际成本。

缓存测试用未完成的 touch／put 验证可用字节返回不等待，验证晚到持久化失败、失效及切换账号不能写回旧数据；队列限制两项／32 MiB，touch合并为一项。保留冷磁盘命中路径，不通过绕过缓存额外下载来换延迟。

真实 PublicUserPage 回归使用预解码静态poster及记录请求的动画来源，经过生产卡片、CustomScrollView与Tab控制器，覆盖同一卡片轻滑停止后唯一准备、分页追加不重启、详情返回的secondary转场期间禁止准备、转场完成自动恢复及Tab切换。它隔离了图片服务耗时，不能代替原真机资源测速。

负责人复验：在新的候选 Debug 包进入原个人主页，用同一动画重复轻滑停下，再测试首次进入、连续换卡片、详情返回和切换Tab。记录冷／热缓存体感、省流量、后台恢复；出现慢起播时保留原GIF及操作顺序以分段测量。正式判定仍需负责人明确反馈，自动测试与构建不能替代验收。
