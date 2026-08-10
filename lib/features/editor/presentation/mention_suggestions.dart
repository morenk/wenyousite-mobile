import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/editor/application/mention_candidates_controller.dart';
import 'package:wenyousite_mobile/features/editor/domain/mention_models.dart';

class MentionSuggestions extends ConsumerStatefulWidget {
  const MentionSuggestions({
    required this.controller,
    required this.focusNode,
    required this.threadId,
    required this.enabled,
    this.debounce = const Duration(milliseconds: 180),
    super.key,
  });

  final QuillController controller;
  final FocusNode focusNode;
  final String? threadId;
  final bool enabled;
  final Duration debounce;

  @override
  ConsumerState<MentionSuggestions> createState() => _MentionSuggestionsState();
}

class _MentionSuggestionsState extends ConsumerState<MentionSuggestions> {
  Timer? _timer;
  ActiveMentionQuery? _active;
  bool _debouncing = false;
  bool _suppressControllerEvents = false;
  String? _dismissedSignature;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncFromController(force: true);
    });
  }

  @override
  void didUpdateWidget(covariant MentionSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
    if (oldWidget.controller != widget.controller ||
        oldWidget.threadId != widget.threadId ||
        oldWidget.enabled != widget.enabled) {
      _syncFromController(force: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!_suppressControllerEvents) _syncFromController();
  }

  void _syncFromController({bool force = false}) {
    if (!mounted) return;
    final selection = widget.controller.selection;
    final next = widget.enabled && selection.isCollapsed
        ? detectActiveMentionQuery(
            widget.controller.document.toPlainText(),
            selection.baseOffset,
          )
        : null;
    final signature = _signature(next);
    final visible = signature == _dismissedSignature ? null : next;
    if (!force && visible == _active) return;
    _timer?.cancel();
    if (visible == null) {
      if (_active != null || _debouncing) {
        setState(() {
          _active = null;
          _debouncing = false;
        });
      }
      return;
    }
    _dismissedSignature = null;
    final threadId = widget.threadId?.trim();
    setState(() {
      _active = visible;
      _debouncing = threadId != null && threadId.isNotEmpty;
    });
    if (threadId == null || threadId.isEmpty) return;
    _timer = Timer(widget.debounce, () {
      if (!mounted ||
          _active != visible ||
          widget.threadId?.trim() != threadId) {
        return;
      }
      setState(() => _debouncing = false);
      unawaited(
        ref
            .read(mentionCandidatesControllerProvider(threadId).notifier)
            .search(visible.query),
      );
    });
  }

  String? _signature(ActiveMentionQuery? query) => query == null
      ? null
      : '${query.start}:${query.end}:${query.query}:${widget.threadId ?? ''}';

  void _dismiss() {
    final active = _active;
    if (active == null) return;
    _timer?.cancel();
    setState(() {
      _dismissedSignature = _signature(active);
      _active = null;
      _debouncing = false;
    });
    widget.focusNode.requestFocus();
  }

  void _insertUser(MentionCandidate candidate) {
    _insert(
      Embeddable(MarkdownDeltaCodec.mentionEmbed, {
        'version': 1,
        'kind': 'user',
        'userId': candidate.id,
        'label': candidate.label,
      }),
    );
  }

  void _insertAllPlayers() {
    _insert(
      const Embeddable(MarkdownDeltaCodec.mentionEmbed, {
        'version': 1,
        'kind': 'all_players',
        'label': '@全体玩家',
      }),
    );
  }

  void _insert(Embeddable embed) {
    final active = _active;
    final selection = widget.controller.selection;
    final current = selection.isCollapsed
        ? detectActiveMentionQuery(
            widget.controller.document.toPlainText(),
            selection.baseOffset,
          )
        : null;
    if (active == null || current != active) {
      _syncFromController(force: true);
      return;
    }
    _timer?.cancel();
    _suppressControllerEvents = true;
    try {
      widget.controller.replaceText(
        active.start,
        active.length,
        embed,
        TextSelection.collapsed(offset: active.start + 1),
      );
      widget.controller.replaceText(
        active.start + 1,
        0,
        ' ',
        TextSelection.collapsed(offset: active.start + 2),
      );
    } finally {
      _suppressControllerEvents = false;
    }
    setState(() {
      _active = null;
      _debouncing = false;
      _dismissedSignature = null;
    });
    widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final active = _active;
    if (active == null) return const SizedBox.shrink();
    final threadId = widget.threadId?.trim();
    if (threadId == null || threadId.isEmpty) {
      return _MentionPanel(
        key: const Key('mention-context-required'),
        title: '提及需要主题上下文',
        onDismiss: _dismiss,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('请先保存到服务端草稿，再继续输入 @ 选择可提及用户。'),
        ),
      );
    }
    final state = ref.watch(mentionCandidatesControllerProvider(threadId));
    final matchesQuery = state.query == active.query;
    final loading =
        _debouncing ||
        !matchesQuery ||
        state.phase == MentionCandidatesPhase.idle ||
        state.phase == MentionCandidatesPhase.loading;
    return _MentionPanel(
      key: const Key('mention-suggestions'),
      title: active.query.isEmpty ? '选择要提及的人' : '查找“${active.query}”',
      onDismiss: _dismiss,
      child: loading
          ? const _MentionStatus(
              key: Key('mention-loading'),
              icon: SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              message: '正在查找可提及用户…',
            )
          : switch (state.phase) {
              MentionCandidatesPhase.failed => _MentionFailure(
                failure: state.failure!,
                onRetry: () => ref
                    .read(
                      mentionCandidatesControllerProvider(threadId).notifier,
                    )
                    .retry(),
              ),
              MentionCandidatesPhase.ready => _MentionResults(
                result: state.result,
                query: active.query,
                onAllPlayers: _insertAllPlayers,
                onUser: _insertUser,
              ),
              _ => const SizedBox.shrink(),
            },
    );
  }
}

