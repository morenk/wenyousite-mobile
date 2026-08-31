import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/search/application/search_controller.dart';
import 'package:wenyousite_mobile/features/search/domain/search_models.dart';

class ThreadPostSearchPage extends ConsumerStatefulWidget {
  const ThreadPostSearchPage({required this.threadId, super.key});

  final String threadId;

  @override
  ConsumerState<ThreadPostSearchPage> createState() =>
      _ThreadPostSearchPageState();
}

class _ThreadPostSearchPageState extends ConsumerState<ThreadPostSearchPage> {
  late final TextEditingController _queryController;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(
      text: ref.read(threadPostSearchControllerProvider(widget.threadId)).query,
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _focusNode.unfocus();
    await ref
        .read(threadPostSearchControllerProvider(widget.threadId).notifier)
        .submit(_queryController.text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = threadPostSearchControllerProvider(widget.threadId);
    final state = ref.watch(provider);
    final tokens = context.wenyouTokens;
    ref.listen(provider.select((value) => value.query), (previous, next) {
      if (previous?.isNotEmpty == true && next.isEmpty) {
        _queryController.clear();
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('主题内搜索')),
      body: RefreshIndicator(
        onRefresh: state.isQueryValid
            ? () => ref.read(provider.notifier).retry()
            : () async {},
        child: ListView(
          key: PageStorageKey('thread-search-${widget.threadId}'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: _pagePadding(context),
          children: [
            Semantics(
              container: true,
              label: '搜索当前主题的楼层内容',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('thread-search-query-input'),
                      controller: _queryController,
                      focusNode: _focusNode,
                      maxLength: 100,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        labelText: '主题内关键词',
                        hintText: '搜索全部子贴的楼层内容',
                        prefixIcon: WenyouIcon(WenyouIconIds.actionSearch),
                        counterText: '',
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  SizedBox(width: tokens.space8),
                  SizedBox(
                    height: tokens.minimumTouchTarget,
                    child: FilledButton(
                      key: const Key('thread-search-submit'),
                      onPressed: _submit,
                      child: const Text('搜索'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.space16),
            if (!state.hasQuery)
              const WenyouPanel(
                child: WenyouEmptyState(
                  icon: WenyouIconIds.actionSearch,
                  title: '输入关键词搜索当前主题',
                ),
              )
            else if (!state.isQueryValid)
              const WenyouPanel(
                child: WenyouEmptyState(
                  icon: WenyouIconIds.editorHeading,
                  title: '主题内搜索至少需要 2 个字符',
                  message: '请补充一个字符后重新搜索。',
                ),
              )
            else
              _ThreadSearchResults(
                threadId: widget.threadId,
                state: state.results,
              ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _pagePadding(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = wenyouHorizontalPagePadding(context);
    return EdgeInsets.fromLTRB(
      horizontal,
      tokens.space16,
      horizontal,
      tokens.space32,
    );
  }
}

class _ThreadSearchResults extends ConsumerWidget {
  const _ThreadSearchResults({required this.threadId, required this.state});

  final String threadId;
  final SearchSectionState<SearchPostResult> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final provider = threadPostSearchControllerProvider(threadId);
    return switch (state.phase) {
      SearchSectionPhase.idle || SearchSectionPhase.loading => WenyouPanel(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: tokens.space12),
            const Text('正在搜索当前主题…'),
          ],
        ),
      ),
      SearchSectionPhase.failed => _ThreadSearchError(
        failure: state.failure,
        onRetry: () => ref.read(provider.notifier).retry(),
      ),
      SearchSectionPhase.ready when state.items.isEmpty => const WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.statusNoResults,
          title: '当前主题没有匹配内容',
          message: '可以换个关键词后重新搜索。',
        ),
      ),
      SearchSectionPhase.ready => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < state.items.length; index++) ...[
            if (index > 0) SizedBox(height: tokens.space12),
            _ThreadSearchResultCard(item: state.items[index]),
          ],
          if (state.failure != null) ...[
            SizedBox(height: tokens.space12),
            WenyouStatusBanner(
              tone: WenyouStatusTone.error,
              message: state.failure!.userMessage,
              detail: wenyouFailureDetail(state.failure),
              action: TextButton.icon(
                onPressed: () => ref.read(provider.notifier).loadMore(),
                icon: const WenyouIcon(WenyouIconIds.actionRefresh, size: 18),
                label: const Text('重试加载更多'),
              ),
            ),
          ],
          if (state.hasMore && state.failure == null) ...[
            SizedBox(height: tokens.space12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('thread-search-load-more'),
                onPressed: state.isLoadingMore
                    ? null
                    : () => ref.read(provider.notifier).loadMore(),
                icon: state.isLoadingMore
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const WenyouIcon(WenyouIconIds.navigationExpand),
                label: Text(state.isLoadingMore ? '正在加载' : '加载更多结果'),
              ),
            ),
          ],
        ],
      ),
    };
  }
}

class _ThreadSearchResultCard extends StatelessWidget {
  const _ThreadSearchResultCard({required this.item});

  final SearchPostResult item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      label: '打开当前主题中的匹配正文',
      child: WenyouPanel(
        key: Key('thread-search-result-${item.id}'),
        onTap: () => context.pushNamed(
          'thread-detail',
          pathParameters: {'threadId': item.threadId},
          queryParameters: {'post': item.id},
        ),
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.preview.isEmpty ? '该内容没有可显示的文字预览' : item.preview,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: tokens.space12),
            Text(
              '${item.authorName} · '
              '${item.floorNumber == null ? '楼中楼' : '#${item.floorNumber}'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: tokens.space4),
            Text(
              item.subthreadTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadSearchError extends StatelessWidget {
  const _ThreadSearchError({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPanel(
      child: WenyouEmptyState(
        icon: WenyouIconIds.statusOffline,
        title: '主题内搜索失败',
        message: failure?.userMessage ?? '请检查网络后重试。',
        detail: wenyouFailureDetail(failure),
        action: OutlinedButton.icon(
          key: const Key('thread-search-retry'),
          onPressed: onRetry,
          icon: const WenyouIcon(WenyouIconIds.actionRefresh),
          label: const Text('重试'),
        ),
      ),
    );
  }
}
