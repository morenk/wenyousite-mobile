import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/reading_gallery.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_reading_body.dart';

typedef _ProfileRequest = ({String threadId, String postId, Object opening});
final _profilePostProvider = FutureProvider.autoDispose
    .family<PostItem?, _ProfileRequest>((ref, request) async {
      ref.watch(viewerScopeProvider);
      try {
        final post = await ref
            .watch(postRepositoryProvider)
            .fetchPost(request.postId);
        if (post.id != request.postId ||
            post.threadId != request.threadId ||
            post.isDeleted) {
          return null;
        }
        return post;
      } on ApiFailure catch (error) {
        if (const {401, 403, 404, 410}.contains(error.httpStatus) ||
            const {
              FailureReason.notFound,
              FailureReason.permissionDenied,
              FailureReason.unauthenticated,
              FailureReason.sessionInvalid,
            }.contains(error.reason)) {
          return null;
        }
        rethrow;
      }
    }, dependencies: [viewerScopeProvider, postRepositoryProvider]);

/// 每次打开使用独立请求标识，切号与可见性变化立即移除旧正文。
class PostIdentityProfilePreview extends ConsumerStatefulWidget {
  const PostIdentityProfilePreview({
    required this.threadId,
    required this.postId,
    required this.onOpenPost,
    super.key,
  });
  final String threadId;
  final String postId;
  final ValueChanged<String> onOpenPost;
  @override
  ConsumerState<PostIdentityProfilePreview> createState() =>
      _PostIdentityProfilePreviewState();
}

class _PostIdentityProfilePreviewState
    extends ConsumerState<PostIdentityProfilePreview> {
  final _opening = Object();

  @override
  Widget build(BuildContext context) {
    final provider = _profilePostProvider((
      threadId: widget.threadId,
      postId: widget.postId,
      opening: _opening,
    ));
    return ref
        .watch(provider)
        .when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          loading: () => const Padding(
            key: Key('identity-profile-loading'),
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          ),
          error: (_, _) => Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => ref.invalidate(provider),
              child: const Text('加载失败，重试'),
            ),
          ),
          data: (post) =>
              post == null ? const Text('资料暂不可用') : _body(context, post),
        );
  }

  Widget _body(BuildContext context, PostItem post) {
    final parent = post.parentPostId;
    final location = parent == null
        ? AppRouteLocations.thread(post.threadId, postId: post.id)
        : AppRouteLocations.postReplies(post.threadId, parent, postId: post.id);
    final number = post.isBody
        ? '正文'
        : parent == null
        ? '#${post.floorNumber ?? '—'}'
        : '#${post.parentFloorNumber ?? '—'} · 回复 ${post.replyNumber ?? '—'}';
    return Column(
      key: const Key('identity-profile-body'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        PostReadingBody(
          post: post,
          galleryTarget: ReadingGalleryTarget(
            scope: parent == null
                ? ReadingGalleryScope.subthread
                : ReadingGalleryScope.postReplies,
            scopeId: parent ?? post.subthreadId,
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            key: const Key('identity-profile-source'),
            onPressed: () => widget.onOpenPost(location),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    '${post.subthreadTitle ?? '子贴'} · $number',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.wenyouCaption,
                  ),
                ),
                SizedBox(width: context.wenyouTokens.space4),
                const WenyouIcon(WenyouIconIds.navigationNext, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
