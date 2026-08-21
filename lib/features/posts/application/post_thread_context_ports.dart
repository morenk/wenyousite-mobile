import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';

class PostThreadContext {
  const PostThreadContext({
    required this.isPrivate,
    required this.canManageThread,
  });

  final bool isPrivate;
  final bool canManageThread;

  bool get canReport => !isPrivate;
}

typedef PostThreadContextLookup =
    Future<PostThreadContext> Function(String threadId);

final postThreadContextLookupProvider = Provider<PostThreadContextLookup>((
  ref,
) {
  return (threadId) =>
      Future<PostThreadContext>.error(StateError('主题权限上下文尚未在应用组合根绑定。'));
});

final postThreadContextProvider = FutureProvider.autoDispose
    .family<PostThreadContext, String>((ref, threadId) {
      ref.watch(sessionScopeProvider);
      return ref.watch(postThreadContextLookupProvider)(threadId);
    }, dependencies: [postThreadContextLookupProvider, sessionScopeProvider]);
