# 个人区视觉收敛候选验收

日期：2026-09-26。状态：负责人已同意合并到 `dev` 并清理任务分支；此前 Debug 候选已安装，未记录逐页目视结论。按负责人要求跳过全量测试。

## 合并前整合

候选最初基于 `796e5afa7407fb76e3b1011093b192d5572518da`，后与 `origin/dev` 的 `444ef40149adc746271c188400c21d971e664eeb` 整合。保留内容卡任务的 Foundation `v7.1.2`、10dp 内容卡圆角、8dp 浏览卡间距、外观页“省流量”入口，以及后台提醒仅在设备支持时展示；个人资料头按本候选使用无描边单层卡片、隐藏空简介与脱敏邮箱。当前固定 Backend 来源随 `dev` 更新为 `124fb4e8aa395440f7a2156de98b642ec87f7583`，OpenAPI 仍为 `5.26.0-dev.20260922.3`。本次整合不改变 HTTP API 或存储。

## 范围与事实源

本切片收敛“我的”、他人主页共用资料头、资料编辑、账号设置、外观和故障诊断。页面只使用 Foundation 和现有移动端语义 Token，不改变页面路径、写入流程、权限、HTTP API 或存储。分支从 `origin/dev` 的 `796e5afa7407fb76e3b1011093b192d5572518da` 建立。

开始前在 Foundation 只读镜像执行 `git fetch origin --tags`，确认最新正式 Tag 为 `v7.1.1`（`f7339711a1d77964a38719580cf480ea4fd08e23`），阅读其 CHANGELOG、视觉契约及移动端 profile 后固定 `pubspec.yaml` 和锁文件。后端只读镜像 `origin/dev`、本仓已记录 revision 与公网 `/meta` 均为 `0bc9c45e213fa4dcbde8a3bcf2c466dc88ceb256`，OpenAPI `5.26.0-dev.20260922.3` 未漂移，无须同步或重生成业务契约。

## 候选行为

- 个人页与编辑、账号设置、外观、诊断使用同一柔和浅色页底；黑夜使用现有暗色背景。设置项使用白色或暗色分组面板、组内细线、语义图标，保留原入口和操作。
- 账号设置依次为“偏好与提醒 / 账号 / 账号操作 / 帮助”。个人区分组内设置项标题统一为常规字重；后台消息提醒行不再显示右侧感叹号说明按钮，原说明保留为标题长按提示和读屏信息。后台提醒申请权限、读取和保存重试、退出确认与仅清除本机登录、注销入口沿用原流程。
- 资料编辑的基本资料与主页公开内容分组，原预览、单一保存按钮及离开保护不变。
- 本人和他人共用资料头移除外框及多余分隔，保留封面、头像、等级、统计和操作，不再显示加入日期。没有简介时不显示占位文案；本人资料头不显示脱敏邮箱；“概览”页签不重复“创作概览”标题。

## 自动检查与视觉样本

直接相关测试覆盖 `test/features/users/me_page_test.dart`、`user_profile_header_test.dart`、`public_user_page_test.dart`、`user_activity_summary_panel_test.dart`、`background_reminder_settings_panel_test.dart`、`test/features/settings/appearance_settings_page_test.dart` 和 `diagnostic_settings_page_test.dart`。Foundation 版本及资源校验覆盖 `test/app/app_theme_test.dart` 与 `test/tool/foundation_brand_assets_test.dart`。

完整 `npm run check:apk` 已在全仓格式、应用与生成客户端分析、架构、21 个模块文档、API 覆盖及契约校验通过后，按负责人要求于全量 Flutter 测试期间中止；中止时进度为 2,624 项通过、1 项跳过。此执行退出码非 0，**不算完整门禁通过**。随后运行 `npm run candidate:apk`：全仓格式无改动，应用和生成客户端分析零问题，上述九个相关测试文件全部通过；进入 Gradle `assembleDebug` 后，为让筛选栏先行验机而中止构建，因此该入口也未完整通过。

负责人随后要求个人区只直接构建并交由另一任务安装；该轮 `flutter build apk --debug` 退出码 0，历史候选大小 `109242464` 字节、SHA-256 `1364AA7F889BA067B6D097737C39311C824830549D27750F500994CC7DEE5EB8`。此摘要已被下述微调调试包取代，不能再作为当前设备的验收依据。

