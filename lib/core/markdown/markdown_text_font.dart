import 'package:markdown/markdown.dart' as md;

/// Backend 正文字体 v1 的固定 ID；显示名称与资源由字体目录提供。
abstract final class MarkdownTextFont {
  static const ids = {
    'source-han-sans',
    'zcoolkuaile',
    'zcoolxiaowei',
    'longcang',
    'liujianmaocao',
    'wenkai',
    'tiejili',
    'unbounded',
    'xiaolai',
    'zhuque',
    'fusion',
    'shinsyoku-mincho',
    'bouken-gothic',
    'hakkou-mincho',
    'shattered-display',
    'xiaocheng-lafeng',
    'jf-zsk-seal',
  };

  static bool hasUnknown(String source) {
    final masked = source.replaceAllMapped(
      md.CodeSyntax().pattern,
      (m) => ' ' * m[0]!.length,
    );
    for (final match in RegExp(
      r'<span (?:data-wenyou-color-v1="#[0-9a-fA-F]{6}" )?data-wenyou-font-v1="([a-z][a-z0-9-]*)"(?: data-wenyou-color-v1="#[0-9a-fA-F]{6}")?>[^\r\n]+?</span>',
    ).allMatches(masked)) {
      var slashes = 0;
      for (var i = match.start - 1; i >= 0 && masked[i] == r'\'; i--) {
        slashes++;
      }
      if (slashes.isEven && !ids.contains(match[1])) return true;
    }
    return false;
  }
}
