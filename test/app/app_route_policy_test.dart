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
      '/moments/moment-1/edit',
      '/join/invite-token',
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
  });
}
