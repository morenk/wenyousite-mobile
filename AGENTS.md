# 温油站移动端 — AI 辅助开发规范

## 0. 开发位置硬约束

- 本仓库的日常开发只允许在 Windows 本地开发机上修改、生成、测试、构建、签名和发布；标准工作区为 `D:\code\wenyousite\wenyousite-mobile`。
- 在 Linux、VPS 或非 Windows CI 环境发现本仓库时，只允许阅读；必须停止源码修改、Flutter/Gradle 构建、签名和发布。
- Windows 工作区中的 `wenyousite-frontend` 与 `wenyousite-backend` 只是只读参考镜像。移动端任务只允许对它们执行 `git fetch`、`git show`、`git diff` 和读取契约；禁止修改源码、安装依赖、启动服务、运行迁移或部署。
- Web 与后端只能在 VPS 的 `/root/wenyousite` 工作区开发和切换服务。需要修改 Web 或后端时，必须转到 VPS 对应仓库，不能在 Windows 镜像代改。
- `wenyousite-foundation` 对移动端而言是已发布依赖。开始任何 Foundation 相关实现前，必须在只读镜像执行 `git fetch origin --tags`，以远端最新正式发布 Tag 为准，并把 `pubspec.yaml` 锁定到该 Tag；若本仓库版本落后，必须先在当前切片同步依赖和迁移变更，禁止继续按旧版规范实现，也禁止直接跟随浮动分支。需要修改 Foundation 源码时必须另开独立任务并在其授权环境发布新 Tag。
- GitHub Actions 若保留，只能使用 Windows runner 在临时 checkout 内复核质量或 Debug 构建；CI 对仓库和外部系统只读，不拥有部署、签名、制品上传或发布权限，也不能替代 Windows 本地验收。

## 1. 项目定位

温油站移动端使用 Flutter 构建。首发 Android，最低 Android 8（API 26），手机竖屏优先；共享 Dart 代码保持 iOS 可兼容，但当前不做 iOS 签名和真机验收。

- 应用名称：温油站
- Android applicationId：`site.wenyou.app`
- 开发 API：`https://wenyou.site/api/v1`
- Android 模拟器经显式 SSH 隧道访问 VPS loopback 时：`http://10.0.2.2:3000/api/v1`
- Flutter SDK：`D:\sdk\flutter`
- Android SDK：`D:\sdk\android`
- Flutter/Dart 基线：Flutter `3.44.8`、Dart `3.12.2`
- 后端只读参考镜像：`..\wenyousite-backend`

当前阶段是公网开发环境上的第一阶段快速迭代，不是正式生产发布。开发闭环以相关本地检查和真机冒烟为主，GitHub Actions 仅保留手动触发，不作为日常切片完成条件。所有公网联调必须使用专用测试账号；禁止对共享开发数据运行批量删除、账号注销或其他破坏性自动化。

## 2. 产品范围

V1 包含认证、公开浏览、搜索、动态、主题/子贴/楼层、创作管理、图片、提及、骰子、草稿、收藏表情、收藏、关注、订阅、拉黑、社区举报、账号设置、站内通知和站内私聊。

V1 暂不实现：FCM 系统推送、举报审核/管理后台、离线阅读、离线自动发帖、暗色主题、阅读进度、子贴标签和 Android App Links。

共享审美与跨端体验事实源只存在于 `wenyousite-foundation` 的远端最新正式发布版本；当前由 `pubspec.yaml` 锁定 Foundation v6.2.0。移动端仓库不维护平行审美规范，只记录模块行为与代码入口。页面必须复用 `WenyouThemeTokens`、Foundation 语义图标、全局 `ColorScheme` 与共享组件，禁止在页面内创建近似 Token 或直接使用 Material 图标。功能阶段不得顺手引入大范围插画、粒子或复杂换皮。

## 3. 事实源与契约优先级

1. 后端运行时代码与 DTO 定义真实行为。
2. `contracts/openapi.json` 是 Flutter API/model 生成的固定机器契约。
3. `contracts/markdown-v3-fixtures.json`、`contracts/markdown-v3-nodes-fixtures.json` 与 `contracts/markdown-editor-roundtrip-v2-fixtures.json` 分别固定 Markdown 规范化/可见性、扩展节点和编辑器往返语义。
4. `contracts/mobile-push-v1.schema.json` 与 `contracts/mobile-push-v1-fixtures.json` 固定未来推送接入边界；V1 未接入 FCM 时也必须保持同步。
5. `docs/modules/*.md` 说明移动端产品流程、状态、权限和验收，不复制完整 Schema。

