import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/models/thread_category_presentation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_page_failure_state.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_pagination.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_chip.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/tags/application/tag_threads_controller.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_feed_card.dart';

class TagThreadsPage extends ConsumerStatefulWidget {
  const TagThreadsPage({required this.tagId, super.key});

  final String tagId;

  @override
  ConsumerState<TagThreadsPage> createState() => _TagThreadsPageState();
}

class _TagThreadsPageState extends ConsumerState<TagThreadsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreNearEnd);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadMoreNearEnd)
      ..dispose();
    super.dispose();
  }

  void _loadMoreNearEnd() {
    if (!_scrollController.hasClients ||
        !wenyouShouldPrefetch(_scrollController.position)) {
      return;
    }
    ref.read(tagThreadsControllerProvider(widget.tagId).notifier).loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final provider = tagThreadsControllerProvider(widget.tagId);
    final state = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(
        title: Text(state.tag == null ? '标签主题' : '#${state.tag!.name}'),
      ),
      body: switch (state.phase) {
        TagThreadsPhase.loading => const WenyouPageBody(
          child: WenyouListSkeleton(label: '正在加载标签主题'),
        ),
        TagThreadsPhase.failed => _TagFatalState(
          failure: state.failure,
          onRetry: () => ref.read(provider.notifier).loadInitial(),
        ),
        TagThreadsPhase.ready => _buildReady(state, provider),
      },
    );
  }

  Widget _buildReady(
    TagThreadsState state,
    AutoDisposeStateNotifierProvider<TagThreadsController, TagThreadsState>
    provider,
  ) {
    final tokens = context.wenyouTokens;
    final transientCount = state.transientFailure == null ? 0 : 1;
    final contentCount = state.items.isEmpty ? 1 : state.items.length;
    final footerCount = state.items.isEmpty ? 0 : 1;
    return RefreshIndicator(
      onRefresh: () => ref.read(provider.notifier).refresh(),
      child: ListView.builder(
        key: PageStorageKey('tag-threads-${widget.tagId}'),
        controller: _scrollController,
        addAutomaticKeepAlives: false,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          wenyouHorizontalPagePadding(context),
          tokens.space16,
          wenyouHorizontalPagePadding(context),
          tokens.space32,
        ),
        itemCount: 1 + transientCount + contentCount + footerCount,
        itemBuilder: (context, index) {
          var cursor = index;
          if (cursor == 0) {
            return WenyouConstrainedWidth(
              child: WenyouPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WenyouSectionHeader(
                      title: '#${state.tag!.name}',
                      subtitle: state.tag!.description,
                    ),
                    SizedBox(height: tokens.space12),
                    WenyouTagChip(
                      key: Key('tag-detail-${state.tag!.id}'),
                      name: state.tag!.name,
                    ),
                    SizedBox(height: tokens.space8),
                    Text(
                      '已加载 ${state.items.length} 个主题',
                      style: Theme.of(context).textTheme.wenyouCaption.copyWith(
                        color: tokens.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          cursor -= 1;
          if (state.transientFailure != null) {
            if (cursor == 0) {
              return Padding(
                padding: EdgeInsets.only(top: tokens.space12),
                child: WenyouConstrainedWidth(
                  child: WenyouFailureBanner(
                    key: const Key('tag-threads-transient-failure'),
                    failure: state.transientFailure!,
                    action: TextButton(
                      onPressed:
                          state.transientRetryAction ==
                              TagThreadsRetryAction.loadMore
                          ? () => ref.read(provider.notifier).loadMore()
                          : () => ref.read(provider.notifier).refresh(),
                      child: const Text('重试'),
                    ),
                  ),
                ),
              );
            }
            cursor -= 1;
          }
          if (state.items.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: tokens.space12),
              child: const WenyouConstrainedWidth(
                child: WenyouPanel(
                  child: WenyouEmptyState(
                    icon: WenyouIconIds.actionAddReaction,
                    title: '这个标签下还没有公开主题',
                  ),
                ),
              ),
            );
          }
          if (cursor < state.items.length) {
            final thread = state.items[cursor];
            return Padding(
              padding: EdgeInsets.only(top: tokens.space12),
              child: WenyouConstrainedWidth(
                child: HomeThreadCard(
                  key: Key('tag-thread-${thread.id}'),
                  thread: thread,
                  category: resolveThreadCategoryPresentation(
                    thread.categorySlug,
                    categories: state.categories,
                  ),
                  onTap: () => context.pushNamed(
                    'thread-detail',
                    pathParameters: {'threadId': thread.id},
                  ),
                  onTagTap: (tag) => context.pushNamed(
                    'tag-threads',
                    pathParameters: {'tagId': tag.id},
                  ),
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(top: tokens.space16),
            child: WenyouConstrainedWidth(
              child: WenyouPaginationFooter(
                hasMore: state.hasMore,
                isLoading: state.isLoadingMore,
                onLoadMore: () => ref.read(provider.notifier).loadMore(),
                loadMoreKey: const Key('tag-threads-load-more'),
                endLabel: '已经看到这个标签下的全部主题',
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TagFatalState extends StatelessWidget {
  const _TagFatalState({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final missing = failure?.httpStatus == 404;
    return WenyouPageFailureState(
      title: missing ? '标签不存在或已停用' : '标签主题加载失败',
      failure: failure,
      onRetry: onRetry,
      maxWidth: 520,
      icon: missing
          ? WenyouIconIds.actionRemoveTag
          : WenyouIconIds.statusOffline,
      retryKey: const Key('tag-threads-retry'),
    );
  }
}
