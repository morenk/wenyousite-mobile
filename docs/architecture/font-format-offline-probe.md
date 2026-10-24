# 字体格式离线 Flutter 验证

本工具用于验证后端导出的真实 Mobile SFNT 字节能否在 Windows Flutter 测试引擎加载和绘制。它不进入应用运行时，不联网，不生成或安装 APK，也不代表 Android 真机验收。正式样本未到齐前，仓库测试字体只用于验证工具自身，不能计入后端格式兼容结果。

## 输入与执行

使用已提交后端 SHA 产生的产物；将其来源、许可证、原字体 SHA、处理参数及默认轴证据保留在后端交付记录中。下面的 JSON 是本工具的本地输入清单，不是新增 HTTP 或跨端契约。若后端交付清单形状不同，可从已校验交付记录建立该输入清单，不改变字体字节。

```json
{
  "schemaVersion": 1,
  "evidenceKind": "backend-artifacts",
  "backendRevision": "完整40位提交SHA",
  "samples": [
    {
      "id": "static-ttf",
      "file": "mobile/font.ttf",
      "sha256": "完整64位字体SHA256",
      "outline": "glyf",
      "defaultInstance": false,
      "text": "Wenyou Aa 0123"
    }
  ]
}
```

`outline` 接受 `glyf`、`CFF `（末尾空格）和 `CFF2`；静态 CFF OTF 使用 `CFF `。可变字体经后端默认实例化的输出设置 `defaultInstance: true`，要求产物无 `fvar`。这只能证明输出静态化，默认轴值与轮廓的正确性仍须引用后端源字体/输出对比证据，不能仅凭字段自述证明。

文件路径必须相对输入目录，解析链接后仍须位于目录内，摘要必须匹配。样张为 1–64 字符单行；中、日使用 `温油文字 Aa 0123`，英及未分类使用 `Wenyou Aa 0123`。样张字符必须为字体声明覆盖范围；若产物是分片，应为对应分片选择它实际覆盖的探针，完整文案需另用完整实例或完整分片集合验证，不能把回退当作成功。

```powershell
flutter test --no-pub tool/font_format_probe_test.dart --reporter expanded `
  --dart-define=FONT_PROBE_ROOT=D:/font-evidence/input `
  --dart-define=FONT_PROBE_MANIFEST=probe.json `
  --dart-define=FONT_PROBE_MANIFEST_SHA256=<清单SHA256> `
  --dart-define=FONT_PROBE_BACKEND_SHA=<后端提交SHA> `
  --dart-define=FONT_PROBE_OUTPUT=D:/font-evidence/output-new
