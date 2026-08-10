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
}
