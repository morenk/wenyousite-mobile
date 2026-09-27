# Android 0.8.0+97 正式版发布验收

## 范围与状态

2026-09-27 负责人指定正式版本 `0.8.0+97` 并确认后台文案，授权准备及后续正式发布。当前为签名候选准备：沿用 PR #73 的一次更新说明弹窗、14sp 紧凑正文和固定底部按钮，移除版本开发后缀、保留构建号；按同批紧急反馈将通知唯一删除操作直接呈现在通知行尾部。未上传、晋级或打 Tag；最终真机冒烟由负责人手动执行。此前未验收缺口按各原记录保留，不由本轮自动检查代替。

## 事实源与门禁

Foundation 保持最新正式 `v7.2.1`；Backend 固定已部署 `1d43b85f7aa8cd1ab03f6ab34f1851462e1a0021` / `5.27.0-dev.20260927.1`。未部署的跨仓文档修订不改变 strict production source。

治理已通过专用受限 SSH 的真实 `--preflight`，绑定 Android / `0.8.0` / 97 / confirmedRevision 1。该证据独立保存；`BuildOnly` 原生摘要的 `notesConfirmedRevision` 为 null，不改写成脚本未执行的预检结果。正式发布前必须再次核验同一 revision，变更时停止重新确认批次。

最终应用源码需通过 `npm run check:apk -- -TestConcurrency 2`；相同源码通过后，签名构建使用原发布脚本的 `--build-only --skip-checks`，复用已完成完整门禁，不上传或晋级。不复用旧源码 `8be9ffb1` 的 dev.2/build 97 APK。

## 制品与设备证据

待补充最终提交、源码摘要、完整门禁结果、Debug 与 Release 包 SHA-256、正式证书、包名和设备覆盖安装核验。私有签名材料只用于本地构建，禁止进入 Git；主工作目录与发布配置不因本轮准备切换或修改。

## 负责人手测

1. 在核验过的设备上打开正式包 `site.wenyou.app` 对应“温油站”，确认版本 `0.8.0`、build 97，保留原账号与本地数据；自动化不打开已登录公网应用。
2. 首页、主题正文与动态详情的读取、返回、长文滚动及阅读滑块正常；编辑器与本地草稿可打开，公网不做自动测试写入。
3. 设置和游客“我的”没有旧更新历史入口。更新说明的长正文可上下滚动、底部操作可见，关闭后同 build 不重复；最终公网 97 文案公开前的覆盖安装弹窗不能视为已验证，需在合法隔离环境或发布后补核。
4. 记录负责人明确反馈、实际包 SHA-256 与日期。推荐／强制更新、低 build 合法升级等未在该包手测到的状态继续保留自动回归及原候选记录的覆盖边界。

发布授权不代替手测通过；没有明确结果时保持候选状态。正式上传必须与负责人手测制品 SHA-256 一致；若标准入口重新构建产生不同字节，须保留旧包并重新核验新包，不能冒用已测哈希。

## 通知直接删除紧急反馈

原场景：消息中心通知行的更多菜单只有“删除”一项，需要多一次展开。负责人要求直接呈现唯一操作。本轮仅以共享异步图标按钮和 Foundation `actionDelete` 替换单项菜单，保留删除确认、取消、在途禁用、权限、原请求和失败恢复，不调整数据与接口。

原应用摘要 `332ad71335e163406e8992281a17d54be173bbe494c9ed2dee3267eb23f6835f` 的完整门禁于紧急反馈后用任务执行会话 Ctrl+C 停止，退出 1；已跑 3715 项、1 项显式联网跳过，不能视为完整通过。原日志保留为 `build-formal-080-check-apk.log`，没有生成本批新 Debug／Release 包，也没有安装或发布。修改源码前已核对原 Flutter 检查进程退出。

新增页面精确回归在旧实现失败：默认通知行找不到可点击的直接删除按钮；日志 `build-notification-delete-old-regression.log`。候选将检查一键进入确认、取消不删除／不已读／不跳转、确认沿原删除路径，以及明暗 320dp 两倍字号画面；最终完整门禁需绑定急改后新摘要。

