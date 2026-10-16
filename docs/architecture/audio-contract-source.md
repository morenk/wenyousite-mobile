# 音频契约来源

固定 Backend 已合并提交 `7f95563edd8f461ebb7a66d7b458ec0349e39297`，通过 Windows 只读镜像与 `tool/sync_backend_contract.ps1` 导出。OpenAPI `5.39.0-dev.20261017.1`，Markdown 主版本属性保持 4，独立 `markdown-audio-v1` 不变；没有自拟 title 标记。该提交契约树与合并前已验证的 `78685f48` 相同，最终仅更新来源元数据，没有机械重新生成相同 SDK。

音频准入新增错误 `42901 AUDIO_ACTIVE_LIMIT`、`42902 AUDIO_DAILY_BYTES_LIMIT`，成功 DTO、音频大小／格式／码率与 Markdown 均不变。SDK 经既有生成器及规范化脚本重建，数字错误码反序列化有定向验证；每日／活动预算由 Backend 执行，客户端不推算配额或自动重建媒体身份。同步的上游颜色能力为可选字段／读取头及 `40016–40018`，本切片不声明颜色能力、不实现颜色 UI；后端向旧能力端返回去色副本并保护含颜色正文覆盖。

本批合并只读观察为线上 `d3577839dc537e21c546ee385a4c97091b58a8f7`／API `5.38.0-dev.20261016.1`；与最终固定契约的差异为预算错误和版本元数据，没有成功 DTO 或 Markdown 破坏。线上精确版本检查仍失败，负责人仅批准本批延期到部署核验，不修改检查器，也不在本任务部署。

同步包括 OpenAPI、版本关联 fixture、audio fixture/schema 与 `audio-upload.md`。SDK 由固定 OpenAPI 生成，后续来源提交只修关联版本，不重复生成相同 API。`normalize_generated_api.dart` 对唯一数字 version=1 枚举改用 `wireNumber`，真实 /meta JSON 反序列化有定向覆盖。未扩展其他 DTO 规范化。

能力缺失默认关闭新上传；投影校验与正文阅读独立。旧端无 title 链接往返及同 URL 独立链接边界由消费者回归保护。兼容与回滚见 [弃用登记](../deprecation-register.md)。
