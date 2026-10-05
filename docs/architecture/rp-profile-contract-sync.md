# RP 资料楼层兼容契约同步

消费者固定 Backend `60273e5576c9837f645245ae2c610ba8a3f81ea1`（`codex/20261005-rp-profile-post`），API `5.36.0-dev.20261005.1`。同步仅来自 Git 已提交文件；公网后端仍使用原契约，尚未授权本扩展部署。

`tool/sync_backend_contract.ps1` 同步 OpenAPI、现有版本语料及新增 `rp-identity-profile-post.v1.fixtures.json`、对应 Markdown 规范；OpenAPI Generator 保持 `7.23.0`。生成包新增可选能力、资料字段及状态枚举，不删除旧接口与字段。

客户端缺少 `rpIdentityProfileSupported` 时隐藏编辑字段且不发送新增字段。生成客户端省略 null，解绑必须发送 `clearProfilePost=true`；省略保留原绑定。本人 `identity.profilePostId` 与已按访客过滤的顶层 `profilePostId/profilePostStatus` 用途不同，不能用后者覆盖编辑资料。正文使用既有 `postsFindById` 授权接口，不存正文快照或访问任意 URL。

本同步提交独立于应用候选；生成、契约来源及同步脚本检查证据随任务验收记录维护。最终应用、真机与跨端写入验收仍待完成，合并与部署另行决定。
