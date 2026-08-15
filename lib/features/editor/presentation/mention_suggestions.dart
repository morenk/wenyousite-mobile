import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
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
  final OverlayPortalController _overlayController = OverlayPortalController(
    debugLabel: 'mention-suggestions',
  );
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
        ? _detectQueryAt(selection.baseOffset)
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
      _hideOverlay();
      return;
    }
    _dismissedSignature = null;
    final threadId = widget.threadId?.trim();
    setState(() {
      _active = visible;
      _debouncing = threadId != null && threadId.isNotEmpty;
    });
    _showOverlay();
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
    _hideOverlay();
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
        ? _detectQueryAt(selection.baseOffset)
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
    _hideOverlay();
    widget.focusNode.requestFocus();
  }

  ActiveMentionQuery? _detectQueryAt(int cursor) {
    // A valid query contains at most 24 characters. Reading one extra
    // character before `@` is enough to validate the boundary without
    // materializing the complete document for every key event.
    final windowStart = cursor > 26 ? cursor - 26 : 0;
    final text = widget.controller.document.getPlainText(
      windowStart,
      cursor - windowStart,
    );
    final local = detectActiveMentionQuery(text, text.length);
    if (local == null) return null;
    return ActiveMentionQuery(
      start: local.start + windowStart,
      end: local.end + windowStart,
      query: local.query,
    );
  }

  void _showOverlay() {
    if (!_overlayController.isShowing) _overlayController.show();
  }

  void _hideOverlay() {
    if (_overlayController.isShowing) _overlayController.hide();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: _buildOverlay,
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final active = _active;
    if (active == null) return const SizedBox.shrink();
    final tokens = context.wenyouTokens;
    final media = MediaQuery.of(context);
    final keepsFormatToolsClear =
        media.size.width <= 400 && media.viewInsets.bottom > 0;
    final bottom =
        media.viewInsets.bottom +
        (keepsFormatToolsClear
            ? tokens.minimumTouchTarget + tokens.space16
            : tokens.space8);
    final availableHeight =
        media.size.height - bottom - media.padding.top - tokens.space8;
    final maxPanelHeight = availableHeight.clamp(
      tokens.minimumTouchTarget * 2,
      200.0,
    );
    final threadId = widget.threadId?.trim();
    final panel = threadId == null || threadId.isEmpty
        ? _MentionPanel(
            key: const Key('mention-context-required'),
            title: '提及需要主题上下文',
            onDismiss: _dismiss,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('请先保存到云端草稿，再继续输入 @ 选择可提及用户。'),
            ),
          )
        : _buildCandidatesPanel(threadId, active);
    return Positioned(
      left: tokens.space8,
      right: tokens.space8,
      bottom: bottom,
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: maxPanelHeight,
            ),
            child: panel,
          ),
        ),
      ),
    );
  }

  Widget _buildCandidatesPanel(String threadId, ActiveMentionQuery active) {
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
    return RepaintBoundary(
      key: const Key('mention-floating-panel'),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: '提及候选',
        child: Material(
          elevation: 4,
          color: Theme.of(context).colorScheme.surface,
          shadowColor: Theme.of(
            context,
          ).colorScheme.shadow.withValues(alpha: 0.14),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: tokens.border),
            borderRadius: BorderRadius.circular(tokens.radius12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space12,
              0,
              tokens.space4,
              tokens.space8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: tokens.minimumTouchTarget,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      IconButton(
                        key: const Key('mention-dismiss'),
                        tooltip: '关闭提及候选',
                        onPressed: onDismiss,
                        icon: const WenyouIcon(WenyouIconIds.actionClose),
                      ),
                    ],
                  ),
                ),
                Flexible(child: child),
              ],
            ),
          ),
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
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
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
        icon: WenyouIcon(WenyouIconIds.actionMention),
        message: '暂无匹配的可提及用户。',
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 144),
      child: ListView.builder(
        key: const Key('mention-results'),
        shrinkWrap: true,
        itemCount: count,
        itemBuilder: (context, index) {
          if (showAllPlayers && index == 0) {
            return ListTile(
              key: const Key('mention-all-players'),
              minTileHeight: context.wenyouTokens.minimumTouchTarget,
              leading: const WenyouIcon(WenyouIconIds.identityMembers),
              title: const Text('@全体玩家'),
              trailing: const Text('仅楼主/协作者'),
              onTap: onAllPlayers,
            );
          }
          final candidate = result.users[index - (showAllPlayers ? 1 : 0)];
          return ListTile(
            key: ValueKey('mention-user-${candidate.id}'),
            minTileHeight: context.wenyouTokens.minimumTouchTarget,
            leading: const WenyouIcon(WenyouIconIds.actionMention),
            title: Text(candidate.label),
            trailing: Text(candidate.relationLabel),
            onTap: () => onUser(candidate),
          );
        },
      ),
    );
  }
}
