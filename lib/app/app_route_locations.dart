abstract final class AppRouteLocations {
  static const home = '/home';
  static const me = '/me';
  static const meEdit = '/me/edit';
  static const meSettings = '/me/settings';
  static const moments = '/moments';
  static const notifications = '/notifications';
  static const search = '/search';
  static const moderationAppeals = '/appeals';
  static const composeThread = '/compose/thread';
  static const composeMoment = '/compose/moment';

  static String login({String? returnTo}) =>
      _withQuery('/auth/login', {'returnTo': ?returnTo});

  static String register({String? returnTo}) =>
      _withQuery('/auth/register', {'returnTo': ?returnTo});

  static String verifyEmail({String? returnTo}) =>
      _withQuery('/me/security/verify-email', {'returnTo': ?returnTo});

  static String thread(String threadId, {String? postId}) =>
      _fromSegments(['threads', threadId], {'post': ?postId});

  static String messageCenter({String? section}) =>
      _withQuery(notifications, {'section': ?section});

  static String postReplies(
    String threadId,
    String parentPostId, {
    String? postId,
  }) => _fromSegments(
    ['threads', threadId, 'posts', parentPostId, 'replies'],
    {'post': ?postId},
  );

  static String threadManagement(String threadId) =>
      '${thread(threadId)}/manage';

  static String threadMemberManagement(String threadId) =>
      '${threadManagement(threadId)}/members';

  static String threadTagManagement(String threadId) =>
      '${threadManagement(threadId)}/tags';

  static String subthreadManagement(String threadId) =>
      '${threadManagement(threadId)}/subthreads';

  static String user(String userId) => _fromSegments(['users', userId]);

  static String moment(String momentId) => _fromSegments(['moments', momentId]);

  static String _fromSegments(
    List<String> segments, [
    Map<String, String> query = const {},
  ]) {
    return Uri(
      pathSegments: ['', ...segments],
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }

  static String _withQuery(String path, Map<String, String> query) {
    return Uri(
      path: path,
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }
}