局部候选源码摘要 `f69e88ccf6805649b408f7bee7c1d356fe5fe89c4516759b877e5143cd21c92c`；`flutter test test/features/notifications --concurrency 2` 52 项通过（`build-notification-delete-verified.log`），包含在途禁用其他行删除、结算后恢复。标准 360dp、明暗 320×640 两倍字号三张 Golden 已实际查看，无溢出、删除按钮命中区域至少 44dp，确认按钮可达。图与日志保存于发布制品目录 `notification-delete-v1`；治理已审阅最小 diff 和三张图，仍属代理审阅，不替代负责人真机结果。修改后的最终完整门禁另用 `build-formal-080-final-check-apk.log`，不覆盖旧源码中断日志。

## 最终门禁与签名候选（2026-09-28）

应用提交 `2c0710c0b96fe6ad7537465c5d520afad5854269`，源码摘要 `f69e88ccf6805649b408f7bee7c1d356fe5fe89c4516759b877e5143cd21c92c`。最终 `npm run check:apk -- -TestConcurrency 2` 退出 0：格式、应用与生成客户端静态分析、架构、21 模块文档、161/161 API 覆盖、契约校验／再生成无 diff、严格公网来源全部通过；全量 Flutter 4991 项通过、1 项显式联网诊断按默认配置跳过，Windows 工具 67 项通过，ARM64 Debug 构建成功（218.1 秒）。日志 `final-check-apk.log`、机器记录 `full-gate.json` 位于下方同一制品目录。

签名构建在干净、已推送的同一源码执行原脚本 `--version 0.8.0 --build 97 --platform android --build-only --skip-checks`，只复用刚完成的完整门禁；正式包使用既有私有诊断配置。构建 423.4 秒并退出 0，原脚本完成 ARM64／字体检查、zipalign 16KB、ELF LOAD 16KB 对齐及 apksigner 验签。原签名材料和诊断配置哈希保持不变，未将密钥加入 Git。

- 制品目录：`D:\code\wenyousite\artifacts\mobile-release-notes-20260927\formal-0.8.0-97`。
- Release：`wenyou-0.8.0-97.apk`，`site.wenyou.app` / `0.8.0` / 97，Android API 26+、仅 `arm64-v8a`，33,610,393 bytes。
- Release SHA-256：`b3ebe7b5d0a0bd7d7c64963e59967e83ab3485813479bc6583b7191b5e63f245`。
- 证书 SHA-256：`4b19f9ba1890480d1e1ac72450f00027a635be57958b702ba3a8e80f2db24839`，与此前设备正式包和线上 build 96 一致。
- 原生构建摘要：`wenyou-0.8.0-97.json`，sourceCommit 为上述应用提交；`notesConfirmedRevision: null` 原样保留，独立 `preflight-initial.json` 为治理实际执行并绑定的 Android/0.8.0/97/revision 1 证据。
- Debug 门禁制品：`wenyou-0.8.0-debug-97-gate.apk`，109,419,846 bytes，SHA-256 `8e37dca4606c7165e5dc7d03e663d8204024ca55681e38777276e9886fa471ae`；它是普通门禁构建，不冒充已启动的隔离 Debug。

签名构建日志保留既有 KGP、Cupertino 字体裁剪提示；原脚本验签与产物检查通过，本轮没有扩大依赖或字体范围。远端只读 Windows CI 由治理针对应用提交核验，结果不替代本机门禁或负责人手测。

## 当前真机边界

准备早期设备 `4b9c39b5` 在线：正式包为 `0.8.0-dev.2`/97（更新时间 2026-09-27 03:49:40），Debug 为 `0.8.0-dev.2-debug`/97（05:44:47）；只读拉取旧正式包并核对相同签名。最终构建期间设备断开，2026-09-28 00:23 再次 `adb devices -l` 为空。因此本轮没有覆盖安装、卸载、清数据或启动正式／Debug 应用，没有新设备 APK 哈希和负责人手测通过结果。

Backend 在原隔离 run 的 Android 97 样本已调整为 `0.8.0-debug` / revision 1，Mobile 真实身份核验和详情 HTTP 200 通过；说明仍明确标注隔离样本，三项更新策略仍为 null，不能冒充已公开正式 97 文案。恢复设备后先安装并核验上述精确 Release SHA，再遵守前台归属启动原 consumer 的受控 Debug；若实际显示一次说明，保留弹窗供负责人查看，不自动关闭、不伪造偏好重播。负责人在正式应用时不启动 Debug 抢占。

PR #73 保持 Draft。负责人需对同包正常路径、通知直接删除和一次说明给出明确结果；此前不合并 dev/main、不打 Tag、不上传或晋级。普通文档证据补充不改变上述应用源码或 APK。
