/// 结构化提及的原始目标。显示昵称变化不改写链接或原始标签。
class MarkdownMentionTarget {
  const MarkdownMentionTarget._(this.userId, this.sourceHref, this.identityId);

  final String userId;
  final String sourceHref;
  final String? identityId;
  bool get isLegacy => !sourceHref.contains('?');
  bool get isAccount => !isLegacy && identityId == null;

  static const nodePattern =
      r'\[(@[^\]\r\n]+)\]\((/users/[a-zA-Z0-9_-]+(?:\?[^)\s]*)?)\)';
  static final nodeAtStart = RegExp('^$nodePattern');
  static final _href = RegExp(
    r'^/users/([a-zA-Z0-9_-]+)(?:\?(?:rpIdentityId=(c[a-z0-9]{24})|identityMode=ACCOUNT))?$',
  );

  static MarkdownMentionTarget? parse(String sourceHref) {
    final match = _href.firstMatch(sourceHref);
    if (match == null) return null;
    return MarkdownMentionTarget._(match[1]!, sourceHref, match[2]);
  }

  static MarkdownMentionTarget? fromPayload(Map payload) {
    final userId = payload['userId'];
    final sourceHref = payload['sourceHref'];
    if (userId is! String || sourceHref != null && sourceHref is! String) {
      return null;
    }
    final value = parse(sourceHref as String? ?? '/users/$userId');
    return value?.userId == userId ? value : null;
  }

  bool acceptsLabel(String label) =>
      label.startsWith('@') &&
      label.length > 1 &&
      (isLegacy ? label.length <= 49 : label.runes.length <= 33) &&
      !RegExp(r'[\]\r\n]').hasMatch(label);

  /// 旧投影保持兼容；新目标包含完整链接，区分同账号同名角色及账号。
  String projectionKey(String label) =>
      '${isLegacy ? userId : sourceHref}\u0000$label';

  Map<String, Object> toPayload(String label) => {
    'version': 1,
    'kind': 'user',
    'userId': userId,
    'label': label,
    if (!isLegacy) 'sourceHref': sourceHref,
  };

  static String? projectedLabel(Map payload, Map<String, String> labels) {
    final target = fromPayload(payload);
    final label = payload['label'];
    if (target == null || label is! String || !label.startsWith('@')) {
      return null;
    }
    return labels[target.projectionKey(label.substring(1))];
  }
}
