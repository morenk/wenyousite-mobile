import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';

class PostThreadContext {
  const PostThreadContext({
    required this.isPrivate,
    required this.canManageThread,
    this.supportsRpIdentity = false,
    this.ownerId,
  });

  final bool isPrivate;
  final bool canManageThread;
  final bool supportsRpIdentity;
  final String? ownerId;

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
      ref.watch(viewerScopeProvider);
      return ref.watch(postThreadContextLookupProvider)(threadId);
    }, dependencies: [postThreadContextLookupProvider, viewerScopeProvider]);
