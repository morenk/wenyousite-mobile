# 治理决定与申诉

状态：`in_progress`

## 1. 模块目标与非目标

让普通登录用户和被暂停/封禁而无法建立普通会话的账号，都能查看本人近 30 天治理决定并对仍生效、尚未申诉的决定提交一次复核说明。移动端不承载举报审核、治理案件队列、处罚执行、申诉裁决或完整管理员站务产品；契约已提供管理员在内容现场直接隐藏的窄能力，但当前尚未接入可见入口。

## 2. 用户角色与使用场景

普通有效会话直接读取本人决定；暂停或封禁账号从登录页进入公开申诉入口，验证账号密码后使用 15 分钟专用凭据。游客若没有对应账号只能看到验证表单。管理员审核和最终处理在独立站务产品完成；后端 4.9.0 提供普通 Bearer 下的内容隐藏端点，移动端需先可靠投影 `ADMIN / SUPER_ADMIN` 角色并完成现场确认与状态刷新，不能向普通用户猜测或暴露该能力。

## 3. 页面、入口和导航关系

公开路由 `/appeals` 使用标题“治理决定与申诉”。登录页常驻“账号被暂停或封禁？”入口，普通登录用户也可从“我的 → 账号设置 → 治理决定与申诉”进入。该路由不要求先建立普通登录会话，避免受处罚账号被鉴权守卫送回登录；普通会话存在时仍优先使用普通 Bearer。

## 4. 用户操作流程

普通登录进入后自动读取决定。受限账号输入邮箱或大小写敏感用户名与密码，调用专用签发端点；成功后清空密码并读取决定。列表显示生效/撤销状态、处置类型、时间、公开说明、规则代码和目标稳定 ID。仍生效且没有申诉的决定可打开底部表单，输入 10～2000 字事实和理由；提交成功后权威重读列表并展示“待复核”。已有申诉显示说明、状态和可选站务复核备注，不再出现重复提交入口。

## 5. API operationId 与生成类型

- 专用凭据：`userModerationAppealsIssueToken`，使用 `IssueAppealTokenDto`、`AppealAccessTokenResponseDto`。
- 本人决定：`userModerationAppealsMine`，使用 `ModerationDecisionPublicResponseDto`。
- 提交申诉：`userModerationAppealsAppeal`，使用 `CreateModerationAppealDto`、`ModerationAppealResponseDto`、`ModerationAppealDecisionResponseDto` 与 `ModerationAppealAppellantResponseDto`。
- 待接入管理员现场隐藏：`clientContentModerationHide`，使用普通 Access Token、`ModerateContentDto` 与 `AdminContentModerationResponseDto`；当前仅生成客户端并登记计划，不在页面调用。

## 6. 状态模型和数据流

`ModerationAppealController` 使用 credential/loading/ready/failed 四阶段，专用凭据只保存在 autoDispose 控制器私有字段，状态仅暴露过期时间。申诉仓储接口位于 `moderation/application`，`main.dart` 组合根绑定 API data 适配器；普通会话由 `SessionController` 提供，适配器根据是否存在专用凭据选择普通 Bearer 或显式 `Authorization`。提交按 decisionId 串行，成功后重新调用本人决定接口，不乐观拼装申诉对象。

## 7. 鉴权、权限和隐私规则

签发请求显式 `skipAuth`，避免现有普通 Access Token 覆盖账号密码恢复流程。专用凭据请求同时显式设置该 Bearer 和 `skipAuth`，因此普通会话拦截器不会替换它；凭据只能被后端 AppealAuth 接受，不能访问其他接口。账号、密码、专用 JWT 和申诉正文不写日志、不进查询参数、不持久化。`40120 APPEAL_TOKEN_INVALID` 只清专用凭据并回到验证表单，不清普通会话或触发刷新；目标归属、30 天期限和一次申诉约束均由服务端最终确认。

