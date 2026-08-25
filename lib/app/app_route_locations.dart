abstract final class AppRouteLocations {
  static const home = AppRoutePaths.home;
  static const me = AppRoutePaths.me;
  static const meEdit = AppRoutePaths.meEdit;
  static const meSettings = AppRoutePaths.meSettings;
  static const meBookmarks = AppRoutePaths.meBookmarks;
  static const meBookmarkThreads = AppRoutePaths.meBookmarkThreads;
  static const moments = AppRoutePaths.moments;
  static const notifications = AppRoutePaths.notifications;
  static const search = AppRoutePaths.search;
  static const moderationAppeals = AppRoutePaths.moderationAppeals;
  static const composeThread = AppRoutePaths.composeThread;
  static const composeMoment = AppRoutePaths.composeMoment;

  static String login({String? returnTo}) =>
      _withQuery(AppRoutePaths.login, {'returnTo': ?returnTo});

  static String register({String? returnTo}) =>
      _withQuery(AppRoutePaths.register, {'returnTo': ?returnTo});

  static String thread(String threadId, {String? postId, String? subthreadId}) {
    if (postId != null && subthreadId != null) {
      throw ArgumentError('帖子坐标和子贴坐标不能同时存在。');
    }
    return _fromSegments(
      ['threads', threadId],
      {'post': ?postId, 'subthread': ?subthreadId},
    );
  }

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

  static String subthreadCreate(String threadId) =>
      '${subthreadManagement(threadId)}/new';

  static String subthreadEdit(String threadId, String subthreadId) =>
      '${subthreadManagement(threadId)}/${Uri.encodeComponent(subthreadId)}/edit';

  static String user(String userId) => _fromSegments(['users', userId]);

  static String moment(String momentId, {String? commentId}) =>
      _fromSegments(['moments', momentId], {'comment': ?commentId});

  static String meBookmarkFolder(String folderId, {String? name}) =>
      _fromSegments(['me', 'bookmarks', 'folders', folderId], {'name': ?name});

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

abstract final class AppRoutePaths {
  static const home = '/home';
  static const moments = '/moments';
  static const notifications = '/notifications';
  static const me = '/me';
  static const search = '/search';
  static const moderationAppeals = '/appeals';
  static const momentBookmarks = '/moments/bookmarks';
  static const momentEdit = '/moments/:momentId/edit';
  static const momentDetail = '/moments/:momentId';
  static const userMoments = '/users/:userId/moments';
  static const directMessages = '/messages';
  static const directMessageNew = '/messages/new/:userId';
  static const directConversation = '/messages/:conversationId';
  static const threadInvitation = '/join/:token';
  static const tagThreads = '/tags/:tagId';
  static const postReplies = '/threads/:threadId/posts/:postId/replies';
  static const threadMemberManagement = '/threads/:threadId/manage/members';
  static const threadTagManagement = '/threads/:threadId/manage/tags';
  static const subthreadManagement = '/threads/:threadId/manage/subthreads';
  static const subthreadCreate = '/threads/:threadId/manage/subthreads/new';
  static const subthreadEdit =
      '/threads/:threadId/manage/subthreads/:subthreadId/edit';
  static const threadManagement = '/threads/:threadId/manage';
  static const threadPostSearch = '/threads/:threadId/search';
  static const threadDetail = '/threads/:threadId';
  static const userProfile = '/users/:userId';
  static const userFollowing = '/users/:userId/following';
  static const userFollowers = '/users/:userId/followers';
  static const meEdit = '/me/edit';
  static const meSettings = '/me/settings';
  static const wallet = '/me/wallet';
  static const meFollowing = '/me/following';
  static const meFollowers = '/me/followers';
  static const meBlocks = '/me/blocks';
  static const meBookmarks = '/me/bookmarks';
  static const meBookmarkThreads = '/me/bookmarks/threads';
  static const meBookmarkFolder = '/me/bookmarks/folders/:folderId';
  static const meStickers = '/me/stickers';
  static const loginSessions = '/me/security/sessions';
  static const changePassword = '/me/security/password';
  static const changeEmail = '/me/security/email';
  static const deleteAccount = '/me/security/delete-account';
  static const composeMoment = '/compose/moment';
  static const composeThread = '/compose/thread';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
}

abstract final class AppRouteNames {
  static const home = 'home';
  static const moments = 'moments';
  static const notifications = 'notifications';
  static const me = 'me';
  static const search = 'search';
  static const moderationAppeals = 'moderation-appeals';
  static const momentBookmarks = 'moment-bookmarks';
  static const momentEdit = 'moment-edit';
  static const momentDetail = 'moment-detail';
  static const userMoments = 'user-moments';
  static const directMessages = 'direct-messages';
  static const directMessageNew = 'direct-message-new';
  static const directConversation = 'direct-conversation';
  static const threadInvitation = 'thread-invitation';
  static const tagThreads = 'tag-threads';
  static const postReplies = 'post-replies';
  static const threadMemberManagement = 'thread-member-management';
  static const threadTagManagement = 'thread-tag-management';
  static const subthreadManagement = 'subthread-management';
  static const subthreadCreate = 'subthread-create';
  static const subthreadEdit = 'subthread-edit';
  static const threadManagement = 'thread-management';
  static const threadPostSearch = 'thread-post-search';
  static const threadDetail = 'thread-detail';
  static const userProfile = 'user-profile';
  static const userFollowing = 'user-following';
  static const userFollowers = 'user-followers';
  static const meEdit = 'me-edit';
  static const meSettings = 'me-settings';
  static const wallet = 'wallet';
  static const meFollowing = 'me-following';
  static const meFollowers = 'me-followers';
  static const meBlocks = 'me-blocks';
  static const meBookmarks = 'me-bookmarks';
  static const meBookmarkThreads = 'me-bookmark-threads';
  static const meBookmarkFolder = 'me-bookmark-folder';
  static const meStickers = 'me-stickers';
  static const loginSessions = 'login-sessions';
  static const changePassword = 'change-password';
  static const changeEmail = 'change-email';
  static const deleteAccount = 'delete-account';
  static const composeMoment = 'compose-moment';
  static const composeThread = 'compose-thread';
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgot-password';
  static const resetPassword = 'reset-password';
}
