# 兼容与弃用登记

## APK 每日下载次数（候选／待验收）

- 固定 Backend `10b7819ad4a15777490dad5ab9abb7ae961422fc`／`5.32.0-dev.20261003.1`。仅兼容新增 429 原因头及可选浏览器 Cookie，238 个操作和 DTO 保持；无有效 Cookie 的旧 APP 可直接 HEAD→GET，仍受单 IP 日次数限制，不要求新增 info 或硬件标识。
- 设备／IP 次数跨构建按北京时间日界累计，合法 GET 含每个 Range 在发送前计次，预占后中断不退；HEAD/info 不计次数。未知或缺失原因头继续按原 429/Retry-After 处理，文件元数据、摘要与安装签名门禁不变。
- 不删除路径、旧 APP、旧 `/meta` 或 RainS3 历史制品身份。发布顺序为兼容 Backend → 消费端；回滚消费者可恢复通用提示，不能绕过后台限额，也不能清空或降级出站账本以重置已用次数。出站 v2 迁移／回滚由 Backend 独立管理，Mobile 不操作服务或生产账本。
- 浏览器签名 Cookie 不保证物理设备唯一；原生 APP 本次不新增 Cookie 持久化。已校验本地包的继续安装不消耗新下载次数；真实旧 APP 覆盖安装仍待负责人验收。

## 讨论固定编号与双向窗口（候选／待验收）

- 固定 Backend `62083784e27f697af3799e392011bf8f6dd825d2`／`5.30.0-dev.20261001.1`。新增 `postsFindFloorWindow`、`postsFindReplyWindow` 与可选 `replyNumber`；旧列表、创建及帖子 ID 坐标继续保留。`total` 是筛选后条数，`maxNumber` 是当前查看者在整个范围可访问的最大固定编号，编号空洞不重排。
- 默认首屏保留最多十条置顶及对应 ID 抑制集合；直接编号、ID 与返回位置读取窗口时清空置顶区。仅 `40010 DISCUSSION_TARGET_FILTERED` 清作者筛选重试一次；404 不替换为邻居，也不清空已有阅读内容。
- 发布顺序为兼容 Backend → 消费端；本切片不删除旧接口、生成 SDK 或后端编号兼容触发器。回滚消费者可恢复旧分页，已分配编号不重排。Foundation 正式依赖仍固定 `v7.2.1`，不新增本地持久阅读进度。

## 私密邀请链接复用（候选／待负责人验收）

- 当前消费者文档来源升级至 Backend `4db0cdf2c079fc8b66545c67849053cd74945f8a`，API／Schema未变。本轮按负责人反馈移除Mobile邀请Sheet、重置入口及专属控制器状态，设置页仅直接复制PUT。POST、operationId、生成SDK和repository禁止重放策略继续保留；这次不删除兼容协议。以下是初始契约接入记录。

- 固定 Backend `cfe9621c39f9d9c8c7f764bf45293be43bab1af7`／`5.29.0-dev.20261001.1`，新增消费 `threadsEnsureInviteLink`（PUT，200）。`threadsCreateInviteLink`（POST）及其 operationId 保留，仅在用户明确确认重置时调用，显式禁止自动重放。
- 旧客户端继续使用 POST 重置；新客户端获取失败不得回退 POST。必须先发布兼容 Backend，再发布消费者。服务端重置只使旧链接失效，不撤销既有成员；本切片不改 Schema、本地持久化或成员权限。
- 未删除接口、DTO 或兼容协议；回滚消费者可恢复旧入口，不能恢复已经重置的旧 token。Foundation 仅补共享交互文档，继续锁定正式 v7.2.1，不等待新包发布。
- 随契约生成同步的可选 `PostBaseResponseDto.editedAt` 保留兼容，不在本切片消费。检查和未覆盖项见[邀请候选验收](architecture/private-invite-reuse-acceptance.md)。

## 本人关注与粉丝管理

- 新增消费 `usersFollowRemoveFollower`；`UserFollowRecordResponseDto.viewerIsFollowing`、`viewerIsFollowedBy` 为可选，本人列表缺字段时展示关系暂不可用，不误判未关注，不允许未知状态写入。原公开/本人列表路径与原关注接口保留。
- 兼容后端已先行合并与部署，消费端已获负责人验收并授权合并 dev，尚未正式发布 Android；本候选来源已同步 Backend `92b030a81f8957386e324fed477bd1e46faf65ea` / `5.26.0-dev.20260922.3`（关系接口与此前 4850e2f 来源完全一致）。旧后端不能提供新管理能力，但原列表仍可读取；不逐行请求主页补投影。
- Foundation 锁定正式 v7.1.0；关系交互说明来自共享文档提交 `ba1e921212b908835734732f26e263203a8226c6`，无新增 Token、版本或 Tag。
- 不新增数据库或本地持久化，不删除兼容协议。回滚消费者恢复原页面与对应依赖；已发生的关系写入不会通过回滚客户端恢复。

## 兼容新增图集读取

- 本关系候选仅同步 `galleryList` 和生成类型，不改变既有图片查看入口；完整图集消费由独立媒体切片接入。管理端 `rememberDevice` 可选字段不改变 Mobile 认证流程。
- 不移除或清理旧协议；已有关系字段缺失兼容、未知结果只读核实和回滚边界保持。
