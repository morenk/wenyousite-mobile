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

同步、失败门禁与单独来源复核日志分别为 `.mobile-update-reply-contract-source-sync.log`、`.mobile-update-reply-full-check-source-failed.log`、`.mobile-update-reply-source-verify.log`；最终完整门禁另行从唯一入口重跑，结果汇入[候选和合并记录](mobile-update-reply-navigation-candidate.md)。

应用 `lib` tree 仍为 `cf64354ad08226fd6c301ed68cc268cf7c48072f`，原候选 APK 继续有效，不重新构建或安装。此来源同步不代表负责人新增真机验收，也不恢复已明确跳过的第三项定位调查。
