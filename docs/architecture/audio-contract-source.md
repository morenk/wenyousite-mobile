# 音频契约来源

固定 Backend `9159729106cefb883726121dc9f94c0b164678c1`，分支 `codex/20261017-audio-resource-budget`，通过 Windows 只读镜像与 `tool/sync_backend_contract.ps1` 导出。OpenAPI `5.38.0-dev.20261017.1`，Markdown 主版本属性保持 4，独立 `markdown-audio-v1` 不变；没有自拟 title 标记。

本次仅增加音频准入错误 `42901 AUDIO_ACTIVE_LIMIT`、`42902 AUDIO_DAILY_BYTES_LIMIT`，成功 DTO、音频大小／格式／码率与 Markdown 均不变。SDK 经既有生成器及规范化脚本重建，数字错误码反序列化有定向验证；每日／活动预算由 Backend 执行，客户端不推算配额或自动重建媒体身份。契约已提交不代表该预算后端已部署；此前兼容部署仍为 `1aa8655f`。

同步包括 OpenAPI、版本关联 fixture、audio fixture/schema 与 `audio-upload.md`。SDK 由固定 OpenAPI 生成，后续来源提交只修关联版本，不重复生成相同 API。`normalize_generated_api.dart` 对唯一数字 version=1 枚举改用 `wireNumber`，真实 /meta JSON 反序列化有定向覆盖。未扩展其他 DTO 规范化。

能力缺失默认关闭新上传；投影校验与正文阅读独立。旧端无 title 链接往返及同 URL 独立链接边界由消费者回归保护。兼容与回滚见 [弃用登记](../deprecation-register.md)。
