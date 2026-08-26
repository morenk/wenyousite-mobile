import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_route_access.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';

void main() {
  test('路由访问级别同时覆盖声明模板和实际位置', () {
    expect(
      AppRouteAccessPolicy.forLocation('/auth/login'),
      AppRouteAccess.guestOnly,
    );
    for (final location in const [
      '/messages',
      '/messages/:conversationId',
      '/messages/new/user-1',
      '/threads/:threadId/manage/tags',
      '/threads/thread-1/manage/subthreads',
      '/threads/thread-1/manage/subthreads/new',
      '/threads/thread-1/manage/subthreads/sub-1/edit',
      '/moments/moment-1/edit',
      '/join/invite-token',
      '/me/bookmarks/threads',
      '/me/bookmarks/moments',
      '/me/bookmarks/threads/folders/:folderId',
      '/me/bookmarks/moments/folders/folder-1',
      '/me/bookmarks/folders/:folderId',
      '/me/bookmarks/folders/folder-1',
    ]) {
      expect(
        AppRouteAccessPolicy.forLocation(location),
        AppRouteAccess.authenticated,
        reason: location,
      );
    }
    expect(
      AppRouteAccessPolicy.forLocation('/threads/thread-1'),
      AppRouteAccess.public,
    );
    expect(
      AppRouteAccessPolicy.forLocation(AppRouteLocations.moderationAppeals),
      AppRouteAccess.public,
    );
  });

  test('位置构造器编码路径段和 returnTo 查询参数', () {
    expect(
      AppRouteLocations.thread('thread/with slash', postId: 'post&1'),
      '/threads/thread%2Fwith%20slash?post=post%261',
    );
    expect(
      AppRouteLocations.login(
        returnTo: AppRouteLocations.thread('thread-1', postId: 'post-1'),
      ),
      '/auth/login?returnTo=%2Fthreads%2Fthread-1%3Fpost%3Dpost-1',
    );
    expect(
      AppRouteLocations.thread('thread-1', subthreadId: 'subthread&1'),
      '/threads/thread-1?subthread=subthread%261',
    );
    expect(
      () => AppRouteLocations.thread(
        'thread-1',
        postId: 'post-1',
        subthreadId: 'subthread-1',
      ),
      throwsArgumentError,
    );
    expect(
      AppRouteLocations.messageCenter(section: 'directMessages'),
      '/notifications?section=directMessages',
    );
    expect(
      AppRouteLocations.postReplies('thread/1', 'floor/2', postId: 'reply&9'),
      '/threads/thread%2F1/posts/floor%2F2/replies?post=reply%269',
    );
    expect(
      AppRouteLocations.subthreadEdit('thread/1', 'sub/2'),
      '/threads/thread%2F1/manage/subthreads/sub%2F2/edit',
    );
    expect(
      AppRouteLocations.meThreadBookmarkFolder('folder/1', name: '跑团 资料'),
      '/me/bookmarks/threads/folders/folder%2F1?name=%E8%B7%91%E5%9B%A2+%E8%B5%84%E6%96%99',
    );
    expect(
      AppRouteLocations.meMomentBookmarkFolder('folder/1', name: '稍后 阅读'),
      '/me/bookmarks/moments/folders/folder%2F1?name=%E7%A8%8D%E5%90%8E+%E9%98%85%E8%AF%BB',
    );
  });
}
