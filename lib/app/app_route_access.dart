import 'package:wenyousite_mobile/app/app_route_locations.dart';

enum AppRouteAccess { public, authenticated, guestOnly }

abstract final class AppRouteAccessPolicy {
  static AppRouteAccess forLocation(String location) {
    if (_guestOnlyLocations.contains(location)) {
      return AppRouteAccess.guestOnly;
    }
    if (_authenticatedLocations.contains(location) ||
        _threadManagementPattern.hasMatch(location) ||
        _momentEditPattern.hasMatch(location) ||
        _bookmarkFolderPattern.hasMatch(location) ||
        _directMessagePattern.hasMatch(location) ||
        _invitationPattern.hasMatch(location)) {
      return AppRouteAccess.authenticated;
    }
    return AppRouteAccess.public;
  }

  static const _guestOnlyLocations = <String>{
    AppRoutePaths.login,
    AppRoutePaths.register,
    AppRoutePaths.forgotPassword,
    AppRoutePaths.resetPassword,
  };

  static const _authenticatedLocations = <String>{
    AppRoutePaths.composeThread,
    AppRoutePaths.composeMoment,
    AppRoutePaths.momentBookmarks,
    AppRoutePaths.meEdit,
    AppRoutePaths.meSettings,
    AppRoutePaths.meFollowing,
    AppRoutePaths.wallet,
    AppRoutePaths.meFollowers,
    AppRoutePaths.meBlocks,
    AppRoutePaths.meBookmarks,
    AppRoutePaths.meBookmarkThreads,
    AppRoutePaths.meStickers,
    AppRoutePaths.loginSessions,
    AppRoutePaths.changePassword,
    AppRoutePaths.changeEmail,
    AppRoutePaths.deleteAccount,
  };

  static final _momentEditPattern = RegExp(
    r'^/moments/(?:[^/]+|:momentId)/edit$',
  );
  static final _bookmarkFolderPattern = RegExp(
    r'^/me/bookmarks/folders/(?:[^/]+|:folderId)$',
  );
  static final _threadManagementPattern = RegExp(
    r'^/threads/(?:[^/]+|:threadId)/manage(?:/(?:members|tags)|/subthreads(?:/new|/(?:[^/]+|:subthreadId)/edit)?)?$',
  );
  static final _invitationPattern = RegExp(r'^/join/(?:[^/]+|:token)$');
  static final _directMessagePattern = RegExp(
    r'^/messages(?:/(?:[^/]+|:conversationId)|/new/(?:[^/]+|:userId))?$',
  );
}