视觉实现以远端最新正式发布 Tag 的 Foundation `contracts/foundation.v1.json`、Flutter profile、元素/图片契约和生成常量为唯一事实源。视觉契约不得覆盖接口与业务契约，但所有页面、共享组件和视觉验收必须遵循中央颜色、字体、密度、状态、图片与无障碍规则。

视觉切片开始前必须 fetch Foundation 远端与 tags，确认最新正式发布 Tag，阅读该版本 CHANGELOG 和受影响契约，并核对 `pubspec.yaml`；发现新 Tag 时先升级固定版本、迁移破坏性变化并更新锁文件，再继续页面实现。`origin/main` 只用于确认最新发布位置，构建始终锁定明确 Tag。

每个切片开始先比较已记录后端 revision、`origin/dev` 与公网 `/meta`；仅在契约 revision 变化或明确同步契约时 fetch 后端只读镜像并比较：

- `contracts/openapi.json`
- `contracts/CHANGELOG.md`
- `contracts/markdown-v3-fixtures.json`
- `contracts/markdown-v3-nodes-fixtures.json`
- `contracts/markdown-editor-roundtrip-v2-fixtures.json`
- `contracts/mobile-push-v1.schema.json`
- `contracts/mobile-push-v1-fixtures.json`
- `docs/mobile-client-guide.md`

契约变化时，必须先用独立 `chore` 切片同步契约、重新生成客户端、审查生成 diff、更新受影响模块文档和 CHANGELOG，再开发业务功能。

同步命令：

```powershell
pwsh -NoProfile -File tool/sync_backend_contract.ps1
npm ci
npm run api:validate
npm run api:generate
```

OpenAPI Generator 固定为 `7.23.0`。`packages/wenyou_api` 全部由生成器维护，禁止手工编辑；生成文件必须提交。

## 4. 工程边界

```text
lib/
  app/                  # App、主题、路由、启动兼容检查
  core/
    application/        # 会话退出、资料缓存失效等跨 feature 应用协作契约
    config/             # AppEnvironment
    network/            # Dio、错误、请求追踪、刷新锁
    storage/            # Token 与本地数据库
    markdown/           # Markdown v3、Quill Delta Codec 与协议节点
    widgets/            # 无业务归属的通用组件
  features/
    app_shell/
    auth/
    home/
    moments/
    search/
    threads/
    posts/
    editor/
    drafts/
    media/
    notifications/
    direct_messages/
    stickers/
    users/
    reports/
    wallet/
    social/
    settings/
packages/
  wenyou_api/           # 生成客户端，禁止手改
```

规则：

- 使用 Riverpod 管理状态和依赖，go_router 管理导航，Dio 负责 HTTP。
- feature 之间通过明确的 repository/service 接口协作，不直接读取其他 feature 的页面状态。
- `core` 只放无业务归属的横切能力，不成为杂物目录。
- API 传输模型不得直接承担复杂 UI 状态；需要时在 feature 内映射为展示模型。
- 所有 label、说明、空状态和错误文案必须从用户视角描述当前对象、可执行动作或结果；禁止向用户解释服务端/客户端、接口/响应、协议/兼容节点、跨端状态共享等实现细节。
- 页面结构已能表达含义时，不再用“将显示在这里”“与某页共用数据”等文案重复解释界面。只保留用户做决定所需的输入约束、权限/隐私影响、不可逆风险和恢复方式。
- 面向用户的错误统一使用“加载失败 / 操作失败”等明确结果，不使用“响应不完整”“结果尚未确认”等开发语义；需要诊断时仅次要展示“问题编号”。
- 用户可见的业务状态使用产品语义而非存储枚举直译；主题 `CLOSED` 固定显示为“已停招”。
- 编辑器使用 Flutter Quill；Delta 只存在于编辑会话内存。后端、云草稿和 Drift 快照始终保存完整 Markdown v3。
- Markdown ↔ Delta 使用自研可测试 Codec；不得依赖 `markdown_quill` 充当事实转换层，mention/dice/sticker/image/独占 `<br />` 必须无损往返。
- 优先使用 Dart 语言能力，避免为简单状态额外引入代码生成框架。
- 注释解释权限、重试、生命周期和兼容原因，不复述显然代码。
- 不得通过关闭 lint、使用大范围 `dynamic` 或吞异常规避类型问题。
- 非生成 Dart 文件不得超过 900 行；`tool/architecture_allowlist.json` 只冻结启用门禁时的存量超限文件和精确行数。存量只能拆分、收紧和清零，禁止新增条目、提高基线或把实现机械搬进新的超大 `part` 文件。

