# 图片上传切片的后端契约同步

## 固定来源

- 旧基线：Backend `e214fd18637cb10d79576c5ab5a4cf42340fef71` / OpenAPI `5.23.0-dev.20260913.1`。
- 新基线：已核验远端 `origin/dev` 与公网 `/meta` 对应的 Backend `fc88ea09a808af9c54c1f5b971e116b3be4a471b` / OpenAPI `5.24.0-dev.20260920.1`。
- 通过 `tool/sync_backend_contract.ps1` 从 Windows 后端只读参考镜像的上述已提交 SHA 导出契约。保留独立固定的 editor-list 与 inline-combinations 语料来源。
- Foundation 已在独立提交 `5bc62ed096b90659ed7e92555b00a76524e5a39f` 固定正式 `v7.1.0`，本次不再更新依赖。

## 审查结论

同步新增 `adminContentList`、`adminContentDetail`、`adminContentUpdateTaxonomy` 三个管理端点，以及对应管理台 DTO 和管理统计字段。移动端 V1 不承载管理产品，三个端点已在同步覆盖契约及本地排除清单登记为 `not_applicable` / `admin_product`。

将旧、新 OpenAPI 解析为对象并按键排序后逐项比较：全部 `/media` 路径保持一致；名字含 media、upload、image、markdown 的既有 Schema 保持一致，此范围仅新增管理台专用 `AdminContentMediaDto`。本轮图片上传、确认、查询、用途校验和 `COMPLETED` 语义均未改变，无需新增兼容协议或移动端业务接入。

生成客户端使用仓库固定 OpenAPI Generator `7.23.0` 和既有规范化脚本，不手改 `packages/wenyou_api`。该提交仅同步契约、生成客户端、覆盖排除项和来源说明，不包含本机附件或上传交互功能。

## 验证

- `npm run api:validate`：通过。
- `npm run api:generate`：通过；固定生成器、规范化与 built_value 生成完成，生成结果与上述兼容变更逐项审查。
- `dart run tool/audit_api_coverage.dart --require-complete`：适用端点 `158/158`，无遗漏；总计 223 个端点，排除 65 个。
- `dart run tool/check_docs.dart`：21 个模块文档通过。完整 Flutter／APK 门禁由上传体验主任务在最终源码上统一执行，避免重复构建。

所有模块的第 13 节记录新的已发布契约来源；已有上传体验功能说明保留在工作区，由后续功能提交交付。本次未合并、部署或修改后端镜像源码。
