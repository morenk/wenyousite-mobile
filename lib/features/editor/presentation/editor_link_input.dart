import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';

typedef EditorLinkInput = ({String? url, String? error, bool extracted});

final _sharedWebUrl = RegExp(
  r'(?:^|\s)((?:https?://|mailto:)[^\s]+)',
  caseSensitive: false,
);
final _unsupportedLinkCharacters = RegExp(r'[\s()<>\x00-\x1f\x7f]');

/// 分享口令只在链接输入面板解析，不改变正文粘贴或已有文档的目标。
/// 提取结果由面板预览；含多个地址时不替用户选择。
EditorLinkInput resolveEditorLinkInput(String input) {
  final value = input.trim();
  var candidate = value;
  var extracted = false;
  if (RegExp(r'\s').hasMatch(value)) {
    final matches = _sharedWebUrl.allMatches(value).toList();
    if (matches.length != 1 ||
        !matches.single.group(1)!.toLowerCase().startsWith('http')) {
      return (url: null, error: '请只填写一个完整的链接地址', extracted: false);
    }
    candidate = matches.single.group(1)!;
    extracted = true;
  }
  final uri = Uri.tryParse(candidate);
  if (uri == null || !uri.hasScheme || !MarkdownContent.isSafeLink(uri)) {
    return (url: null, error: '仅支持 HTTP(S) 或 mailto 链接', extracted: false);
  }
  if (_unsupportedLinkCharacters.hasMatch(candidate) ||
      ((uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isEmpty) ||
      (uri.scheme == 'mailto' && uri.path.isEmpty)) {
    return (url: null, error: '链接地址不完整或包含无效字符，请检查后重试', extracted: false);
  }
  return (url: candidate, error: null, extracted: extracted);
}