## 5. 网络与安全不变量

- 登录、注册携带 `X-Client-Platform: mobile`。
- 每个请求携带安全的 UUID v4 `X-Request-ID`。
- access/refresh token 仅存安全存储；内存可缓存 access token。
- 日志禁止记录 Token、验证码、密码、完整私信正文、FCM token 和预签名 URL 查询参数。
- 并发 `40101 TOKEN_EXPIRED` 只允许一个 refresh 在途；其余请求等待同一结果。
- 刷新成功后原子替换双 Token，每个请求最多重放一次。
- 验证码发送等不可安全重放的写请求必须标记 `noAutomaticReplay`；遇到 `40101` 只刷新会话并由用户明确重试，超时/429/5xx 结果不明时不得在后台重发。
- `40103`～`40106` 清除本地会话；业务逻辑按错误码分支，不解析中文 message。
- Cursor 是不透明字符串；筛选变化时清空，`40007 INVALID_CURSOR` 从首页重载。
- 仅 GET、幂等方法和携带稳定 `clientRequestId` 的创建请求可自动重试。
- 创建主题、动态、动态评论、子贴、楼层和回复的同一次用户操作必须复用同一 UUID `clientRequestId`。
- 断网时保留草稿，但不得静默自动发布。

## 6. 模块文档规范

每个 `lib/features/<module>` 必须对应 `docs/modules/<module>.md`。模块文档是中文当前事实文档，不是开发日记。

固定章节：

1. 模块目标与非目标
2. 用户角色与使用场景
3. 页面、入口和导航关系
4. 用户操作流程
5. API operationId 与生成类型
6. 状态模型和数据流
7. 鉴权、权限和隐私规则
8. 本地存储、缓存及失效
9. 加载、空数据、错误、重试和冲突
10. 跨模块约束
11. 测试场景与验收条件
12. 已知限制和后续功能
13. 最近审查的契约版本和后端提交
14. 相关代码与架构文档

行为、页面、API、状态、权限、存储或错误处理变化时，代码、测试和文档必须在同一提交更新。纯内部重构可不改正文，但提交必须写：

```text
Docs-Impact: none - 仅调整内部实现，外部行为与状态模型不变
```

其他情况写：

```text
Docs-Impact: updated
```

## 7. 垂直切片流程

本项目是个人开发，采用轻量持续流，不固定 Sprint。默认一次只推进一个可操作的垂直切片；严重缺陷可以中断。

1. Fetch 后端并检查契约。
2. 阅读受影响模块文档。
3. 明确目标、非目标、验收标准、风险和文档影响。
4. 以完整行为实现，不按文件类型机械拆分。
5. 同步测试和模块文档。
6. 开发反馈批次收敛后运行与变更直接相关的本地检查；高风险切片、阶段验收或准备交付时运行统一质量门禁。
7. 自查 diff、生成文件、无关修改和敏感信息。
8. 原子提交并默认推送 `dev`。
9. 汇报行为、文档、本地验证、Debug APK 和真机手测清单；日常开发不等待 CI。

切片完成定义：主路径可操作；加载/空/错/重试/权限状态完整；相关测试和文档同步；变更范围内静态检查零问题；契约无漂移；无伪实现和调试残留；已推送 `dev`。涉及 Android、网络、认证或持久化时还要完成对应本地构建，并把真机关键路径整理为项目负责人可执行的手测清单；真机结果由项目负责人反馈。

### 开发中快速反馈循环

Flutter 本地开发中的“热重载”和“热重启”只用于 Debug 反馈，不表示向已安装客户端动态下发代码的生产热更新。项目负责人负责启动模拟器、真机和 `flutter run` 或 IDE Debug 会话；开发代理优先复用现有会话，当前工具能安全控制会话时触发对应操作，否则明确提示项目负责人执行，不自行操作未授权真机，也不为此启动长期后台调试进程。

- 颜色、间距、字号、文案、普通布局和 Widget 组合等纯 Dart 展示调整，优先在现有会话中使用 `r` 热重载，并保留当前页面与操作状态快速观察结果。
- `main()`、初始化逻辑、Provider 装配、路由、全局或静态状态等不能由热重载可靠重新执行的变化，使用 `R` 热重启并重新进入目标页面。
- `pubspec.yaml`、依赖、新增资源或字体、代码生成输出变化后，执行所需获取或生成步骤并重新启动调试会话；涉及插件、Manifest、Gradle 或其他 Android 原生配置时必须重新构建。
- 热重载后出现疑似旧状态、缓存或初始化残留时，先热重启复核，再判断为实现缺陷。

