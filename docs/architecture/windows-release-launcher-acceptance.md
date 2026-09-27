# Windows 发布入口解释器路径候选

状态：候选／待负责人验收。范围仅为两个标准桌面 `.cmd` 的 Windows PowerShell 定位方式；不改变发布流程、凭据、SSH 指纹、APK 构建或线上策略。

2026-09-27 在更新说明 PR #71 合入 `dev` `a4a7f13dc177869768c7bf98a276e4082e984354` 后，本机原标准 Installer 已更新五个 PowerShell 程序及两个桌面入口，受限 `--help` 成功且支持 `--preflight` 与 `--notes-revision`。安装前后 SSH 私／公钥、config、known_hosts、DPAPI 文件、签名 properties 和 keystore 内容均不变，配置路径字段保留。记录位于 `D:\code\wenyousite\artifacts\mobile-release-notes-20260927\windows-release-tools`。

原场景：当前、用户和机器 PATH 均不包含 Windows PowerShell，`where powershell.exe` 返回1；系统目录中的解释器实际存在。原桌面入口裸调用该名称，因此找不到解释器。未为复现而启动实际发布入口：回归在含空格的临时目录复制原入口，清空 PATH，将 LOCALAPPDATA 指向临时目录，两个目标 PowerShell 脚本均仅输出固定标记并返回23。

精确回归位于 `tool/windows/windows_release_scripts.test.mjs` 的“桌面入口在 PATH 无 PowerShell 时仍调用系统解释器并保留失败退出码”。旧实现实际返回9009并提示找不到 `powershell.exe`（`build-release-launcher-before.log`）；候选通过两个入口的标记及退出码断言。完整执行该测试文件，11/11通过（`build-release-launcher-after.log`）。候选仅将命令改为带引号的系统绝对路径，不修改用户或机器 PATH，仍调用原安装目录中的脚本。

应用、依赖、契约、发布 Shell 与 PowerShell 实现均未改变；沿用 PR #71 的应用验证证据，不重复 Flutter 全量测试或 APK 构建。真实桌面发布／SSH初始化未执行，后续标准 Installer 更新与受限只读检查不能冒充真实发布或负责人手工验收。本切片不构建、不上传、不发包、不打 Tag、不晋级，也不在线创建说明。
