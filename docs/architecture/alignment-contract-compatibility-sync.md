# 行距候选的 API 契约兼容同步

历史记录：本文描述已验收的 5.43 独立候选。2026-10-24 合并准备已集成完整字体功能并同步 5.44；当前范围见[集成验收记录](alignment-font-integration-acceptance.md)，下文无字体声明只适用于原候选。

本切片按负责人要求解除行距候选的生产契约门禁阻塞，不接入独立 PR 114 的字体选择、下载或缓存功能。

## 固定来源

- Mobile 基线 `6f0064507a77e2034250ee4fd9f1d382e0a063a9`。
- Backend 已提交来源与本轮只读 `/api/v1/meta` 的 buildSha 均为 `bc1135b72557eb6025a541dbd10119cf528ff989`。
- API 由 `5.40.0-dev.20261018.1` 同步为 `5.43.0-dev.20261022.3`。
- `tool/sync_backend_contract.ps1` 从该精确 SHA 导出 OpenAPI、既有契约、23 份字体契约/文档；既有单独固定的列表和行内组合夹具继续遵照来源清单，不冒充本轮来源。
- 公共 Markdown fixtures 仍为 v4，部署声明 v5；已有图片对齐及角色提及能力协商保持原逻辑，严格核验脚本未更改。

## 差异与兼容边界

新增 18 个字体操作（12 个管理、6 个公开读取）及字体 DTO；未删除既有操作或 Schema，既有 DTO 未新增必填字段。正文写入的 `textFontVersion` 和 meta 中四个字体能力字段均为可选。生成客户端由固定生成器重新生成，不手改产物。

本候选不发送 `X-Text-Font-Version`，不设置写入 DTO 的 `textFontVersion`。服务端向无能力客户端提供移除字体标记的安全副本，并在原正文含字体时拒绝降级覆盖。40019–40021 属于已知业务拒绝，使用保留草稿的恢复动作与安全提示，不当作未知异常；不自动重放写入。

新增端点在 `tool/api_coverage_exclusions.json` 精确登记：管理端点为 Mobile 范围外，公开字体读取为独立 PR 114 待接入；不计作本切片覆盖完成。资源 manifest 作为精确来源契约保存，不纳入手写 Dart 行数限制。

## 验证记录

- `build/alignment-contract-production.log`：严格生产核验通过，API、来源 SHA 与只读线上 meta 一致，公开主题列表 Schema 兼容。
- 定向验证覆盖 meta 新增/缺省字段、生成 DTO 不声明字体能力、实际网络 provider 不发送字体头，以及字体拒绝分类与保留内容。
- 首轮完整入口的应用静态检查和 7367 项 Flutter 测试通过，Windows 契约同步工具测试因临时 Backend 缺失新增字体来源目录失败。已补齐测试夹具的 docs/archive 原始结构，并新增 23 份字体契约逐字一致断言；保留失败日志 `build/alignment-contract-final-full-gate.log`，完整入口重新执行，不以分段补跑冒充同次成功。
- 最终官方完整门禁与新 APK 身份补记于[行距候选](editor-alignment-spacing-candidate.md)；旧诊断 APK 不代表本轮最终源码。
- 补齐夹具后，同一次 `npm run check:apk -- -TestConcurrency 2` 完整成功：7367 项 Flutter 测试、49 项 Windows 工具测试通过，1 项原条件跳过，随后 ARM64 Debug 构建成功。日志为 `build/alignment-contract-final-full-gate-2.log`。交付前再次严格只读复核线上 SHA/API 仍一致，见 `build/alignment-contract-delivery-production.log`。
- 本轮没有自动安装、启动客户端或执行线上业务写入。字体拒绝的错误分类、保留内容标志与提示由本地模拟响应验证；未执行含字体原文的真实保存，此历史交付时点负责人真机验收仍待完成；随后原候选已于 2026-10-24 验收通过。