```

输出目录必须为空。每个通过样本输出白底 PNG；`result.json` 保存输入身份、轮廓表、对照字体 SHA、像素/PNG SHA、可见像素数与行宽。中途失败时 `complete: false`，之前通过的样本不能替代完整验收。进程退出码非零或未生成结果文件均不算通过。引擎版本另记录 `flutter --version`，保存完整执行命令和日志。工具自身试运行使用 `evidenceKind: harness-self-check`，不得混同 `backend-artifacts` 的正式样本证据。

## 防止回退误判

`FontLoader.load()` 返回不等于字体已经用于绘制。本工具逐个可见字符比较两套不同回退字形，并加入完全未注册家族的对照；目标在不同回退下必须一致、非空，且不能与未注册家族的两次输出同时相同。整行另做绘制比较，确认可见结果稳定。无法区分对照的字符会失败，不给出兼容结论；目标字体恰与默认回退逐像素相同时也可能保守拒绝，需要补充可区分探针或独立字形证据，不能放宽断言。

`test/tool/font_format_probe_test.dart` 使用仓库既有字体执行真实引擎自测，并验证未注册家族、局部缺字、摘要不符、目录越界、轮廓类型错误、未实例化可变字体均被拒绝。它不宣称覆盖后端 TTF/CFF OTF 产物。

## 本轮契约范围

锁定 Backend `2db4ef1254c7738966dc28b1cd1fc10dcb19da47` / API `5.44.0-dev.20261024.3`。OpenAPI 仅版本号变化；四类自动样张文案统一，历史快照保持。Mobile v2 读取后端 PNG，不实现样张文案生成或新增字体管理入口。同步共享夹具、生成客户端与契约来源记录；再生成后仅 SDK README 版本变化，应用及 SDK 可执行代码、依赖锁文件均无变化。

## 2026-10-24 首批产物结果

后端交接归档 `mobile-handoff-v1.tar.gz` SHA-256 为 `88fec204b99b2b9b3b3dcf0f8e708063d01635fbd50e1114fb0d1177ae8b3b31`，传输后核验摘要和成员，无绝对路径、父目录穿越、链接或源码。各样本字体、原 manifest、Web 字体、样张与许可摘要全部匹配，选中分片确实位于对应原 manifest 中。Python 仅用于文件/摘要/清单处理，不承担 Flutter 验收。

Windows Flutter `3.44.8` / Dart `3.12.2` / engine `0cd610717bde95fd88343c64f81c11ba4e5c0010` 的真实 `flutter_tester` 对四个 core 分片全部通过。样张为 `Wenyou Aa 0123`；字形和整行均通过非空、两套回退与未注册字体反证。静态 TTF/CFF 是后端合成轮廓夹具，不能将其画面当作商业字体审美样张。

| 产物 | 轮廓 | 可见像素 | 行宽 | 结果 |
| --- | --- | ---: | ---: | --- |
| 静态 TTF | glyf | 5112 | 336.00 | 通过 |
| 静态 CFF OTF | CFF1 | 5208 | 336.00 | 通过 |
| Orbitron 默认实例 | glyf，无 fvar | 4270 | 380.52 | 通过 |
| SourceSerif4 默认实例 | CFF1，无 fvar | 2827 | 289.00 | 通过 |

原始身份、compiler/source SHA、默认轴证据、输出 PNG 与像素摘要见[证据目录](../verification/font-format-regression-20261024-v1/)。默认轴轮廓正确性的对比来自后端交接证据；本端独立确认静态轮廓类型和真实 Flutter 绘制。

此批明确为 **parametersVersion=1**，虽然内部 manifest 为 v2，不能单凭此批宣称 parametersVersion=2 处理链路已验证。不覆盖未交付分片、全部字符、Android 真机或源可变字体的非默认轴。后续 parametersVersion=2 独立复验见下一节，首批记录保留。

定向消费者与工具自测共 23 项通过，实际路径：

- `test/tool/font_format_probe_test.dart`
- `test/core/network/admin_font_management_contract_test.dart`
- `test/core/network/audio_budget_contract_test.dart`
- `test/core/text_fonts/dynamic_font_manifest_test.dart`
- `test/features/editor/editor_font_specimen_test.dart`

正式样本另执行一次 `tool/font_format_probe_test.dart`，约 44 秒，四样本全部通过。输入清单 SHA-256 为 `740888d05a3d2fcb249484a1b497937af332e94c1495d24e2943dd76a456fcbb`。本轮按授权执行离线定向验证，未运行全量 Flutter 测试、未构建/安装 APK、未执行生产登录或业务写入，不宣称完整集成门禁或真机验收通过。

## parametersVersion=2 独立复验与版本比较

第二批归档 `mobile-handoff-v2.tar.gz` 的 SHA-256 为 `91f4a48e683f08b965f7fcb24f6a87533cf8295dbf3ce79ce9e5894526461751`。34 个成员共 496687 字节，全部通过相对路径、无父目录穿越、无链接、无源码及资产/许可摘要核验。compiler SHA-256 `824849c888cfaa571e35ae7b605c9afcedc75a68ed3c9bb2de4f2b32c7a70560` 独立核对与 Backend `2db4ef1254c7738966dc28b1cd1fc10dcb19da47` 的 `scripts/fonts/dynamic/compile-v2.py` 完全一致。

使用同一 Flutter/Dart/engine 和未变化的验证器，按 `parametersVersion=2` 再执行四种真实 core 分片，约 34 秒全部通过 FontLoader、逐字防回退和实际绘制。输入清单 SHA-256 为 `fad40f8904673e1a2ab7d4b5c3a3aa1b23c38201f616b04e8fae619c7668977c`；输入目录为 `build/font-format-v2/extracted/font-format-samples`，输出为 `build/font-format-v2/flutter-output`，其余调用参数沿用上文命令模板。

v1/v2 四组源字体 SHA 相同，输出字体 SHA 均不同。TTF 差异位于 `head`、`name`；CFF OTF 另含 `CFF ` 表中的家族名称变化。将旧家族标识替换为新标识，并将 `head.checkSumAdjustment` 的四字节归零后，所有对应表字节完全一致。此操作只用于内存中的比较，没有改写或重新生成输入字体；引擎加载的始终是归档原始字节。

四组输出 PNG 字节、像素 SHA、可见像素数、行宽均与首批完全一致。证明范围是本次 `Wenyou Aa 0123` 样张和已交付 core 分片，不推断其他分片、所有字符或非默认轴的画面。完整比对结果、独立输入和输出见[v2 证据目录](../verification/font-format-regression-20261024-v2/)。

至此，两种参数版本各四类产物的 Windows 离线 Flutter 验证完成。此增量只添加验证证据与文档，应用运行时、生成客户端与验证器源码均未变化，沿用首批静态分析、23 项定向测试及格式等检查，不重复全量门禁。PR 可进入评审；未执行 Android 真机验收、APK 构建/安装、合并或部署。
