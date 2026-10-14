# 测试专用字体

`WenyouGoldenText-Variable.ttf` 是 Noto Sans SC Variable 的测试子集，只由 Widget/Golden 的 `loadDeterministicTestFonts` 加载，不在 pubspec 资源中，不进入 APK。运行时继续继承平台系统字体。

文字工具箱补齐原子集缺失的 4 个字形；原有 1253 个 Unicode 映射均保留，结果为 1257 个。来源是已发布 Foundation v6.11.0 的历史 Noto Sans SC 字体（提交 `ba9a237040de3969525ad814f08ef343a5de902d`），源文件 SHA-256 为 `a3041811a78c361b1de50f953c805e0244951c21c5bd412f7232ef0d899af0da`。使用 fontTools 4.66.1 子集选项，layout_features、name_IDs、name_languages 均为 `*`，notdef_outline 为 true，其余默认；保留旧字体 cmap 并加入 `lib/features/toolbox` 使用的源字体可用字符，不引入新的产品字体依赖。

新增字形为古（U+53E4）、摩（U+6469）、斯（U+65AF）、花（U+82B1）。等价核验：旧 1253 个字符在 weight 100/400/700/900 下的分解轮廓和 advance 均无差异；未映射字形的 `.notdef` 轮廓和 advance 也必须相同，避免旧缺字方框消失。保留原布局特性，其他模块的 Golden 不批量重录。

字体许可见同目录 `LICENSE.txt`。新增文案的 Golden 出现方框时应先核查测试字形覆盖，不能把缺字画面当成验收结果。

进阶起名反馈批次继续使用同一来源和 fontTools 参数，保留上次 1257 个 cmap 映射，加入进阶控件、页面、结果和对应两份 Widget 测试所需字形，以及姓名结果固定样例“詹姆斯／迈克尔／斯蒂芬／蒙哥马利-威灵顿”，现为 1277 个映射。旧映射的水平 advance 与 side bearing 均核对一致，且旧 1257 字符及 `.notdef` 在 weight 100/400/700/900 下的分解轮廓与 advance 全部相同；只扩展测试子集，不更改产品字体、pubspec 或原生资源。本轮只重录受补字影响的姓名范围 Golden，不批量覆盖其他模块画面。
