import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/search/application/search_controller.dart';
import 'package:wenyousite_mobile/features/search/domain/search_models.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _queryController;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(
      text: ref.read(searchControllerProvider).query,
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
        .read(searchControllerProvider.notifier)
        .submit(_queryController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final tokens = context.wenyouTokens;
    ref.listen(searchControllerProvider.select((value) => value.query), (
      previous,
      next,
    ) {
      if (previous?.isNotEmpty == true && next.isEmpty) {
        _queryController.clear();
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('搜索')),
      body: RefreshIndicator(
        onRefresh: state.hasQuery
            ? () => ref.read(searchControllerProvider.notifier).refreshActive()
            : () async {},
        child: ListView(
          key: const PageStorageKey('search-results-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: _pagePadding(context),
          children: [
            _SearchForm(
              controller: _queryController,
              focusNode: _focusNode,
              onSubmitted: _submit,
            ),
            SizedBox(height: tokens.space16),
            _SearchTabs(state: state),
            SizedBox(height: tokens.space16),
            if (!state.hasQuery)
              const WenyouPanel(
                child: WenyouEmptyState(
                  icon: Icons.manage_search_rounded,
                  title: '输入关键词开始搜索',
                  message: '可以查找公开主题、用户和楼层正文。',
                ),
              )
            else
              _ActiveSearchResults(state: state),
          ],
        ),
      ),
    );
  }

  EdgeInsets _pagePadding(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = MediaQuery.sizeOf(context).width <= 400
        ? tokens.space12
        : tokens.space24;
    return EdgeInsets.fromLTRB(
      horizontal,
      tokens.space16,
      horizontal,
      tokens.space32,
    );
  }
}

class _SearchForm extends StatelessWidget {
  const _SearchForm({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Future<void> Function() onSubmitted;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      container: true,
      label: '全站搜索',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              key: const Key('search-query-input'),
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: '关键词',
                hintText: '主题、用户名或楼层内容',
                prefixIcon: Icon(Icons.search_rounded),
                counterText: '',
              ),
              onSubmitted: (_) => onSubmitted(),
            ),
          ),
          SizedBox(width: tokens.space8),
          SizedBox(
            height: tokens.minimumTouchTarget,
            child: FilledButton(
              key: const Key('search-submit'),
              onPressed: onSubmitted,
              child: const Text('搜索'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchTabs extends ConsumerWidget {
  const _SearchTabs({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<SearchResultTab>(
      showSelectedIcon: false,
      selected: {state.activeTab},
      onSelectionChanged: (selection) {
        ref.read(searchControllerProvider.notifier).selectTab(selection.single);
      },
      segments: [
        for (final tab in SearchResultTab.values)
          ButtonSegment(
            value: tab,
            label: Text(tab.label),
            icon: Icon(_tabIcon(tab), size: 18),
          ),
      ],
    );
  }

  IconData _tabIcon(SearchResultTab tab) => switch (tab) {
    SearchResultTab.threads => Icons.forum_outlined,
    SearchResultTab.users => Icons.people_outline_rounded,
    SearchResultTab.posts => Icons.subject_rounded,
  };
}

class _ActiveSearchResults extends ConsumerWidget {
  const _ActiveSearchResults({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.activeTab == SearchResultTab.posts && !state.isPostQueryValid) {
      return const WenyouPanel(
        child: WenyouEmptyState(
          icon: Icons.text_fields_rounded,
          title: '正文搜索至少需要 2 个字符',
          message: '主题和用户名仍然支持单字符搜索。',
        ),
      );
    }
    return switch (state.activeTab) {
      SearchResultTab.threads => _SectionBody<SearchThreadResult>(
        state: state.threads,
        emptyTitle: '没有匹配的主题',
        emptyMessage: '可以换个关键词，或切换到用户和正文。',
        itemBuilder: (context, item) => _ThreadResultCard(item: item),
      ),
      SearchResultTab.users => _SectionBody<SearchUserResult>(
        state: state.users,
        emptyTitle: '没有匹配的用户',
        emptyMessage: '用户搜索只匹配当前有效的用户名。',
        itemBuilder: (context, item) => _UserResultCard(item: item),
      ),
      SearchResultTab.posts => _PostSectionBody(state: state.posts),
    };
  }
}

class _SectionBody<T> extends ConsumerWidget {
  const _SectionBody({
    required this.state,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.itemBuilder,
  });

  final SearchSectionState<T> state;
  final String emptyTitle;
  final String emptyMessage;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    return switch (state.phase) {
      SearchSectionPhase.idle ||
      SearchSectionPhase.loading => const _SearchLoadingState(),
      SearchSectionPhase.failed => _SearchErrorState(
        failure: state.failure,
        onRetry: () =>
            ref.read(searchControllerProvider.notifier).retryActive(),
      ),
      SearchSectionPhase.ready when state.items.isEmpty => WenyouPanel(
        child: WenyouEmptyState(
          icon: Icons.search_off_rounded,
          title: emptyTitle,
          message: emptyMessage,
        ),
      ),
      SearchSectionPhase.ready => Column(
        children: [
          for (var index = 0; index < state.items.length; index++) ...[
            if (index > 0) SizedBox(height: tokens.space12),
            itemBuilder(context, state.items[index]),
          ],
        ],
      ),
    };
  }
}

class _PostSectionBody extends ConsumerWidget {
  const _PostSectionBody({required this.state});

  final SearchSectionState<SearchPostResult> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    if (state.phase != SearchSectionPhase.ready || state.items.isEmpty) {
      return _SectionBody<SearchPostResult>(
        state: state,
        emptyTitle: '没有匹配的正文',
        emptyMessage: '可以换个关键词，或切换到主题和用户。',
        itemBuilder: (context, item) => _PostResultCard(item: item),
      );
    }
    return Column(
      children: [
        for (var index = 0; index < state.items.length; index++) ...[
          if (index > 0) SizedBox(height: tokens.space12),
          _PostResultCard(item: state.items[index]),
        ],
        if (state.failure != null) ...[
          SizedBox(height: tokens.space12),
          _SearchInlineError(
            failure: state.failure!,
            onRetry: () =>
                ref.read(searchControllerProvider.notifier).loadMorePosts(),
          ),
        ],
        if (state.hasMore) ...[
          SizedBox(height: tokens.space12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('search-posts-load-more'),
              onPressed: state.isLoadingMore
                  ? null
                  : () => ref
                        .read(searchControllerProvider.notifier)
                        .loadMorePosts(),
              icon: state.isLoadingMore
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more_rounded),
              label: Text(state.isLoadingMore ? '正在加载' : '加载更多正文'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ThreadResultCard extends StatelessWidget {
  const _ThreadResultCard({required this.item});

  final SearchThreadResult item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      label: '打开主题 ${item.title}',
      child: WenyouPanel(
        onTap: () => context.pushNamed(
          'thread-detail',
          pathParameters: {'threadId': item.id},
          extra: item.categorySlug,
        ),
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.titleLarge),
            if (item.coverImageUrls.isNotEmpty) ...[
              SizedBox(height: tokens.space12),
              _SearchCover(
                url: item.coverImageUrls.first,
                extraCount: item.coverImageUrls.length - 1,
              ),
            ],
            SizedBox(height: tokens.space12),
            Text(
              '${item.ownerName} · ${_formatDate(item.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: tokens.space8),
            Text(
              '${item.memberCount} 成员 · ${item.playerCount} 玩家 · '
              '${item.postCount} 条内容',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchCover extends StatelessWidget {
  const _SearchCover({required this.url, required this.extraCount});

  final String url;
  final int extraCount;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Icon(Icons.broken_image_outlined, color: tokens.mutedText),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) => fallback,
              errorWidget: (_, _, _) => fallback,
            ),
            if (extraCount > 0)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(tokens.space8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tokens.text.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(tokens.radiusPill),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.space8,
                        vertical: tokens.space4,
                      ),
                      child: Text(
                        '+$extraCount',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: tokens.panel),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UserResultCard extends StatelessWidget {
  const _UserResultCard({required this.item});

  final SearchUserResult item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      label: '打开用户 ${item.username}',
      child: WenyouPanel(
        onTap: () => context.pushNamed(
          'user-profile',
          pathParameters: {'userId': item.id},
        ),
        padding: EdgeInsets.all(tokens.space16),
        child: Row(
          children: [
            _SearchAvatar(url: item.avatarUrl, name: item.username),
            SizedBox(width: tokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.username,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (item.bio != null) ...[
                    SizedBox(height: tokens.space4),
                    Text(
                      item.bio!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: tokens.space8),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _PostResultCard extends StatelessWidget {
  const _PostResultCard({required this.item});

  final SearchPostResult item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final location = Uri(
      path: '/threads/${item.threadId}',
      queryParameters: {'post': item.id},
    ).toString();
    return Semantics(
      button: true,
      label: '打开 ${item.threadTitle} 中的匹配正文',
      child: WenyouPanel(
        onTap: () => context.push(location),
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.preview.isEmpty ? '该内容没有可显示的文字预览' : item.preview,
              maxLines: 4,
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
              '${item.threadTitle} · ${item.subthreadTitle}',
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

class _SearchAvatar extends StatelessWidget {
  const _SearchAvatar({required this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Icon(Icons.person_rounded, color: tokens.mutedText),
    );
    return Semantics(
      image: true,
      label: '$name 的头像',
      child: ClipOval(
        child: SizedBox.square(
          dimension: tokens.minimumTouchTarget,
          child: url == null
              ? fallback
              : CachedNetworkImage(
                  imageUrl: url!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}

class _SearchLoadingState extends StatelessWidget {
  const _SearchLoadingState();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: tokens.space12),
          const Text('正在搜索…'),
        ],
      ),
    );
  }
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPanel(
      child: WenyouEmptyState(
        icon: Icons.cloud_off_outlined,
        title: '搜索没有完成',
        message: failure?.userMessage ?? '请检查网络后重试。',
        detail: failure?.requestId == null
            ? null
            : '请求 ID：${failure!.requestId}',
        action: OutlinedButton.icon(
          key: const Key('search-retry'),
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('重试'),
        ),
      ),
    );
  }
}

class _SearchInlineError extends StatelessWidget {
  const _SearchInlineError({required this.failure, required this.onRetry});

  final ApiFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouStatusBanner(
      tone: WenyouStatusTone.error,
      message: failure.userMessage,
      detail: failure.requestId == null ? null : '请求 ID：${failure.requestId}',
      action: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('重试加载更多'),
      ),
    );
  }
}

String _formatDate(DateTime value) => DateFormat('yyyy-MM-dd').format(value);
