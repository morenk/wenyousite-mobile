# 主动检查更新与空回复合并前的契约来源复核

合并前完整 `npm run check` 在生产来源身份核验处停止：本地固定 Backend `8a5d21858e04c69832c90e5a3a10f1e70fdcb545`，公网 `/meta` 为 `d54313346681eae8f62584d63d07f3315e42381b`；API 均为 `5.44.0-dev.20261024.3`。不能仅凭机器契约相同绕过精确来源检查。

通过受支持入口执行：

```powershell
pwsh -NoProfile -File tool/sync_backend_contract.ps1 -BackendPath D:/code/wenyousite/references/wenyousite-backend -Revision d54313346681eae8f62584d63d07f3315e42381b
```

脚本从已提交的 Backend `origin/dev` 读取，没有修改或运行 Windows 后端镜像。实际 diff 仅包括：

- `contracts/backend-contract.properties` 的 Backend revision 更新为已部署来源。
- `contracts/dynamic-text-fonts.md` 镜像同步后台字体编译器对嵌入位图／空字形的说明和回归入口；不是 Mobile 字体协议或客户端实现变化。

OpenAPI、机器 fixtures、移动端指南、生成 SDK、应用 `lib` 和依赖锁文件均无变化。固定 editor-list 与行内组合语料来源保留，没有 Foundation、弃用协议或消费者行为迁移。API 再生成一致性已在失败前通过，来源同步后生产只读校验通过：`sourceMarkdown=4`、`deployedMarkdown=5`，客户端原有支持范围包含两者，`GET /threads` Schema 兼容。

第二轮完整门禁已通过应用／生成 SDK 全量分析及架构检查，但文档门禁要求全部 23 模块登记精确 Backend revision。现已在各模块第 13 节追加本轮来源复核和本记录链接，保留原历史 SHA，不更改检查脚本或模块原有验收结论；随后先预检文档、API 覆盖与 Windows 工具测试，再从唯一完整入口重跑。

同步、失败门禁与单独来源复核日志分别为 `.mobile-update-reply-contract-source-sync.log`、`.mobile-update-reply-full-check-source-failed.log`、`.mobile-update-reply-source-verify.log`；最终完整门禁另行从唯一入口重跑，结果汇入[候选和合并记录](mobile-update-reply-navigation-candidate.md)。

来源同步环节的应用 `lib` tree 为 `cf64354ad08226fd6c301ed68cc268cf7c48072f`，当时没有重建 APK。随后在前两项范围内发现动态合法纯文本会被 Markdown 判空误拒绝，补丁改变应用源码，最终将通过完整 `check:apk` 重新验证并生成新包；新旧身份以[候选和合并记录](mobile-update-reply-navigation-candidate.md)分别登记。来源同步和后续补丁均不代表负责人新增真机验收，也不恢复已明确跳过的第三项定位调查。

完整收集还发现 `test/core/network/audio_budget_contract_test.dart` 固定旧来源 SHA 的唯一断言未同步；现已将其精确值对齐已独立核验的 `d54313346681eae8f62584d63d07f3315e42381b`，保留所有既有错误码、Schema 和旧 `42900` 兼容断言，没有泛化为任意 SHA 或跳过测试。
