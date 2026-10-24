# 相册候选的后端精确来源同步

2026-10-24，本任务 Windows 本地完整门禁核对到公网 Backend 已从 `31f39ff317e56d6eb49b4c5e60ecdb93dfc9ec06` 更新为 `33574ae73d88123aa216a93f9cc81eab60fb9ee9`，API 保持 `5.44.0-dev.20261024.2`。

后端只读镜像 fetch 后，按已部署完整 SHA 执行官方 `tool/sync_backend_contract.ps1 -BackendPath D:/code/wenyousite/references/wenyousite-backend -Revision 33574ae73d88123aa216a93f9cc81eab60fb9ee9 -SkipFetch`。`git show -s --format=%P` 确认该合并提交的第一父提交就是原固定 31f39ff3；后端 PR #62 修复字体处理。两提交 contracts/ 与 docs/mobile-client-guide.md 的 diff 为空，OpenAPI、共享夹具和消费者指南无差异；导出的 docs/dynamic-text-fonts.md 运维说明增加八行及来源 SHA 更新。本 Mobile 切片不改字体实现、缓存、上传协议或 Backend 源码，也不跟随更晚的浮动分支。

来源同步使用独立 chore；相册／安全区／回复栏仍为候选，未获负责人原场景真机验收。同步前完整门禁因精确 SHA 不同失败，不能算通过；生成客户端已在该运行中重新生成且 diff 为零。更新来源后再次按唯一完整入口检查。

Docs-Impact：updated，仅更新来源及导出说明，不改变 Mobile 应用行为。

验证：官方同步仅上述两个 contracts 文件变化；此前完整入口的 API 再生成 diff 为零。更新后 tool/check_contract_sources.dart、tool/verify_production_api.dart 和 tool/check_docs.dart 均通过（23 个模块）。
