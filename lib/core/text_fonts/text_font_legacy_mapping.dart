import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';

/// 固定历史版本来自 contracts/thread-font-v1-import-map.json；不限制新增动态版本。
const legacyTextFontVersions = <String, String>{
  'source-han-sans': 'tfv_854b8c85ea98ee9946ddb0242c01df3e',
  'zcoolkuaile': 'tfv_474f09cbe75263ede78fdaaee67c414a',
  'longcang': 'tfv_f89af08dba955b3d736984c8de95961b',
  'liujianmaocao': 'tfv_b434e71260aa4d5fd22ffc5db672e70e',
  'wenkai': 'tfv_7682a10d9b7c3cf6691c3ac5c0b34fbf',
  'tiejili': 'tfv_4b8360744df5acfdb318c30e74203c34',
  'unbounded': 'tfv_932ba6d9407eac1c6ff054a8210e38dc',
  'xiaolai': 'tfv_5bb5ac598cd26a55df285a1b4ba49f36',
  'zhuque': 'tfv_186e28fdce28c4cfd56fa5b6c25b7e38',
  'fusion': 'tfv_b7417737776609fe701c12467974aa64',
  'shinsyoku-mincho': 'tfv_f7e72b58ef3b478e4233ae08b229b4e9',
  'bouken-gothic': 'tfv_7d398cca95b92b4543766a05e6b75285',
  'hakkou-mincho': 'tfv_c85e8ab291c645b5d470f33e5b0d7e25',
  'shattered-display': 'tfv_e05d3ba26b0b3dd4876a24181e133b76',
  'jf-zsk-seal': 'tfv_7088a82a609c270f6d3681373c8850c9',
  'kaitou-yokoku-gothic': 'tfv_8a7a562725ce6a614ff9be6baac9b66e',
  'yuji-boku': 'tfv_0ffc028a1c99ca10e5cf79bf21f79195',
  'dotgothic16': 'tfv_f2e383bff617dd71af53388c8e040a61',
  'hachi-maru-pop': 'tfv_8c6ee724b60a837748e690273a1e447b',
  'reggae-one': 'tfv_af5e8ee8919af0f3eb570468847b92bc',
  'train-one': 'tfv_7e347dc5aa54273b720d365d1bf35b20',
  'rampart-one': 'tfv_94c9589b87a703cf478f7d21fa37e185',
  'unifraktur-cook': 'tfv_4ce6de8735b7de93e27e5be11bf5c0f4',
  'great-vibes': 'tfv_72451c7e8503cb513f4d13bbb9ddd04d',
  'special-elite': 'tfv_7893d23d55c1d2698455674585942e9c',
  'monoton': 'tfv_cb76222f87323214556ce7904947726f',
  'orbitron': 'tfv_50f3e665ad3e4586439e435ac261266e',
  'rye': 'tfv_937f8f7b1344bc1af110c37b103d1453',
};

String? dynamicTextFontVersion(String id) =>
    MarkdownTextFont.isVersionId(id) ? id : legacyTextFontVersions[id];