同一视觉目标的连续微调可以组成一个反馈批次，批次内不在每次保存后机械重复 analyze、测试或构建。批次收敛、准备提交或切片完成时，必须按下一节的风险分层执行相关检查；热重载或热重启不能替代静态检查、Widget/Golden 回归、Debug APK、完整门禁或项目负责人真机验收。没有可复用 Debug 会话时，开发代理不得把未查看的页面宣称为已完成视觉验收，应在交付说明中列出待执行的页面检查。

## 8. 质量门禁

第一阶段开发允许先使用热重载或热重启完成快速反馈；反馈批次收敛后优先运行相关测试和受影响范围的静态检查。以下完整本地门禁用于认证、契约、网络、上传、持久化等高风险切片，以及阶段验收、准备交付或用户明确要求时；普通展示和低风险切片不必机械重复全部命令。完整门禁的唯一入口是：

```powershell
npm run check
```

该入口必须覆盖格式、应用与生成客户端分析、全量测试、架构、文档、API 覆盖、契约校验/再生成一致性和 Windows 发布工具测试；不得在本文复制第二套易漂移的子命令清单。

生成契约变化时还要重新生成并确认 `git diff` 符合预期。涉及 Android 配置、依赖、原生插件、演示构建或准备晋级时执行：

```powershell
flutter build apk --debug
```

风险分层：

- 纯展示：开发中热重载、必要时热重启；反馈批次收敛后 analyze + Widget/Golden 测试 + 页面检查清单。
- 分页/表单/普通写入：状态/仓储测试 + 错误状态 + API 冒烟。
- 认证/契约/上传/持久化/幂等/注销：回归测试 + 集成测试 + APK + 项目负责人手动执行的真机关键路径清单。

Bug 修复必须包含能复现旧问题的回归测试。不追求表面覆盖率数字，但认证、网络、契约、编辑器和状态转换必须有自动测试。

GitHub Actions 的 Quality 与 Android Debug APK 工作流在第一阶段仅支持 `workflow_dispatch` 手动触发，不因 `dev` push 自动运行，也不作为日常开发阻塞条件。进入发布准备或用户明确恢复 CI 后，再启用自动触发并恢复远端绿色要求。

## 9. Git、版本与交付

- 长期开发分支为 `dev`。
- 用户未明确决定时，禁止合并 `main`、禁止打正式 Tag。
- 每个提交必须是可独立理解、独立回滚的完整行为。
- 禁止提交不能编译或只完成一半的切片。
- 依赖升级、契约同步和生成工具变化使用独立 `chore`。
- `pubspec.lock`、`package-lock.json` 和生成客户端必须提交。
- 禁止提交密钥、签名文件、Token、测试账号和私人配置。
- Android 发布 APK 由开发机直接上传 `wenyou-apk` RainS3 桶，VPS 只晋级 `/meta` 策略；发布 AccessKey 只留在开发机，禁止回退到 SCP/VPS 分发。

提交格式：

```text
<type>: <中文行为摘要>

- 关键变化
- 验证方式

Docs-Impact: updated|none - 原因
```

允许类型：`feat`、`fix`、`refactor`、`test`、`docs`、`chore`、`perf`。

开发版本使用 `0.x.0-dev.N+buildNumber`。只有用户明确决定晋级时，才执行 `dev -> main`、完整门禁、项目负责人手动真机冒烟、移除 dev 后缀和 `v0.x.0` Tag。

## 10. 当前交付基线

最初按 `0.1.0-dev`～`0.7.0-dev` 划分的交付顺序只属于历史规划，已归档到 `docs/archive/initial-delivery-plan.md`，不得再据此推断功能尚未实现或指定下一个版本。当前版本、已交付范围、持续债务和优先级以 `PROJECT_PLAN.md` 为准；模块的行为与验收状态以 `docs/modules/*.md` 和 `docs/modules/README.md` 为准；活跃变化只追加到 `docs/CHANGELOG.md`。

选择切片时优先解决当前计划中的发布安全、稳定契约未接入能力和未完成真机验收。Foundation 视觉基础已经建立；复杂动效、插画和全局像素级精修仍应作为独立切片，不与功能闭环混改。
