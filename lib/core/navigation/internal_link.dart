import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';

/// Returns whether [uri] points to a route owned by Wenyou.
///
/// Markdown links may be stored either as relative app paths or as links
/// copied from the Web client. Only the known Wenyou origins are treated as
/// internal; every other HTTP(S) URL remains an external link.
bool isInternalWenyouUri(Uri uri) {
  if (!uri.hasScheme && uri.host.isEmpty) {
    return uri.path.startsWith('/');
  }
  if (uri.scheme != 'http' && uri.scheme != 'https') return false;
  return switch (uri.host.toLowerCase()) {
    'wenyou.site' || 'www.wenyou.site' || 'localhost' || '10.0.2.2' => true,
    _ => false,
  };
}

/// Converts an absolute Web link to the path understood by the mobile router.
Uri? internalWenyouLocation(Uri uri) {
  if (!isInternalWenyouUri(uri)) return null;
  final path = uri.path.isEmpty ? '/' : uri.path;
  if (!path.startsWith('/')) return null;
  return Uri(
    path: path,
    queryParameters: uri.queryParameters.isEmpty ? null : uri.queryParameters,
    fragment: uri.fragment.isEmpty ? null : uri.fragment,
  );
}

/// Opens a supported internal route without leaving the app.
///
/// The router remains the authority for authentication and route access. A
/// missing/unsupported path is kept in-app and explained instead of silently
/// handing a Wenyou URL to the browser.
void openInternalWenyouLink(BuildContext context, Uri uri) {
  final location = internalWenyouLocation(uri);
  if (location == null || !_isSupportedWenyouPath(location.path)) {
    showWenyouSnackBar(
      context,
      '这个站内目标暂时无法打开。',
      pacing: WenyouSnackBarPacing.extended,
    );
    return;
  }
  context.push(location.toString());
}

bool _isSupportedWenyouPath(String path) {
  if (path == '/') return true;
  const exactPaths = {
    '/home',
    '/moments',
    '/search',
    '/notifications',
    '/me',
    '/me/edit',
    '/me/settings',
    '/me/wallet',
    '/compose/moment',
    '/compose/thread',
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
  };
  if (exactPaths.contains(path)) return true;
  const prefixes = [
    '/moments/',
    '/users/',
    '/threads/',
    '/messages/',
    '/join/',
    '/tags/',
    '/me/',
  ];
  return prefixes.any(path.startsWith);
}
