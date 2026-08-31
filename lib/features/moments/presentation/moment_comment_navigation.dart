import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

class MomentCommentNavigationProjection {
  const MomentCommentNavigationProjection({
    required this.comments,
    required this.replyPages,
    required this.targetRootIndex,
    required this.targetId,
  });

  final List<MomentRootComment> comments;
  final Map<String, MomentReplyPageState> replyPages;
  final int targetRootIndex;
  final String? targetId;

  String get contentSignature {
    final targetRoot = targetRootIndex < 0 ? null : comments[targetRootIndex];
    final replies = targetRoot == null
        ? const <MomentComment>[]
        : (replyPages[targetRoot.id]?.items ?? targetRoot.replies);
    return '${targetId ?? ''}:$targetRootIndex:${comments.length}:'
        '${targetRoot?.id ?? ''}:${replies.map((item) => item.id).join(',')}';
  }
}

MomentCommentNavigationProjection projectMomentCommentNavigation({
  required List<MomentRootComment> comments,
  required Map<String, MomentReplyPageState> replyPages,
  required MomentCommentOrder order,
  MomentCommentContext? context,
}) {
  if (context == null) {
    return MomentCommentNavigationProjection(
      comments: comments,
      replyPages: replyPages,
      targetRootIndex: -1,
      targetId: null,
    );
  }

  final rootIndex = comments.indexWhere((item) => item.id == context.root.id);
  final existingRoot = rootIndex < 0 ? null : comments[rootIndex];
  final replies = _mergeComments(
    existingRoot?.replies ?? const [],
    context.targetsRoot ? const [] : [context.target],
  )..sort(_oldestFirst);
  final injectedRoot = context.root.copyWith(
    replyCount: context.root.replyCount,
    replies: List.unmodifiable(replies),
  );
  final mergedRoots =
      [
        for (final root in comments)
          if (root.id != injectedRoot.id) root,
        injectedRoot,
      ]..sort((left, right) {
        final comparison = left.createdAt.compareTo(right.createdAt);
        final ordered = order == MomentCommentOrder.oldest
            ? comparison
            : -comparison;
        return ordered == 0 ? left.id.compareTo(right.id) : ordered;
      });

  final mergedReplyPages = {...replyPages};
  final existingPage = mergedReplyPages[injectedRoot.id];
  if (!context.targetsRoot && existingPage != null) {
    final pageItems = _mergeComments(existingPage.items, [context.target])
      ..sort(_oldestFirst);
    mergedReplyPages[injectedRoot.id] = existingPage.copyWith(
      items: List.unmodifiable(pageItems),
    );
  }
  final immutableRoots = List<MomentRootComment>.unmodifiable(mergedRoots);
  return MomentCommentNavigationProjection(
    comments: immutableRoots,
    replyPages: Map.unmodifiable(mergedReplyPages),
    targetRootIndex: immutableRoots.indexWhere(
      (item) => item.id == injectedRoot.id,
    ),
    targetId: context.target.id,
  );
}

List<MomentComment> _mergeComments(
  Iterable<MomentComment> base,
  Iterable<MomentComment> authoritative,
) {
  final byId = <String, MomentComment>{for (final item in base) item.id: item};
  for (final item in authoritative) {
    byId[item.id] = item;
  }
  return byId.values.toList(growable: true);
}

int _oldestFirst(MomentComment left, MomentComment right) {
  final comparison = left.createdAt.compareTo(right.createdAt);
  return comparison == 0 ? left.id.compareTo(right.id) : comparison;
}

class MomentCommentTargetStatus extends StatelessWidget {
  const MomentCommentTargetStatus({
    required this.value,
    required this.onRetry,
    super.key,
  });

  final AsyncValue<MomentCommentContext> value;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (_) => const SizedBox.shrink(),
      loading: () => const WenyouStatusBanner(
        key: Key('moment-comment-target-loading'),
        message: '正在定位评论…',
      ),
      error: (error, _) {
        final failure = mapApplicationFailure(error, '目标评论定位失败，请稍后重试。');
        final unavailable = _targetUnavailable(failure);
        return WenyouStatusBanner(
          key: const Key('moment-comment-target-failure'),
          message: unavailable ? '目标评论已不可见' : failure.userMessage,
          detail: wenyouFailureDetail(failure),
          tone: WenyouStatusTone.error,
          action: unavailable
              ? null
              : TextButton(
                  key: const Key('moment-comment-target-retry'),
                  onPressed: onRetry,
                  child: const Text('重试定位'),
                ),
        );
      },
    );
  }
}

bool _targetUnavailable(ApiFailure failure) {
  return failure.httpStatus == 404 || failure.businessCode == 40415;
}

class MomentDetailFailure extends StatelessWidget {
  const MomentDetailFailure({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final notFound = _targetUnavailable(
      failure ?? const ApiFailure(userMessage: ''),
    );
    return WenyouContentFrame(
      top: 16,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: notFound
              ? WenyouIconIds.navigationMoments
              : WenyouIconIds.statusOffline,
          title: notFound ? '动态不存在' : '动态详情加载失败',
          message: notFound
              ? '这条动态可能已被删除或不可见。'
              : (failure?.userMessage ?? '请稍后重试。'),
          detail: wenyouFailureDetail(failure),
          action: notFound
              ? null
              : OutlinedButton.icon(
                  key: const Key('moment-detail-retry'),
                  onPressed: onRetry,
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                  label: const Text('重新加载'),
                ),
        ),
      ),
    );
  }
}
