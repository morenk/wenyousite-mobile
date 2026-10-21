# 楼层编辑时间契约同步

## 2026-10-15 当前候选

本轮合入 Mobile `dev` 的 `d7168b61ea1b547e737585d2e9b250f1b3bd24e2` 后，采用其已同步的 Backend `b5f0e3bb0b99a3f9763b31e3080cb4d4f2e64045`／API `5.36.0-dev.20261005.1`，生成客户端已包含可选、可空 `editedAt`；不恢复九月的旧契约或覆盖清单。匿名只读 `/meta` 与当前固定来源一致，Markdown 运行时为 5。字段语义与展示范围保持下述约定，当前验证结果见[候选验收记录](post-edited-time-acceptance.md)。

## 历史：2026-09-29 首次同步

以下记录首次契约同步及当时的线上差异，不代表当前候选的固定来源或检查状态。

本候选固定 Backend `dc62a36dcf016f58fadcf53672215bb5fa66e618`，分支 `codex/20260929-post-edited-time`，OpenAPI `5.28.0-dev.20260929.1`。同步脚本从 Windows 后端只读镜像 fetch 该分支，按完整 SHA 导出已提交契约；不代表后端已合并或部署。

`PostResponseDto`、`FloorResponseDto`、`ReplyResponseDto`、`PostDetailResponseDto` 兼容新增可选、可空的 `editedAt`。该时间由后端在规范化正文实际改变且保存成功后更新；历史与未编辑内容为 null，客户端不得从 `updatedAt`、版本号或两个时间的差值推测。缺字段也按未编辑处理。既有创建、排序和版本语义不变。

同步包含此前已合入后端的关注／粉丝计数可见性说明、更新提醒指南及契约包元数据，未新增计数 API 或改变本次页面范围。OpenAPI Generator 固定 `7.23.0`，仍归一化两处既有重复 CSRF 参数，SDK 由生成器维护。固定独立来源的列表、行内组合和预览协议保持不变；Foundation 已 fetch tags 核对最新正式版本仍为 `v7.2.1`，本次不改依赖版本。编辑时间呈现说明另见 Foundation 已提交 `28808c7fa1f7b81f57f5022fa5ce64fcfcf8e931`（PR #26），不改变格式化函数或包版本。

楼层展示、回包映射与视觉回归在独立功能提交接入。公网只读 `/meta` 在同步时仍为 `1d43b85f7aa8cd1ab03f6ab34f1851462e1a0021`、API `5.27.0-dev.20260927.1`、Markdown v5；严格来源检查要求候选与公网 SHA 相同，因此本次未部署候选不能报告该项通过。完整门禁使用现有 `-ContinueAfterFailure` 收集其余检查及 APK，聚合失败仍如实保留。

API 覆盖清单已按新契约重新审查：相对 Mobile `origin/dev` 的 232 个 operationId 集合完全一致，本次只增加响应字段及说明，因此保留原 71 项排除及理由，仅将清单的契约版本固定为 `5.28.0-dev.20260929.1`。独立覆盖审计与最终统一门禁中的该项均确认 Mobile 范围 161/161，无缺口。
