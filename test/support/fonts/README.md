# 测试专用字体

`WenyouGoldenText-Variable.ttf` 是 Noto Sans SC Variable 的测试子集，只由 Widget/Golden 的 `loadDeterministicTestFonts` 加载，不在 pubspec 资源中，不进入 APK。运行时继续继承平台系统字体。

文字工具箱补齐原子集缺失的 4 个字形；原有 1253 个 Unicode 映射均保留，结果为 1257 个。来源是已发布 Foundation v6.11.0 的历史 Noto Sans SC 字体（提交 `ba9a237040de3969525ad814f08ef343a5de902d`），源文件 SHA-256 为 `a3041811a78c361b1de50f953c805e0244951c21c5bd412f7232ef0d899af0da`。使用 fontTools 4.66.1 子集选项，layout_features、name_IDs、name_languages 均为 `*`，notdef_outline 为 true，其余默认；保留旧字体 cmap 并加入 `lib/features/toolbox` 使用的源字体可用字符，不引入新的产品字体依赖。

新增字形为古（U+53E4）、摩（U+6469）、斯（U+65AF）、花（U+82B1）。等价核验：旧 1253 个字符在 weight 100/400/700/900 下的分解轮廓和 advance 均无差异；未映射字形的 `.notdef` 轮廓和 advance 也必须相同，避免旧缺字方框消失。保留原布局特性，其他模块的 Golden 不批量重录。

字体许可见同目录 `LICENSE.txt`。新增文案的 Golden 出现方框时应先核查测试字形覆盖，不能把缺字画面当成验收结果。

进阶起名反馈批次继续使用同一来源和 fontTools 参数，保留上次 1257 个 cmap 映射，加入进阶控件、页面、结果和对应两份 Widget 测试所需字形，以及姓名结果固定样例“詹姆斯／迈克尔／斯蒂芬／蒙哥马利-威灵顿”，现为 1277 个映射。旧映射的水平 advance 与 side bearing 均核对一致，且旧 1257 字符及 `.notdef` 在 weight 100/400/700/900 下的分解轮廓与 advance 全部相同；只扩展测试子集，不更改产品字体、pubspec 或原生资源。本轮只重录受补字影响的姓名范围 Golden，不批量覆盖其他模块画面。

花体扩充使用独立 `toolbox_test_fonts.dart` 和 `toolboxGoldenTheme` 为本轮花体与时间顺序 Golden 指定 fallback；原 `WenyouGoldenText-Variable.ttf` 不变。新增十三个 `WenyouGolden{ToolboxText,Math,Symbols2,Latin,Oriya,Javanese,Yi,Canadian,Hebrew,Thai,Georgian,Cherokee,Lisu}.ttf` 均只位于测试目录，没有 pubspec 声明。测试字体证明离线样例可读，不代表 Android 系统字体覆盖或真机验收。

- ToolboxText 使用上文 Foundation 历史 Noto Sans SC 源，只补本轮清单、预览及进阶标签字形，许可沿用 `LICENSE.txt`。
- Math 使用 [notofonts/math](https://github.com/notofonts/math/tree/53eb8eb200ed8fc73fa13d97d26a2c9c56428c17) 的 `fonts/NotoSansMath/full/ttf/NotoSansMath-Regular.ttf`；许可见 `LICENSE.NotoSansMath.txt`。
- Symbols2 使用 [notofonts/symbols](https://github.com/notofonts/symbols/tree/75173e0ca9576fac893289344c5977c7fc2e60e3) 的 `fonts/NotoSansSymbols2/full/ttf/NotoSansSymbols2-Regular.ttf`；许可见 `LICENSE.NotoSansSymbols.txt`。
- Latin、Oriya、Javanese、Yi、Canadian、Hebrew、Thai、Georgian、Cherokee、Lisu 使用 [notofonts/noto-fonts](https://github.com/notofonts/noto-fonts/tree/ffebf8c1ee449e544955a7e813c54f9b73848eac) 对应 `hinted/ttf/<家族>/<家族>-Regular.ttf`；Latin 为 NotoSans，Canadian 为 NotoSansCanadianAboriginal，其余为 NotoSans 加对应名称。许可见 `LICENSE.NotoAdditional.txt`。

每个源文件 SHA-256、输出 SHA-256 和确切 Unicode 子集记录于 `toolbox-font-source.json`，用 fontTools 4.66.1 的 Subsetter 加载所列码点，layout_features/name_IDs/name_languages 均为 `*`、notdef_outline=true，其余默认。输出 name ID 1/4/6 重命名为文件名（无扩展名）；Latin 额外保留 ASCII 基字母，让组合重音和逐字标记在同一测试字体内排版。清单的彝文、加拿大原住民音节、希腊／西里尔、部首与扩展 B 的 𠘨 均核对 cmap；U+FE0E 是无独立轮廓的文本变体选择符，不需要补可见字形。本轮只更新四张旧花体页面与四张工具目录 Golden，新增八张分类、两张 Zalgo 结果和四张时间顺序 Golden。