负责人对已安装页面提出三处微调后，六个直接受影响测试文件（`me_page_test.dart`、`user_profile_header_test.dart`、`public_user_page_test.dart`、`background_reminder_settings_panel_test.dart`、`appearance_settings_page_test.dart`、`diagnostic_settings_page_test.dart`）共 97 项通过，受影响 Golden 已更新。`flutter attach -d 4b9c39b5` 等待约 80 秒未发现现有 Dart VM Service，因此原先已安装的 APK 无法热重载；随后按负责人授权执行 `flutter run -d 4b9c39b5`，编译、安装和同步均成功，并取得 Dart VM Service。再次发送 `r` 热重载成功；显示 0 个库变化，因为新源码已随 `flutter run` 编译安装。调试会话保持运行。

上一轮已安装调试 APK 大小 `149811316` 字节，SHA-256 `3E9063AD159C94CA40324223853DAEB271DD07BA53E3EA2DC8DFE76AF21A717C`；当时从 APK 本身读取包名 `site.wenyou.app.debug`、应用名“温油站 Debug”、版本 `0.8.0-dev.1-debug`、构建号 `96`。设备该包更新时间为 `2026-09-25 14:51:27`，设备内 `base.apk` 的 SHA-256 与当时本地包一致。整合 `dev` 后重新构建的包见下文，尚未安装；构建与安装、自动测试和 Golden 不代替负责人目视验收。

账号设置、资料编辑和共用资料头新增 320dp／2 倍字号、400dp、600dp 浅色及黑夜 Golden；既有 360dp Golden 随布局更新。已检查代表性图片的面板、页底、窄屏换行与宽屏内容约束。Widget／Golden 不代替真机视觉验收。

### 2026-09-26 整合检查

- `flutter analyze --no-pub` 在整合代码后零问题；后续设置行显式使用语义字阶常规字重，`architecture:check` 再次通过，直接相关 Widget／Golden 与 Debug 构建通过。
- `docs:check` 通过 21 个模块，`api:validate` 无问题。个人区相关 10 个测试文件共 114 项在 Golden 更新后再次以只读对比模式通过；包含浅色／黑夜、320／360／400／600dp、两倍字号、设置入口和资料头。代表性浅色账号设置、黑夜外观、窄屏资料头与资料编辑 Golden 已人工查看。
- `flutter build apk --debug --target-platform android-arm64 --no-pub` 成功，整合后 Debug APK 大小 `149828828` 字节，SHA-256 `E24DE9BE428BD89B3AEBD4AFAD53C854E7CBA2DFA3FC65F7FABF4ACEFFA6E801`。该包仅作候选校验，未安装、上传或正式发布。
- 按负责人要求未运行全量 Flutter 测试；未记录整合后 APK 的真机目视结果。

## 负责人真机复验

1. 安装前核对目标应用包名为 `site.wenyou.app.debug`，安装后核对该包更新时间与设备内 APK SHA-256，再打开“温油站 Debug”；不要仅凭构建号判断是否为本候选。
2. 登录后检查“我的”和他人主页资料头：封面、头像、等级、统计和操作完整，均不显示加入日期；空简介没有占位，概览无重复标题。切换浅色、黑夜、系统大字号，检查 320dp 左右的窄屏和较宽屏，确认无裁切或溢出。
3. 进入账号设置、外观、故障诊断和编辑资料，检查页底、分组、图标、组内分隔、滚动底部与返回。编辑预览、保存及未保存离开提示按原流程操作。
4. 在账号设置确认各设置行标题为常规字重，“后台消息提醒”与其他行一致且右侧没有感叹号说明按钮。逐项打开外观、黑名单、登录终端、修改密码、更换邮箱、治理决定与申诉、故障诊断和注销入口；注销只检查入口及确认，不执行真实注销。切换后台消息提醒并检查权限提示和失败重试；退出登录检查确认及失败时的本机清除选项。
5. 使用 TalkBack 检查分组标题、设置行名称与状态、后台提醒说明及可点击目标。对有权限或失败条件的状态按测试账号真实场景复核。

本任务通过 `flutter run` 在负责人连接的设备上启动了 Debug 会话，并核对包名、更新时间和设备内 APK 哈希；未代替负责人逐页目视复验。自动检查、Golden、构建和安装均不能代替负责人对上述页面的验收，未回复不视为通过。

## 跨任务整合结果

内容卡 PR [#59](https://github.com/morenk/wenyousite-mobile/pull/59) 已先合入 `dev`，本任务随后整合其 Foundation `v7.1.2`、10dp 内容卡圆角和 8dp 浏览卡间距。个人资料头保留无描边单层表面，空简介和脱敏邮箱不显示，概览标题不重复；外观页保留新加入的“省流量”入口。
