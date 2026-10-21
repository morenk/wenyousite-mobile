/// 仅保存在当前 Delta 的链接来源边界，不写入 Markdown 或 title。
const markdownLinkIdentityKey = 'wenyou_link_identity';
int _nextIdentity = 0;
String newMarkdownLinkIdentity() => '${++_nextIdentity}';
