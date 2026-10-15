# 音频契约来源

固定 Backend `cb44acaeb7fbc735fb569276aef00435bf24efe5`，分支 `codex/20261016-audio-uploads`，通过 Windows 只读镜像与 `tool/sync_backend_contract.ps1` 导出。OpenAPI `5.37.0-dev.20261016.1`，Markdown 主版本属性保持 4，新增独立 `markdown-audio-v1`；没有自拟 title 标记。

同步包括 OpenAPI、版本关联 fixture、audio fixture/schema 与 `audio-upload.md`。SDK 由固定 OpenAPI 生成，后续来源提交只修关联版本，不重复生成相同 API。`normalize_generated_api.dart` 对唯一数字 version=1 枚举改用 `wireNumber`，真实 /meta JSON 反序列化有定向覆盖。未扩展其他 DTO 规范化。

能力缺失默认关闭新上传；投影校验与正文阅读独立。旧端无 title 链接往返及同 URL 独立链接边界由消费者回归保护。兼容与回滚见 [弃用登记](../deprecation-register.md)。
