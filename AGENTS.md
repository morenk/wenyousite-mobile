# 温油站移动端 — AI 辅助开发规范

## 0. 开发位置硬约束

- 本仓库的日常开发只允许在 Windows 本地开发机上修改、生成、测试、构建、签名和发布；标准工作区为 `D:\code\wenyousite\wenyousite-mobile`。
- 在 Linux、VPS 或非 Windows CI 环境发现本仓库时，只允许阅读；必须停止源码修改、Flutter/Gradle 构建、签名和发布。
- Windows 工作区中的 `wenyousite-frontend` 与 `wenyousite-backend` 只是只读参考镜像。移动端任务只允许对它们执行 `git fetch`、`git show`、`git diff` 和读取契约；禁止修改源码、安装依赖、启动服务、运行迁移或部署。
- Web 与后端只能在 VPS 的 `/root/wenyousite` 工作区开发和切换服务。需要修改 Web 或后端时，必须转到 VPS 对应仓库，不能在 Windows 镜像代改。
- `wenyousite-foundation` 对移动端而言是已发布依赖。移动端切片只消费固定 Tag；需要修改 Foundation 时必须另开独立任务并在其授权环境发布新 Tag，再由本仓库独立升级。
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

共享审美与跨端体验事实源只存在于 `wenyousite-foundation` 的已发布版本；当前由 `pubspec.yaml` 锁定 Foundation v2.4.2。移动端仓库不维护平行审美规范，只记录模块行为与代码入口。页面必须复用 `WenyouThemeTokens`、Foundation 语义图标、全局 `ColorScheme` 与共享组件，禁止在页面内创建近似 Token 或直接使用 Material 图标。功能阶段不得顺手引入大范围插画、粒子或复杂换皮。

## 3. 事实源与契约优先级

1. 后端运行时代码与 DTO 定义真实行为。
2. `contracts/openapi.json` 是 Flutter API/model 生成的固定机器契约。
3. `contracts/markdown-v2-fixtures.json` 与 `contracts/markdown-v2-nodes-fixtures.json` 分别固定 Markdown 规范化/可见性和扩展节点往返语义。
4. `contracts/mobile-push-v1.schema.json` 与 `contracts/mobile-push-v1-fixtures.json` 固定未来推送接入边界；V1 未接入 FCM 时也必须保持同步。
5. `docs/modules/*.md` 说明移动端产品流程、状态、权限和验收，不复制完整 Schema。

视觉实现以锁定版本的 Foundation `contracts/foundation.v1.json`、Flutter profile、图片契约和生成常量为唯一事实源。视觉契约不得覆盖接口与业务契约，但所有页面、共享组件和视觉验收必须遵循中央颜色、字体、密度、状态、图片与无障碍规则。

视觉切片开始前还要 fetch Foundation，确认 `pubspec.yaml` 的 tag 仍是目标版本并阅读该版本 CHANGELOG；需要升级时先做独立 `chore`，不得直接跟随主分支。

每个切片开始先比较已记录后端 revision、`origin/dev` 与公网 `/meta`；仅在契约 revision 变化或明确同步契约时 fetch 后端只读镜像并比较：

- `contracts/openapi.json`
- `contracts/CHANGELOG.md`
- `contracts/markdown-v2-fixtures.json`
- `contracts/markdown-v2-nodes-fixtures.json`
- `contracts/mobile-push-v1.schema.json`
- `contracts/mobile-push-v1-fixtures.json`
- `docs/mobile-client-guide.md`

契约变化时，必须先用独立 `chore` 切片同步契约、重新生成客户端、审查生成 diff、更新受影响模块文档和 CHANGELOG，再开发业务功能。

同步命令：

```powershell
powershell.exe -NoProfile -File tool/sync_backend_contract.ps1
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
    markdown/           # Markdown v2、Quill Delta Codec 与协议节点
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
- 编辑器使用 Flutter Quill；Delta 只存在于编辑会话内存。后端、云草稿和 Drift 快照始终保存完整 Markdown v2。
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
6. 运行与变更直接相关的本地检查；高风险切片、阶段验收或准备交付时运行统一质量门禁。
7. 自查 diff、生成文件、无关修改和敏感信息。
8. 原子提交并默认推送 `dev`。
9. 汇报行为、文档、本地验证、Debug APK 和真机手测清单；日常开发不等待 CI。

切片完成定义：主路径可操作；加载/空/错/重试/权限状态完整；相关测试和文档同步；变更范围内静态检查零问题；契约无漂移；无伪实现和调试残留；已推送 `dev`。涉及 Android、网络、认证或持久化时还要完成对应本地构建，并把真机关键路径整理为项目负责人可执行的手测清单；真机结果由项目负责人反馈。

## 8. 质量门禁

第一阶段开发优先运行相关测试和受影响范围的静态检查。以下完整本地门禁用于认证、契约、网络、上传、持久化等高风险切片，以及阶段验收、准备交付或用户明确要求时；普通展示和低风险切片不必机械重复全部命令。完整门禁的唯一入口是：

```powershell
npm run check
```

该入口必须覆盖格式、应用与生成客户端分析、全量测试、架构、文档、API 覆盖、契约校验/再生成一致性和 Windows 发布工具测试；不得在本文复制第二套易漂移的子命令清单。

生成契约变化时还要重新生成并确认 `git diff` 符合预期。涉及 Android 配置、依赖、原生插件、演示构建或准备晋级时执行：

```powershell
flutter build apk --debug
```

风险分层：

- 纯展示：analyze + Widget 测试 + 页面检查清单。
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

## 10. 里程碑

- `0.1.0-dev`：仓库、CI、文档、主题、契约、网络基础。
- `0.2.0-dev`：应用壳、游客模式、认证和会话。
- `0.3.0-dev`：首页、动态、搜索、主题、子贴、楼层和用户主页。
- `0.4.0-dev`：动态评论、回复、点赞、收藏、关注、订阅、拉黑、通知和站内私聊。
- `0.5.0-dev`：编辑器、图片、收藏表情、提及、骰子、本地和云草稿。
- `0.6.0-dev`：主题工作台、子贴、成员、玩家和私密邀请。
- `0.7.0-dev`：账号生命周期、性能、弱网、无障碍和真机验收。

Foundation 视觉基础在首页等内容功能前建立；复杂动效、骨架屏、插画和全局像素级精修在功能闭环稳定后作为独立里程碑实施。
