# 超链接切片的兼容契约来源复核

Mobile 基线 `84d0a0d80eb60dc07503c6a5ed7bf5eb5b4f74f3` 记录 Backend `e807a3aa0cb15a626e5601eedc93f23c72d2e6c4` / API `5.27.1-dev.20260928.1`。开始本切片时，已更新的 Backend `origin/dev` 与公网只读 `/meta` 均为 `21acf512285f2a21aaa831f960211780de73aafc` / `5.28.0-dev.20260929.1`，因此先通过契约同步脚本与固定生成器更新消费者。

增量只有四种帖子 DTO 的可选 nullable `editedAt`、契约版本和相关 fixtures 的版本登记；未改变链接、Markdown、路由、权限或 HTTP 操作集合。本次仅生成字段，不接入编辑时间展示，应用运行行为与原验收状态保持。API 覆盖排除理由保持，生成 DTO 的缺省、null 与精确时间兼容用例复用已提交 `09a24f35f67581be3adc671ed81fd915e528e68d`。

同一兼容字段已由独立编辑时间任务的 PR #77 同步；本次固定的是已合并并部署的 Backend SHA。两个任务合并时需保留最新已验证来源，避免旧来源元数据回退，不带入另一个任务尚待验收的界面行为。

Foundation 已 fetch 正式 Tags，最新仍为 `v7.2.1`，与 pubspec 和 lock 一致；站内传送门与普通外链遵循该正式版本的既有区分，本次无需新契约。
