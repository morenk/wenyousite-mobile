import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_chip.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/tags/application/thread_tag_management_controller.dart';
import 'package:wenyousite_mobile/features/tags/domain/tag_models.dart';

class ThreadTagManagementPage extends ConsumerStatefulWidget {
  const ThreadTagManagementPage({required this.threadId, super.key});

  final String threadId;

  @override
  ConsumerState<ThreadTagManagementPage> createState() =>
      _ThreadTagManagementPageState();
}

class _ThreadTagManagementPageState
    extends ConsumerState<ThreadTagManagementPage> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = threadTagManagementControllerProvider(widget.threadId);
    final state = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: const Text('管理主题标签')),
      body: switch (state.phase) {
        ThreadTagManagementPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        ThreadTagManagementPhase.failed => _TagManagementFatalState(
          failure: state.failure,
          onRetry: () => ref.read(provider.notifier).load(),
        ),
        ThreadTagManagementPhase.ready => _buildReady(state, provider),
      },
    );
  }

  Widget _buildReady(
    ThreadTagManagementState state,
    AutoDisposeStateNotifierProvider<
      ThreadTagManagementController,
      ThreadTagManagementState
    >
    provider,
  ) {
    final tokens = context.wenyouTokens;
    final bootstrap = state.bootstrap!;
    final selectedIds = bootstrap.tags.map((item) => item.id).toSet();
    final suggestions = bootstrap.suggestions
        .where((item) => !selectedIds.contains(item.id))
        .toList(growable: false);
    final normalizedQuery = normalizeTagName(_searchController.text);
    final hasExact = [
      ...bootstrap.tags,
      ...suggestions,
    ].any((item) => item.name == normalizedQuery);
    final canCreate =
        normalizedQuery.isNotEmpty &&
        validateTagName(normalizedQuery) == null &&
        !hasExact &&
        bootstrap.tags.length < maxThreadTagCount;
    final atLimit = bootstrap.tags.length >= maxThreadTagCount;
    return WenyouPageBody(
      maxWidth: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WenyouPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WenyouSectionHeader(
                  title: bootstrap.threadTitle,
                  subtitle: '每个主题最多 5 个标签。',
                ),
                SizedBox(height: tokens.space16),
                Text(
                  '已选标签 ${bootstrap.tags.length}/$maxThreadTagCount',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.space8),
                if (bootstrap.tags.isEmpty)
                  Text(
                    '尚未添加标签。搜索或输入名称即可添加；同名标签会自动复用。',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                  )
                else
                  Wrap(
                    spacing: tokens.space8,
                    runSpacing: tokens.space8,
                    children: [
                      for (final tag in bootstrap.tags)
                        WenyouTagChip(
                          key: Key('thread-tag-selected-${tag.id}'),
                          name: tag.name,
                          colorHex: tag.color,
                          deleteTooltip: '从主题移除 #${tag.name}',
                          onPressed: state.isBusy
                              ? null
                              : () => context.pushNamed(
                                  'tag-threads',
                                  pathParameters: {'tagId': tag.id},
                                ),
                          onDeleted: state.isBusy
                              ? null
                              : () => _confirmRemove(tag),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          if (atLimit) ...[
            SizedBox(height: tokens.space12),
            const WenyouStatusBanner(
              key: Key('thread-tag-limit'),
              message: '已经达到 5 个标签上限；移除一个标签后才能继续添加。',
            ),
          ],
          SizedBox(height: tokens.space12),
          WenyouPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WenyouSectionHeader(
                  title: '搜索与添加',
                  subtitle: '名称只能包含中英文、数字、下划线和 #。',
                ),
                SizedBox(height: tokens.space16),
                TextField(
                  key: const Key('thread-tag-search'),
                  controller: _searchController,
                  enabled: !state.isMutating && !atLimit,
                  maxLength: maxTagNameLength,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: '搜索标签',
                    hintText: '例如：无限流',
                    prefixIcon: const WenyouIcon(WenyouIconIds.actionSearch),
                    suffixIcon: state.isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: '清空搜索',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              _scheduleSearch('');
                            },
                            icon: const WenyouIcon(WenyouIconIds.actionClose),
                          ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _scheduleSearch(value);
                  },
                  onSubmitted: (value) {
                    _searchDebounce?.cancel();
                    ref.read(provider.notifier).search(value);
                  },
                ),
                if (canCreate) ...[
                  SizedBox(height: tokens.space8),
                  OutlinedButton.icon(
                    key: const Key('thread-tag-create'),
                    onPressed: state.isBusy
                        ? null
                        : () => _addByName(normalizedQuery),
                    icon: state.mutatingTagId == 'add:$normalizedQuery'
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const WenyouIcon(WenyouIconIds.actionAddTag),
                    label: Text('添加 #$normalizedQuery'),
                  ),
                ],
                SizedBox(height: tokens.space12),
                if (!state.isSearching && suggestions.isEmpty)
                  Text(
                    normalizedQuery.isEmpty ? '当前没有可添加的标签。' : '没有找到其他匹配标签。',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                  )
                else
                  for (final tag in suggestions)
                    ListTile(
                      key: Key('thread-tag-suggestion-${tag.id}'),
                      contentPadding: EdgeInsets.zero,
                      leading: _TagColorDot(colorHex: tag.color),
                      title: Text('#${tag.name}'),
                      subtitle: tag.description == null
                          ? null
                          : Text(
                              tag.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      trailing: state.mutatingTagId == tag.id
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const WenyouIcon(WenyouIconIds.actionAdd),
                      enabled: !state.isBusy && !atLimit,
                      onTap: state.isBusy || atLimit
                          ? null
                          : () => _addExisting(tag),
                    ),
              ],
            ),
          ),
          if (state.failure != null) ...[
            SizedBox(height: tokens.space12),
            WenyouStatusBanner(
              key: const Key('thread-tag-failure'),
              tone: WenyouStatusTone.error,
              message: state.failure!.userMessage,
              detail: state.failure!.requestId == null
                  ? null
                  : '问题编号：${state.failure!.requestId}',
              action: TextButton(
                onPressed: state.isMutating
                    ? null
                    : () => ref.read(provider.notifier).clearFailure(),
                child: const Text('知道了'),
              ),
            ),
          ],
          if (state.actionOutcome != null) ...[
            SizedBox(height: tokens.space12),
            WenyouWriteOutcomeBanner(
              key: const Key('thread-tag-write-outcome'),
              status: state.actionOutcome!,
              confirmingMessage: '正在确认标签状态…',
              indeterminateMessage: '标签操作结果暂时无法确定，请稍后刷新查看。',
              requestId: state.actionRequestId,
              onRefresh: () => ref.read(provider.notifier).load(),
              refreshKey: const Key('thread-tag-refresh-result'),
            ),
          ],
        ],
      ),
    );
  }

  void _scheduleSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      ref
          .read(threadTagManagementControllerProvider(widget.threadId).notifier)
          .search(value);
    });
  }

  Future<void> _addExisting(TopicTagModel tag) async {
    final succeeded = await ref
        .read(threadTagManagementControllerProvider(widget.threadId).notifier)
        .addExisting(tag);
    if (!succeeded || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已添加 #${tag.name}。')));
  }

  Future<void> _addByName(String name) async {
    final succeeded = await ref
        .read(threadTagManagementControllerProvider(widget.threadId).notifier)
        .addByName(name);
    if (!succeeded || !mounted) return;
    _searchController.clear();
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已添加 #$name。')));
  }

  Future<void> _confirmRemove(TopicTagModel tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('移除 #${tag.name}？'),
        content: const Text('只会解除这个主题与标签的关联，不会删除全局标签，也不会影响其他主题。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('thread-tag-remove-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认移除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final succeeded = await ref
        .read(threadTagManagementControllerProvider(widget.threadId).notifier)
        .remove(tag);
    if (!succeeded || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已移除 #${tag.name}。')));
  }
}

class _TagColorDot extends StatelessWidget {
  const _TagColorDot({this.colorHex});

  final String? colorHex;

  @override
  Widget build(BuildContext context) {
    final fallback = context.wenyouTokens.brandForeground;
    final color = colorHex == null
        ? fallback
        : Color(int.parse(colorHex!.substring(1), radix: 16) | 0xff000000);
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const SizedBox.square(dimension: 12),
    );
  }
}

class _TagManagementFatalState extends StatelessWidget {
  const _TagManagementFatalState({
    required this.failure,
    required this.onRetry,
  });

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: failure?.httpStatus == 403
              ? WenyouIconIds.actionLock
              : WenyouIconIds.statusOffline,
          title: failure?.httpStatus == 403 ? '无法管理这个主题' : '主题标签加载失败',
          message: failure?.userMessage ?? '请检查网络后重试。',
          detail: failure?.requestId == null
              ? null
              : '问题编号：${failure!.requestId}',
          action: failure?.httpStatus == 403
              ? null
              : OutlinedButton.icon(
                  key: const Key('thread-tag-retry'),
                  onPressed: onRetry,
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                  label: const Text('重新加载'),
                ),
        ),
      ),
    );
  }
}
