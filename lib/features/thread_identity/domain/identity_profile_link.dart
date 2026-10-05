import 'package:wenyousite_mobile/core/domain/domain_validation_exception.dart';

/// 只解析站内已存在的楼层定位链接；正文始终由受授权的帖子接口读取。
String parseIdentityProfilePostLink(String input, {required String threadId}) {
  final uri = Uri.tryParse(input.trim());
  const invalid = DomainValidationException('请输入有效的楼层链接');
  if (uri == null || uri.userInfo.isNotEmpty || uri.hasFragment) throw invalid;
  if (uri.hasScheme || uri.hasAuthority) {
    if (uri.scheme != 'https' ||
        !const {'wenyou.site', 'www.wenyou.site'}.contains(uri.host) ||
        (uri.hasPort && uri.port != 443)) {
      throw invalid;
    }
  }
  final path = uri.pathSegments;
  final floor = path.length == 2 && path.first == 'threads';
  final reply =
      path.length == 5 &&
      path.first == 'threads' &&
      path[2] == 'posts' &&
      path[4] == 'replies';
  if ((!floor && !reply) || !uri.path.startsWith('/')) throw invalid;
  if (path[1] != threadId) {
    throw const DomainValidationException('请选择本主题内的楼层');
  }
  final values = uri.queryParametersAll;
  if (values.keys.any(
        (key) => !const {'post', 'order', 'subthread'}.contains(key),
      ) ||
      values.values.any((values) => values.length != 1) ||
      values['post']?.length != 1 ||
      (values.containsKey('order') &&
          !const {'OLDEST', 'NEWEST'}.contains(values['order']!.single))) {
    throw invalid;
  }
  final postId = values['post']!.single;
  if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(postId)) throw invalid;
  return postId;
}

String identityProfilePostLink(String threadId, String postId) =>
    Uri.https('wenyou.site', '/threads/$threadId', {'post': postId}).toString();

class IdentityProfilePostTarget {
  const IdentityProfilePostTarget({required this.id, required this.threadId});
  final String id;
  final String threadId;
}
