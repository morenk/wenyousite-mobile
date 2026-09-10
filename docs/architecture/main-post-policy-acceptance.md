# 主贴发言权限候选验收

状态：候选／待负责人验收。用户未授权合并或发布，本次不操作真机、不向公网写入测试数据。

## 行为和视觉

- 已发布主题设置在招募状态、可见范围之后增加主贴发言权限，沿用现有设置行、选择列表、文字角色与间距。页面仍自动保存。
- 实际权限从默认子贴回填；楼主和协作者可选择所有参与人、仅协作者或仅玩家。玩家策略仍允许楼主和协作者发言。
- 默认子贴版本、正文、标题、标签与权限走同一聚合写入。关闭选择列表或重复选中不写入；创建流程、未发布主题入口和其他子贴策略不变。
- 空保存后后续修改不能被旧 Future 吞掉：原协调器在“无修改切换子贴页签再返回，选择权限”路径会不发保存请求。本次最小修正登记顺序，单元回归已确认旧实现失败；候选与原始失败日志分别保留在 `build/main-post-policy-targeted.log`、`build/main-post-policy-autosave-before.log`。

## 契约和环境

- 后端固定 `88ad7be52722c2fa2810515badd2a2ec4d2d2cfd`，契约 `5.21.0-dev.20260911.1`；Foundation 固定最新正式 `v6.9.0`，共享说明见 Foundation 主贴设置 PR。
- 本地 OpenAPI 生成、模型序列化、仓储／控制器／Widget 回归使用固定契约及隔离的测试替身。公网当前仍为已部署旧版，不能用线上请求验收尚未部署的新字段。
- 缺少隔离测试数据库，真实 HTTP 事务和跨端联网组合待补验。自动测试、Golden 与 APK 构建不能替代负责人真机验收。

## 负责人真机验收清单

1. 在兼容后端就绪后安装候选 Debug 包，确认打开包名 `site.wenyou.app.debug` 的应用。
2. 楼主进入已发布主贴设置，核对与招募状态、可见范围的行高、字体、箭头和选择方式一致；检查小屏、系统大字体与完整选项说明。
3. 三种策略逐一修改，待保存完成后退出并重开；Web 查看同一主贴应一致。仅玩家时玩家、楼主和协作者可发主贴楼层与楼中楼，未标记普通用户不可发；仅协作者时普通玩家也不可发。
4. 用协作者重复修改权限；确认可见范围仍只有楼主可改。普通用户无管理入口，其他子贴的原权限不变。
5. 输入标题后立即修改权限，确认同一次自动保存完成。无改动先切子贴页签再返回，修改权限仍能保存。请求中快速换选项，最终重开值应为最后选择。
6. 关闭选项列表及重复选择当前值不产生修改；断网保存失败保留选择并可重试，返回时可继续编辑或明确放弃。
7. 两端同时编辑造成版本冲突，分别检查保留本机输入、载入最新版与明确覆盖。保存成功返回详情后检查最新发言能力；退出登录再用普通用户进入不得沿用管理者能力。
8. 新建主题与未发布草稿流程保持原样。

## 本地验证

- 全量 Flutter：2471 项通过、1 项既有外部回执测试跳过；Windows 工具：17 项通过。原始完整门禁日志为 `build/main-post-policy-check.log`。
- 权限、仓储、控制器、自动保存与整页 Golden 定向复验：49 项全部通过，日志 `build/main-post-policy-targeted-final.log`。测试辅助代码按门禁拆为普通 library 后复验，没有重跑已通过的其他模块。
- OpenAPI 校验、再生成一致性、生成包分析、格式和 21 模块文档检查通过；API 排除清单核对 216 个 operationId 没有变化后更新版本，覆盖复验通过，日志 `build/main-post-policy-coverage-final.log`；架构复验通过，日志 `build/main-post-policy-architecture-final.log`。
- 完整门禁首轮的样式、测试 library 结构和覆盖清单问题均保留原失败日志并逐项修正复验；公网版本仍与候选不同，完整门禁不能标为绿色，也未为通过门禁部署或修改公网。
- 360dp 完整设置页及 320dp 两倍字号完整选项 Golden 均已查看，选项和相邻设置使用同一控件，无布局溢出。Golden 位于 `test/features/threads/goldens/thread_management_settings_360.png` 与 `thread_management_policy_320_text_2x.png`；这些是测试渲染证据，不是负责人真机验收。
- 稳定源码应用分析复验零问题，日志 `build/main-post-policy-analyze-final.log`。
- 首轮 APK 因同机多任务令可用内存低至约 192 MiB，核对本任务 PID 后主动取消，原日志 `build/main-post-policy-apk-cancelled.log` 保留；随后串行 Debug APK 构建成功（327 秒），日志 `build/main-post-policy-apk.log`。仅有既有 Kotlin 插件兼容提示，没有调整依赖或构建配置。

## APK 候选

- 文件：`build/app/outputs/flutter-apk/app-debug.apk`，203742454 字节。
- 包名：`site.wenyou.app.debug`；实际 APK 版本 `0.7.0-dev.1-debug`，versionCode `94`，最低 API `26`。
- SHA-256：`231f99a5c80489d0ad524bcb5ab0ea87fccf5bee90359c6271e13e35a5a42c0c`。
- `aapt dump badging` 核验包名与版本，`apksigner verify --verbose` 验签通过（v2，一位签名者）。未安装到真机，未发布到对象存储。