class _MentionPanel extends StatelessWidget {
  const _MentionPanel({
    required this.title,
    required this.onDismiss,
    required this.child,
    super.key,
  });

  final String title;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Material(
      color: tokens.softPanel,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.space12,
          tokens.space4,
          tokens.space4,
          tokens.space8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                IconButton(
                  key: const Key('mention-dismiss'),
                  tooltip: '关闭提及候选',
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _MentionStatus extends StatelessWidget {
  const _MentionStatus({required this.icon, required this.message, super.key});

  final Widget icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: context.wenyouTokens.minimumTouchTarget,
      ),
      child: Row(
        children: [
          icon,
          SizedBox(width: context.wenyouTokens.space8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _MentionFailure extends StatelessWidget {
  const _MentionFailure({required this.failure, required this.onRetry});

  final ApiFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final requestId = failure.requestId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          failure.userMessage,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        if (requestId != null) Text('请求 ID：$requestId'),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            key: const Key('mention-retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重试'),
          ),
        ),
      ],
    );
  }
}

class _MentionResults extends StatelessWidget {
  const _MentionResults({
    required this.result,
    required this.query,
    required this.onAllPlayers,
    required this.onUser,
  });

  final MentionCandidatesResult result;
  final String query;
  final VoidCallback onAllPlayers;
  final ValueChanged<MentionCandidate> onUser;

  @override
  Widget build(BuildContext context) {
    final showAllPlayers =
        result.canMentionAllPlayers &&
        (query.isEmpty || '全体玩家'.startsWith(query));
    final count = result.users.length + (showAllPlayers ? 1 : 0);
    if (count == 0) {
      return const _MentionStatus(
        key: Key('mention-empty'),
        icon: Icon(Icons.alternate_email_rounded),
        message: '暂无匹配的可提及用户。',
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 224),
      child: ListView.builder(
        key: const Key('mention-results'),
        shrinkWrap: true,
        itemCount: count,
        itemBuilder: (context, index) {
          if (showAllPlayers && index == 0) {
            return ListTile(
              key: const Key('mention-all-players'),
              minTileHeight: context.wenyouTokens.minimumTouchTarget,
              leading: const Icon(Icons.groups_2_outlined),
              title: const Text('@全体玩家'),
              trailing: const Text('仅楼主/协作者'),
              onTap: onAllPlayers,
            );
          }
          final candidate = result.users[index - (showAllPlayers ? 1 : 0)];
          return ListTile(
            key: ValueKey('mention-user-${candidate.id}'),
            minTileHeight: context.wenyouTokens.minimumTouchTarget,
            leading: const Icon(Icons.alternate_email_rounded),
            title: Text(candidate.label),
            trailing: Text(candidate.relationLabel),
            onTap: () => onUser(candidate),
          );
        },
      ),
    );
  }
}
