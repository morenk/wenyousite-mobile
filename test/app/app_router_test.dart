import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';

void main() {
  test('失效会话仍可进入找回与重置密码公开路由', () {
    const session = SessionState.invalidated(
      SessionInvalidationReason.refreshFailed,
    );

    expect(
      resolveSessionRedirect(
        session: session,
        matchedLocation: '/auth/forgot-password',
        uri: Uri.parse('/auth/forgot-password?returnTo=%2Fcompose%2Fthread'),
      ),
      isNull,
    );
    expect(
      resolveSessionRedirect(
        session: session,
        matchedLocation: '/auth/reset-password',
        uri: Uri.parse('/auth/reset-password?returnTo=%2Fcompose%2Fthread'),
      ),
      isNull,
    );
  });

  test('失效会话访问业务页会带完整目标回到登录', () {
    final redirect = resolveSessionRedirect(
      session: const SessionState.invalidated(
        SessionInvalidationReason.revoked,
      ),
      matchedLocation: '/threads/thread-id',
      uri: Uri.parse('/threads/thread-id?post=post-id'),
    );

    expect(
      Uri.parse(redirect!).queryParameters['returnTo'],
      '/threads/thread-id?post=post-id',
    );
  });

  test('已登录用户访问游客认证页恢复安全目标', () {
    final redirect = resolveSessionRedirect(
      session: const SessionState.authenticated(),
      matchedLocation: '/auth/reset-password',
      uri: Uri.parse('/auth/reset-password?returnTo=%2Fcompose%2Fthread'),
    );

    expect(redirect, '/compose/thread');
  });

  test('游客访问私有页面进入登录并拒绝认证页回跳循环', () {
    final redirect = resolveSessionRedirect(
      session: const SessionState.guest(),
      matchedLocation: '/me/security/password',
      uri: Uri.parse('/me/security/password'),
    );
    expect(
      Uri.parse(redirect!).queryParameters['returnTo'],
      '/me/security/password',
    );

    expect(
      resolveSessionRedirect(
        session: const SessionState.authenticated(),
        matchedLocation: '/auth/login',
        uri: Uri.parse('/auth/login?returnTo=%2Fauth%2Fforgot-password'),
      ),
      '/home',
    );
  });

  test('私聊中心、会话与新会话路由均受登录保护', () {
    for (final location in [
      '/messages',
      '/messages/conversation-1',
      '/messages/new/user-2',
    ]) {
      final redirect = resolveSessionRedirect(
        session: const SessionState.guest(),
        matchedLocation: location,
        uri: Uri.parse(location),
      );
      expect(Uri.parse(redirect!).queryParameters['returnTo'], location);
      expect(
        resolveSessionRedirect(
          session: const SessionState.authenticated(),
          matchedLocation: location,
          uri: Uri.parse(location),
        ),
        isNull,
      );
    }
  });

  test('账号注销页受会话保护且已登录时保持可达', () {
    final redirect = resolveSessionRedirect(
      session: const SessionState.guest(),
      matchedLocation: '/me/security/delete-account',
      uri: Uri.parse('/me/security/delete-account'),
    );
    expect(
      Uri.parse(redirect!).queryParameters['returnTo'],
      '/me/security/delete-account',
    );
    expect(
      resolveSessionRedirect(
        session: const SessionState.authenticated(),
        matchedLocation: '/me/security/delete-account',
        uri: Uri.parse('/me/security/delete-account'),
      ),
      isNull,
    );
  });

  test('温油钱包受会话保护并完整保留目标', () {
    final redirect = resolveSessionRedirect(
      session: const SessionState.guest(),
      matchedLocation: '/me/wallet',
      uri: Uri.parse('/me/wallet'),
    );
    expect(Uri.parse(redirect!).queryParameters['returnTo'], '/me/wallet');
    expect(
      resolveSessionRedirect(
        session: const SessionState.authenticated(),
        matchedLocation: '/me/wallet',
        uri: Uri.parse('/me/wallet'),
      ),
      isNull,
    );
  });

  test('主题管理页受会话保护并保留动态主题目标', () {
    final redirect = resolveSessionRedirect(
      session: const SessionState.guest(),
      matchedLocation: '/threads/thread-1/manage',
      uri: Uri.parse('/threads/thread-1/manage'),
    );
    expect(
      Uri.parse(redirect!).queryParameters['returnTo'],
      '/threads/thread-1/manage',
    );
    expect(
      resolveSessionRedirect(
        session: const SessionState.authenticated(),
        matchedLocation: '/threads/thread-1/manage',
        uri: Uri.parse('/threads/thread-1/manage'),
      ),
      isNull,
    );

    final membersRedirect = resolveSessionRedirect(
      session: const SessionState.guest(),
      matchedLocation: '/threads/thread-1/manage/members',
      uri: Uri.parse('/threads/thread-1/manage/members'),
    );
    expect(
      Uri.parse(membersRedirect!).queryParameters['returnTo'],
      '/threads/thread-1/manage/members',
    );

    final subthreadsRedirect = resolveSessionRedirect(
      session: const SessionState.guest(),
      matchedLocation: '/threads/thread-1/manage/subthreads',
      uri: Uri.parse('/threads/thread-1/manage/subthreads'),
    );
    expect(
      Uri.parse(subthreadsRedirect!).queryParameters['returnTo'],
      '/threads/thread-1/manage/subthreads',
    );

    final tagsRedirect = resolveSessionRedirect(
      session: const SessionState.guest(),
      matchedLocation: '/threads/thread-1/manage/tags',
      uri: Uri.parse('/threads/thread-1/manage/tags'),
    );
    expect(
      Uri.parse(tagsRedirect!).queryParameters['returnTo'],
      '/threads/thread-1/manage/tags',
    );
  });

  test('公开标签主题页不要求登录', () {
    expect(
      resolveSessionRedirect(
        session: const SessionState.guest(),
        matchedLocation: '/tags/tag-1',
        uri: Uri.parse('/tags/tag-1'),
      ),
      isNull,
    );
  });

  test('公开主题内搜索保留游客可达性', () {
    expect(
      resolveSessionRedirect(
        session: const SessionState.guest(),
        matchedLocation: '/threads/thread-1/search',
        uri: Uri.parse('/threads/thread-1/search'),
      ),
      isNull,
    );
  });

  test('动态详情与用户动态公开，发布编辑与收藏受登录保护', () {
    for (final location in ['/moments/moment-1', '/users/user-1/moments']) {
      expect(
        resolveSessionRedirect(
          session: const SessionState.guest(),
          matchedLocation: location,
          uri: Uri.parse(location),
        ),
        isNull,
      );
    }
    for (final location in [
      '/compose/moment',
      '/moments/moment-1/edit',
      '/moments/bookmarks',
    ]) {
      final redirect = resolveSessionRedirect(
        session: const SessionState.guest(),
        matchedLocation: location,
        uri: Uri.parse(location),
      );
      expect(Uri.parse(redirect!).queryParameters['returnTo'], location);
      expect(
        resolveSessionRedirect(
          session: const SessionState.authenticated(),
          matchedLocation: location,
          uri: Uri.parse(location),
        ),
        isNull,
      );
    }
  });

  test('私密邀请预览要求登录并完整保留不透明 token', () {
    const location = '/join/Abcd_1234-efGh56';
    final redirect = resolveSessionRedirect(
      session: const SessionState.guest(),
      matchedLocation: location,
      uri: Uri.parse(location),
    );

    expect(Uri.parse(redirect!).queryParameters['returnTo'], location);
    expect(
      resolveSessionRedirect(
        session: const SessionState.authenticated(),
        matchedLocation: location,
        uri: Uri.parse(location),
      ),
      isNull,
    );
  });
}