## 8. 本地存储、缓存及失效规则

账号表单、密码、专用凭据、决定列表和申诉正文只存在当前页面内存。离开 `/appeals` 后 autoDispose 清除专用凭据和列表；应用重启或 15 分钟到期必须重新验证。普通会话 Token 继续只由认证模块的安全存储管理，本模块既不读取持久化 Token，也不写入替代会话。

## 9. 加载、空数据、错误、重试和冲突状态

全模块错误遵循[网络与会话](../architecture/networking.md)统一分级：可操作的预期失败只给恢复提示；本机、网络连接、温油站服务与内容处理异常才标注问题环节，只有可核对的服务/内容异常及结果待核对写入显示问题编号。普通页面不展示 HTTP、业务或内部诊断码，Debug 现场诊断可复制安全技术字段。

加载、近 30 天无决定、读取失败和显式重试均有独立状态。账号密码错误 `40110`、账号锁定 `40105`、暂停/封禁普通会话 `40108/40109`、专用凭据失效 `40120` 使用稳定文案；所有失败可展示请求 ID。`40417` 表示决定不可用，`40921` 表示已提交，`40922` 表示期限结束。POST 不自动网络重试；结果不明确时保留说明并由用户显式重试，后端唯一约束负责收敛重复提交。

## 10. 跨模块约束

auth 只提供登录页入口和普通会话；settings 只提供已登录入口；moderation 独立拥有凭据、决定与申诉状态，不能把专用 JWT 写入 `SessionController`。core/network 提供 `skipAuth`、请求 ID 与稳定错误映射。页面复用 Foundation v6.3.0 Token、语义图标、共享面板/状态组件、48dp 操作目标和单列最大宽度，不复制 Web 管理端样式。

## 11. 测试场景与验收条件

- [x] 签发 DTO 裁剪账号，密码原样发送，且显式 `skipAuth`；返回空 token 时 fail-closed。
- [x] 专用凭据读取和提交显式隔离 Authorization，普通登录读取不添加专用头。
- [x] 提交成功必须同时确认 typed decision 与 appellant，避免旧响应结构伪装成功。
- [x] 游客验证后只用专用凭据读取/提交；普通登录直接读取；`40120` 只清专用凭据并返回验证页。
- [x] 360dp 完成账号验证、决定展示、10 字校验、提交和权威重读，无布局溢出。
- [x] 登录页和账号设置均有可发现入口，公开路由不会要求受限账号先建立普通会话。
- [ ] 使用公网专用受限测试账号验证 15 分钟过期、已申诉和站务处理结果；禁止对真实用户施加处罚。

## 12. 已知限制和后续功能

移动端不展示 30 天之外的历史决定，不支持撤回或补充已提交申诉，也不做后台到期提醒。公开决定 DTO 的既有 `appeal` 仍是开放 map，仓储只在必需字段完整时显示；后端未来应将其收敛为 typed DTO。管理员申诉列表、案件处置和审计继续保持移动端产品范围外；现场隐藏能力在角色投影、二次确认、成功后的内容失效和 `40308` 降级全部闭环前保持隐藏。

## 13. 最近审查的契约版本和后端提交

契约 `5.15.0-dev.20260902.1`；后端 `75669f22a088e1b84dea818eb1fda8682456d5fb`；Foundation `v6.3.0`（`73ed49e`）。

## 14. 相关代码与架构文档

代码入口：`lib/features/moderation/application/moderation_appeal_repository_ports.dart`、`lib/features/moderation/data/`、`lib/main.dart`；登录入口：`lib/features/auth/presentation/login_page.dart`；设置入口：`lib/features/users/presentation/me_page.dart`。参见[认证](auth.md)、[设置](settings.md)、[社区举报](reports.md)、[网络与会话](../architecture/networking.md)、[导航](../architecture/navigation.md)与[API 生成和覆盖审计](../architecture/api-generation.md)。
