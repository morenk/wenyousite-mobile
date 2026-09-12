# API 覆盖清单契约复核

2026-09-11 列表候选完整门禁发现：契约来源已同步到 Backend `062412601b3a8dbf4f64494115a2445d312dd53d`，但 API 排除清单仍登记 `5.20.0-dev.20260909.1`，审计按规则失败。

比较整合基线 `765f023d84ec89af42bff41876fb1870aadc5477` 与当前 `contracts/openapi.json`：差异仅为版本 `5.20.1-dev.20260911.1` 及收藏夹计数字段的可见性说明。HTTP 路径、方法、operationId、字段类型和必填规则均未变化。已逐项复核 `tool/api_coverage_exclusions.json`，管理端、暂缓能力与被聚合接口替代的排除范围不变，不增删排除项。

本次只补齐已审查的清单版本，重新执行 `dart run tool/audit_api_coverage.dart --require-complete`；不修改审计逻辑、不跳过检查、不扩大排除范围。生成客户端再生成一致性已由同轮完整门禁核对。
