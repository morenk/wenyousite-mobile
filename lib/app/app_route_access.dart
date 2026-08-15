enum AppRouteAccess { public, authenticated, guestOnly }

abstract final class AppRouteAccessPolicy {
  static AppRouteAccess forLocation(String location) {
    if (_guestOnlyLocations.contains(location)) {
      return AppRouteAccess.guestOnly;
    }
    if (_authenticatedLocations.contains(location) ||
        _threadManagementPattern.hasMatch(location) ||
        _momentEditPattern.hasMatch(location) ||
        _directMessagePattern.hasMatch(location) ||
        _invitationPattern.hasMatch(location)) {
      return AppRouteAccess.authenticated;
    }
    return AppRouteAccess.public;
  }

  static const _guestOnlyLocations = <String>{
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
  };

  static const _authenticatedLocations = <String>{
    '/compose/thread',
    '/compose/moment',
    '/moments/bookmarks',
    '/me/edit',
    '/me/settings',
    '/me/following',
    '/me/wallet',
    '/me/followers',
    '/me/blocks',
    '/me/bookmarks',
    '/me/stickers',
    '/me/security/sessions',
    '/me/security/password',
    '/me/security/email',
    '/me/security/delete-account',
  };

  static final _momentEditPattern = RegExp(
    r'^/moments/(?:[^/]+|:momentId)/edit$',
  );
  static final _threadManagementPattern = RegExp(
    r'^/threads/(?:[^/]+|:threadId)/manage(?:/(?:members|subthreads|tags))?$',
  );
  static final _invitationPattern = RegExp(r'^/join/(?:[^/]+|:token)$');
  static final _directMessagePattern = RegExp(
    r'^/messages(?:/(?:[^/]+|:conversationId)|/new/(?:[^/]+|:userId))?$',
  );
}
