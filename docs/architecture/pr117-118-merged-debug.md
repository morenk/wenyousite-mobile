# PR #117、#118 合并版 Debug 交付

状态：相册第二轮负责人验收通过；后台恢复仍待负责人真机验收。2026-10-25 负责人原话：“这个版本验收通过了，所有图片入口都能正常打开，合并 PR #117 吧。PR #118 的后台恢复也合并一个debug包让我一起验收”。本记录不把后台恢复的合并或自动测试通过记作原问题修复完成。

## 已合并范围与固定源码

- PR #117：be89da38c14f71d202a5ac59225f5858c9708a38，负责人通过的第二轮 APK 为 a87f51a93c5e；首轮 fd3a19181808 失败记录及原始反证见[相册记录](compose-gallery-candidate.md)。
- PR #118：746e6bdd4360f356cebee1cef14e423b1737910b；相同元信息恢复检查不重建帖子仓库，保留楼中楼窗口及阅读位置；真实能力、切号和权限变化仍按既有规则刷新。原场景与回归见[后台恢复候选](post-replies-resume-candidate.md)。
- 两条父链已通过组合提交3d95ca4902c6816e47e3d411025abb524ab51857进入dev；GitHub均标记已合并。本次不重复执行已完成的合并。
- 本次应用基线为已合并的dev提交b7e1a4acf9433b38b29505834b5f1eea77598330，同时包含 PR #119 的24dp半透明相册圆圈；旧64e0组合包没有这项视觉调整。
- Windows构建位置：D:\codex-worktrees\d5c9\wenyousite-mobile；交付分支codex/20261025-mobile-merged-debug。不修改其他活跃任务的Worktree。
- lib tree：442cb1c292521b899b5bccab67b75c118d8e11c7；应用源码清单SHA-256：b9a63ca3bce962a878e35c08bf5edc7f32d53583937cde7244dd27a20f6cd810。清单定义沿用原组合记录，不含文档、测试和构建产物；原件保存在D:/dev-cache/tmp/mobile-merged-debug-20261025/source-manifest-before.txt。
- Backend来源8a5d21858e04c69832c90e5a3a10f1e70fdcb545，API 5.44.0-dev.20261024.3；Foundation依赖仍锁定v7.6.0。

## 本地检查与产物

本轮对上述组合应用源码执行完整统一入口 `npm run check:apk -- -TestConcurrency 2`，最终退出码0。OpenAPI验证、固定来源、生成客户端再生成一致性及公网只读Markdown／GET兼容检查通过；1551个Dart文件格式零修改、应用和生成客户端全量分析零问题、架构边界、23模块文档及API覆盖门禁通过。实际测试路径为整个 `test/`：7841项Flutter测试通过、1项跳过、0失败（41分36秒），包括相册18入口、首次inset生命周期、图库打开中恢复前台取消保位和楼中楼恢复精确回归；49项Windows工具测试全部通过（118.4秒）。同一入口随后完成ARM64 Debug构建，Gradle124.2秒。

日志为D:/dev-cache/tmp/mobile-merged-debug-20261025/check-apk.log，SHA-256：d67cc4b25b81b1a25c89e632dc7869d256fa620393242a35c8552d0927c1a522。构建前后应用源码清单均为上述b9a63ca3摘要，应用、依赖、原生与生成客户端运行代码没有未提交差异；之后只补本文等验收文档，不使应用测试与APK失效。构建保留既有插件KGP提示，没有变更依赖或降低门禁。

新产物：`D:/dev-cache/artifacts/wenyousite-mobile/20261025/pr117-118-b7e1a4ac/app-debug-pr117-118-dc8feaccea96.apk`；114283017字节，2026-10-25 18:47:32（Asia/Shanghai）构建完成。SHA-256：`dc8feaccea965b10dd87072faac21dd306c7498bac0415039af2b0e8a2bbc96c`。原始build/app/outputs/flutter-apk/app-debug.apk与独立交付副本摘要一致；旧a87／64e0等包均未作为本次产物。

aapt核验“温油站 Debug”、site.wenyou.app.debug、0.10.0-debug／versionCode100、minSdk26／targetSdk36；aapt与ZIP原生目录均仅arm64-v8a。apksigner校验通过，v2=true、1个签名者，证书SHA-256为a3d950270933203c9f0abae0db0f0c112a5f162fba9199d8dec534cf55803fd7，与原Debug候选一致。权限保持图片读取／部分授权，无视频或定位权限。Debug kernel中核对相册稳定Key、四能力select和24dp圆圈对应半透明样式标记均存在，排除交付旧包；kernel SHA-256为e97f2752c46bdb3459f97c8508575b918abfffb153f98452981a98af75547234。

独立交付目录的evidence/保留完整门禁日志、前后源码清单、apk-identity.json、apk-badging.txt、apk-permissions.txt、apk-signature.txt及kernel-proof.json；不依赖当前Worktree被忽略的build目录保存新产物。

默认API为https://wenyou.site/api/v1，属于真实环境。代理仅执行离线回归、契约只读检查与构建，不安装、启动应用或执行业务写入；自动签到等正常启动行为交由负责人自行操作。无本轮新真机画面。

## 负责人同包复验

1. 安装交付包后打开“温油站 Debug”（site.wenyou.app.debug），确认各图片入口仍能打开；检查24dp半透明选择圆圈、取消再开、权限拒绝及设置返回。主题正文完全展开／展开字体列表时检查状态栏安全区，楼中楼底部回复栏和末条仍可见。
2. 楼中楼读到第14条中段，切其他应用后返回，确认可见回复和段落内位置不跳到顶部；复验倒序、作者筛选和分页。图库打开中切后台，返回后取消图库，讨论仍停在原位置。
3. 恢复前台仍应正常检查更新；切号、退出、权限失效应刷新旧账号内容。系统杀进程后重开不属于本次进程内阅读保位承诺。本轮后台恢复通过与否由负责人明确反馈记录。

保留原失败包、两轮相册候选、原组合包和后台恢复任务现场；后台恢复未验收，不清理其分支／Worktree。当前Worktree继续承载新合包与交付记录，不移除或归档。
