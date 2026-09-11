import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_item_divider.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_overview.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_render_diagnostics.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_sections.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_floor_filters.dart';

List<Widget> buildThreadDetailReadingSlivers(
  BuildContext context,
  ThreadDetailState state,
  AutoDisposeStateNotifierProvider<ThreadDetailController, ThreadDetailState>
  provider,
  AsyncValue<ThreadPostTargetModel>? targetState, {
  required WidgetRef ref,
  required String threadId,
  required ThreadDetailSubthreadScrollCoordinator subthreadScroll,
  required ThreadDetailRenderGeometryProbe renderGeometry,
  required ReadingQuickScrollController quickScroll,
  required GlobalKey targetKey,
  required VoidCallback onRetryTarget,
  required Future<void> Function(String) onSelectSubthread,
  required ValueChanged<PostComposerTarget> onCompose,
  required ValueChanged<ThreadFloorModel> onDeleteFloor,
  required ValueChanged<ThreadFloorModel> onToggleFloorPin,
  required void Function(ThreadFloorModel, {String? focusedReplyId})
  onDiscussion,
  required VoidCallback onRequireLogin,
  required PostActionState actions,
  required AsyncValue<List<PostDiscussionAuthor>> discussionAuthors,
  required bool authenticated,
  required String? viewerId,
}) {
  final detail = state.detail!;
  final selected = state.selectedSubthread;
  final target = resolvedThreadPostTarget(targetState);
  final usableTarget =
      target != null &&
          target.threadId == threadId &&
          target.subthreadId == state.selectedSubthreadId &&
          (state.floorAuthorId == null ||
              target.floor.author.id == state.floorAuthorId)
      ? target
      : null;
  final displayedFloors = threadFloorsWithTarget(
    state.floors,
    usableTarget,
    state.floorOrder,
  );
  return [
    SliverToBoxAdapter(
      child: WenyouContentFrame(
        top: 8,
        child: KeyedSubtree(
          key: renderGeometry.overviewKey,
          child: ThreadDetailOverview(
            detail: detail,
            onTagPressed: (tag) => context.pushNamed(
              AppRouteNames.tagThreads,
              pathParameters: {'tagId': tag.id},
            ),
          ),
        ),
      ),
    ),
    ThreadDetailSubthreadHeaderSliver(
      subthreads: detail.subthreads,
      selectedSubthreadId: state.selectedSubthreadId,
      scrollCoordinator: subthreadScroll,
      onSelected: onSelectSubthread,
    ),
    if (state.transientFailure != null &&
        state.retryAction == ThreadDetailRetryAction.refresh)
      SliverToBoxAdapter(
        child: WenyouContentFrame(
          top: 12,
          child: ThreadDetailTransientFailure(
            failure: state.transientFailure!,
            onRetry: () => ref.read(provider.notifier).refresh(),
          ),
        ),
      ),
    if (detail.subthreads.isEmpty)
      SliverFillRemaining(
        hasScrollBody: false,
        child: WenyouContentFrame(
          top: 12,
          bottom: 40,
          child: const WenyouPanel(
            child: WenyouEmptyState(
              icon: WenyouIconIds.contentTopic,
              title: '这个主题还没有子贴',
            ),
          ),
        ),
      )
    else ...[
      SliverToBoxAdapter(
        child: WenyouContentFrame(
          key: subthreadScroll.bodyKey,
          top: context.wenyouTokens.space12,
          bottom: context.wenyouTokens.space12,
          child: KeyedSubtree(
            key: renderGeometry.bodyKey,
            child: ReadingPositionAnchor(
              controller: quickScroll,
              label: '子贴正文',
              child: ThreadSubthreadBody(
                detail,
                selected!,
                onEdit: onCompose,
                diagnosticMarkdownKey: renderGeometry.markdownKey,
              ),
            ),
          ),
        ),
      ),
      if (actions.failure != null)
        SliverToBoxAdapter(
          child: WenyouContentFrame(
            top: 12,
            child: WenyouStatusBanner(
              tone: WenyouStatusTone.error,
              message: actions.failure!.userMessage,
              detail: wenyouFailureDetail(actions.failure, treatAsWrite: true),
            ),
          ),
        ),
      if (targetState != null)
        SliverToBoxAdapter(
          child: WenyouContentFrame(
            top: 12,
            child: ThreadTargetPostStatus(
              targetState: targetState,
              expectedThreadId: threadId,
              availableSubthreadIds: {
                for (final subthread in detail.subthreads) subthread.id,
              },
              onRetry: onRetryTarget,
            ),
          ),
        ),
      SliverToBoxAdapter(
        child: ThreadFloorFilters(
          state: state,
          floorCount: selected.postCount,
          authors: discussionAuthors,
          onRetryAuthors: () =>
              ref.invalidate(postFloorDiscussionAuthorsProvider(selected.id)),
          onOrderChanged: (order) {
            quickScroll.close();
            ref.read(provider.notifier).setFloorOrder(order);
          },
          onAuthorChanged: (author) {
            quickScroll.close();
            ref.read(provider.notifier).setFloorAuthor(author);
          },
        ),
      ),
      if (state.isLoadingFloors)
        const SliverToBoxAdapter(
          child: WenyouContentFrame(top: 12, child: ThreadFloorsLoadingState()),
        )
      else if (state.transientFailure != null &&
          state.retryAction == ThreadDetailRetryAction.floors)
        SliverToBoxAdapter(
          child: WenyouContentFrame(
            top: 12,
            child: ThreadDetailTransientFailure(
              failure: state.transientFailure!,
              onRetry: () => ref.read(provider.notifier).retryFloors(),
            ),
          ),
        )
      else if (displayedFloors.isEmpty)
        SliverToBoxAdapter(
          child: WenyouContentFrame(
            top: 12,
            child: WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.metricComments,
                title: state.floorAuthorId == null ? '还没有楼层' : '没有符合条件的楼层',
                message: state.floorAuthorId == null
                    ? '这个子贴目前只有正文，暂时没有后续讨论。'
                    : '可以换一位发言者，或查看全部楼层。',
                action: state.floorAuthorId == null
                    ? null
                    : TextButton.icon(
                        key: const Key('thread-floors-clear-author'),
                        onPressed: () => ref
                            .read(provider.notifier)
                            .applyFloorFilters(
                              order: state.floorOrder,
                              authorId: null,
                            ),
                        icon: const WenyouIcon(WenyouIconIds.actionClearFilter),
                        label: const Text('查看全部楼层'),
                      ),
              ),
            ),
          ),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final floor = displayedFloors[index];
              final focused =
                  usableTarget?.focusedReplyId == null &&
                  usableTarget?.floor.id == floor.id;
              return DiscussionKeepAlive(
                key: ValueKey('thread-floor-item-${floor.id}'),
                child: WenyouContentFrame(
                  top: index == 0 ? 12 : 0,
                  child: Column(
                    children: [
                      if (index > 0)
                        WenyouContentItemDivider(
                          key: ValueKey('thread-floor-divider-${floor.id}'),
                          variant: WenyouContentItemDividerVariant.line,
                        ),
                      ReadingPositionAnchor(
                        controller: quickScroll,
                        label: '第 ${floor.floorNumber} 楼附近',
                        child: ThreadFloorCard(
                          key: ValueKey('thread-floor-${floor.id}'),
                          threadId: threadId,
                          floor: floor,
                          isFocused: focused,
                          targetFrameKey: focused ? targetKey : null,
                          canEdit: floor.author.id == viewerId,
                          canDelete:
                              floor.author.id == viewerId ||
                              detail.canManageThread,
                          canPin: detail.canManageThread,
                          pending: actions.pendingPostId == floor.id,
                          onReply: authenticated
                              ? () => onCompose(
                                  threadDetailReplyFloorTarget(
                                    detail,
                                    selected,
                                    floor,
                                  ),
                                )
                              : onRequireLogin,
                          onReplyToReply: authenticated
                              ? (reply) => onCompose(
                                  threadDetailReplyInlineTarget(
                                    detail,
                                    selected,
                                    floor,
                                    reply,
                                  ),
                                )
                              : (_) => onRequireLogin(),
                          onDiscussion: () => onDiscussion(
                            floor,
                            focusedReplyId: usableTarget?.floor.id == floor.id
                                ? usableTarget?.focusedReplyId
                                : null,
                          ),
                          reportReturnTo:
                              !detail.isPrivate && floor.author.id != viewerId
                              ? AppRouteLocations.thread(
                                  threadId,
                                  postId: floor.id,
                                )
                              : null,
                          onEdit: () => onCompose(
                            threadDetailEditFloorTarget(
                              detail,
                              selected,
                              floor,
                            ),
                          ),
                          onDelete: () => onDeleteFloor(floor),
                          onTogglePin: () => onToggleFloorPin(floor),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: displayedFloors.length,
            findChildIndexCallback: (key) {
              final value = key is ValueKey<String> ? key.value : null;
              if (value == null || !value.startsWith('thread-floor-item-')) {
                return null;
              }
              final floorId = value.substring('thread-floor-item-'.length);
              final index = displayedFloors.indexWhere(
                (floor) => floor.id == floorId,
              );
              return index < 0 ? null : index;
            },
          ),
        ),
      SliverToBoxAdapter(
        child: WenyouContentFrame(
          top: 12,
          bottom:
              context.wenyouTokens.minimumTouchTarget +
              context.wenyouTokens.space32 +
              context.wenyouTokens.space16,
          child: ThreadFloorsFooter(
            state: state,
            onLoadMore: () => ref.read(provider.notifier).loadMore(),
          ),
        ),
      ),
    ],
  ];
}
