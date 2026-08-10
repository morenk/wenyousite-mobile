import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_widgets.dart';

class DirectConversationPage extends ConsumerStatefulWidget {
  const DirectConversationPage({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<DirectConversationPage> createState() =>
      _DirectConversationPageState();
}

class _DirectConversationPageState
    extends ConsumerState<DirectConversationPage> {
  final _scrollController = ScrollController();
  Timer? _clockTimer;
  var _now = DateTime.now();
  String? _lastMessageId;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(directMessagesEnabledProvider);
    if (!enabled) return const _DirectConversationUnavailablePage();
    final provider = directConversationControllerProvider(
      widget.conversationId,
    );
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    _scheduleInitialOrOwnMessageScroll(state);
    return Scaffold(
      appBar: _buildAppBar(context, state, notifier),
      body: switch (state.phase) {
        DirectConversationPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        DirectConversationPhase.failed => _ConversationFailure(
          state: state,
          onRetry: notifier.loadInitial,
        ),
        DirectConversationPhase.ready => _ReadyConversation(
          state: state,
          now: _now,
          scrollController: _scrollController,
          onRefresh: notifier.refresh,
          onLoadOlder: notifier.loadOlder,
          onSend: notifier.send,
          onAbandonFailedDraft: notifier.abandonFailedDraft,
          onAccept: () => _handleRequest(context, notifier, accept: true),
          onDecline: () => _handleRequest(context, notifier, accept: false),
          onRecall: (message) => _recall(context, notifier, message),
          onVerifyEmail: () => _verifyEmail(context, notifier),
        ),
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DirectConversationState state,
    DirectConversationController notifier,
  ) {
    final conversation = state.conversation;
    final canArchive =
        conversation != null &&
        (conversation.status == DirectConversationStatus.accepted ||
            conversation.isOutgoingRequest);
    return AppBar(
      titleSpacing: 0,
      title: conversation == null
          ? const Text('私信')
          : InkWell(
              key: const Key('direct-conversation-open-user'),
              onTap: () => context.pushNamed(
                'user-profile',
                pathParameters: {'userId': conversation.otherUser.id},
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DirectMessageAvatar(user: conversation.otherUser, size: 34),
                  SizedBox(width: context.wenyouTokens.space8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.otherUser.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          _conversationSubtitle(conversation),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        if (canArchive)
          IconButton(
            key: const Key('direct-conversation-archive'),
            onPressed: state.isMutating || state.isRefreshing
                ? null
                : () => _toggleArchive(context, notifier, conversation),
            tooltip: conversation.archivedAt == null ? '归档会话' : '移回会话列表',
            icon: state.action == DirectConversationAction.archiving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    conversation.archivedAt == null
                        ? Icons.archive_outlined
                        : Icons.unarchive_outlined,
                  ),
          ),
      ],
    );
  }

  void _scheduleInitialOrOwnMessageScroll(DirectConversationState state) {
    final last = state.messages.lastOrNull;
    final conversation = state.conversation;
    if (last == null || conversation == null || last.id == _lastMessageId) {
      return;
    }
    final initial = _lastMessageId == null;
    final ownMessage = last.isMine(conversation.otherUser.id);
    _lastMessageId = last.id;
    if (!initial && !ownMessage) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: initial
            ? Duration.zero
            : context.wenyouTokens.feedbackDuration,
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _toggleArchive(
    BuildContext context,
    DirectConversationController notifier,
    DirectConversation conversation,
  ) async {
    final archived = conversation.archivedAt == null;
    final succeeded = await notifier.toggleArchive();
    if (!context.mounted || !succeeded) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(archived ? '会话已归档。' : '会话已移回主列表。')));
  }

  Future<void> _handleRequest(
    BuildContext context,
    DirectConversationController notifier, {
    required bool accept,
  }) async {
    if (!accept) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('拒绝消息请求？'),
          content: const Text('拒绝后首条消息会被删除，对方不能再次主动向你发起请求。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消'),
            ),
            FilledButton(
              key: const Key('direct-conversation-decline-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('确认拒绝'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }
    final succeeded = await notifier.handleRequest(accept: accept);
    if (!context.mounted || !succeeded) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(accept ? '已接受消息请求。' : '已拒绝消息请求。')));
  }

  Future<void> _verifyEmail(
    BuildContext context,
    DirectConversationController notifier,
  ) async {
    final returnTo = '/messages/${widget.conversationId}';
    final verified = await context.pushNamed<bool>(
      'verify-email',
      queryParameters: {'returnTo': returnTo},
    );
    if (verified != true || !context.mounted) return;
    if (ref
            .read(directConversationControllerProvider(widget.conversationId))
            .failedDraft !=
        null) {
      await notifier.retrySend();
    } else {
      await notifier.handleRequest(accept: true);
    }
  }

  Future<void> _recall(
    BuildContext context,
    DirectConversationController notifier,
    DirectMessage message,
  ) async {
    final pending =
        ref
            .read(directConversationControllerProvider(widget.conversationId))
            .conversation
            ?.status ==
        DirectConversationStatus.pending;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('撤回消息？'),
        content: Text(pending ? '撤回首条消息会同时取消这次消息请求。' : '撤回后双方只会看到撤回提示。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('direct-conversation-recall-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认撤回'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final succeeded = await notifier.recall(message.id, now: _now);
    if (!context.mounted || !succeeded) return;
    final canceled = ref
        .read(directConversationControllerProvider(widget.conversationId))
        .conversationCanceled;
    if (canceled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('消息请求已取消。')));
      context.pop();
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('消息已撤回。')));
  }
}

class _ReadyConversation extends StatelessWidget {
  const _ReadyConversation({
    required this.state,
    required this.now,
    required this.scrollController,
    required this.onRefresh,
    required this.onLoadOlder,
    required this.onSend,
    required this.onAbandonFailedDraft,
    required this.onAccept,
    required this.onDecline,
    required this.onRecall,
    required this.onVerifyEmail,
  });

  final DirectConversationState state;
  final DateTime now;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadOlder;
  final Future<bool> Function({
    String? content,
    String? mediaId,
    String? stickerAssetId,
  })
  onSend;
  final VoidCallback onAbandonFailedDraft;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final ValueChanged<DirectMessage> onRecall;
  final VoidCallback onVerifyEmail;

  @override
  Widget build(BuildContext context) {
    final conversation = state.conversation!;
    final tokens = context.wenyouTokens;
    return Column(
      children: [
        if (conversation.isIncomingRequest)
          _IncomingRequestPanel(
            state: state,
            onAccept: onAccept,
            onDecline: onDecline,
          ),
        if (state.transientFailure != null && state.failedDraft == null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space12,
              tokens.space8,
              tokens.space12,
              0,
            ),
            child: WenyouStatusBanner(
              key: const Key('direct-conversation-action-failure'),
              tone: WenyouStatusTone.error,
              message: state.transientFailure!.userMessage,
              detail: state.transientFailure!.requestId == null
                  ? null
                  : '请求 ID：${state.transientFailure!.requestId}',
              action: state.transientFailure!.businessCode == 40107
                  ? TextButton(
                      key: const Key('direct-conversation-verify-email'),
                      onPressed: onVerifyEmail,
                      child: const Text('先验证邮箱'),
                    )
                  : null,
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: _MessageTimeline(
              state: state,
              now: now,
              controller: scrollController,
              onLoadOlder: onLoadOlder,
              onRecall: onRecall,
            ),
          ),
        ),
        if (conversation.canSend)
          DirectMessageComposer(
            disabled:
                state.isMutating &&
                state.action != DirectConversationAction.sending,
            failure: state.failedDraft == null ? null : state.transientFailure,
            failedDraft: state.failedDraft,
            onAbandonFailedDraft: onAbandonFailedDraft,
            onSend: ({content, mediaId, stickerAssetId}) => onSend(
              content: content,
              mediaId: mediaId,
              stickerAssetId: stickerAssetId,
            ),
          )
        else
          _SendingUnavailable(conversation: conversation),
      ],
    );
  }
}

class _IncomingRequestPanel extends StatelessWidget {
  const _IncomingRequestPanel({
    required this.state,
    required this.onAccept,
    required this.onDecline,
  });

  final DirectConversationState state;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Material(
      color: tokens.accentedBackground,
      child: Padding(
        padding: EdgeInsets.all(tokens.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('这是对方发来的消息请求', style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: tokens.space4),
            Text(
              '接受后可继续对话；拒绝会删除首条消息且对方不能再次主动申请。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: tokens.space8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('direct-conversation-decline'),
                    onPressed: state.isMutating ? null : onDecline,
                    child: state.action == DirectConversationAction.declining
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('拒绝'),
                  ),
                ),
                SizedBox(width: tokens.space12),
                Expanded(
                  child: FilledButton(
                    key: const Key('direct-conversation-accept'),
                    onPressed: state.isMutating ? null : onAccept,
                    child: state.action == DirectConversationAction.accepting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('接受'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageTimeline extends StatelessWidget {
  const _MessageTimeline({
    required this.state,
    required this.now,
    required this.controller,
    required this.onLoadOlder,
    required this.onRecall,
  });

  final DirectConversationState state;
  final DateTime now;
  final ScrollController controller;
  final VoidCallback onLoadOlder;
  final ValueChanged<DirectMessage> onRecall;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final conversation = state.conversation!;
    final headerCount = state.hasMore || state.transientFailure != null ? 1 : 0;
    if (state.messages.isEmpty && headerCount == 0) {
      return ListView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(tokens.space24),
        children: const [
          WenyouEmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: '暂无可显示消息',
            message: '会话状态变化后可下拉重新加载。',
          ),
        ],
      );
    }
    return ListView.builder(
      key: const PageStorageKey('direct-message-timeline'),
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        tokens.space12,
        tokens.space12,
        tokens.space12,
        tokens.space24,
      ),
      itemCount: headerCount + state.messages.length,
      itemBuilder: (context, index) {
        if (headerCount == 1 && index == 0) {
          if (state.transientFailure != null && state.hasMore) {
            return Padding(
              padding: EdgeInsets.only(bottom: tokens.space12),
              child: WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: state.transientFailure!.userMessage,
                detail: state.transientFailure!.requestId == null
                    ? null
                    : '请求 ID：${state.transientFailure!.requestId}',
                action: TextButton(
                  key: const Key('direct-conversation-load-older-retry'),
                  onPressed: onLoadOlder,
                  child: const Text('重试加载'),
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: tokens.space12),
            child: Center(
              child: TextButton.icon(
                key: const Key('direct-conversation-load-older'),
                onPressed: state.isLoadingOlder ? null : onLoadOlder,
                icon: state.isLoadingOlder
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.history_rounded),
                label: Text(state.isLoadingOlder ? '正在加载' : '查看更早消息'),
              ),
            ),
          );
        }
        final messageIndex = index - headerCount;
        final message = state.messages[messageIndex];
        final previous = messageIndex == 0
            ? null
            : state.messages[messageIndex - 1];
        final mine = message.isMine(conversation.otherUser.id);
        final canRecall =
            mine &&
            !message.isRecalled &&
            now.difference(message.createdAt.toLocal()) <=
                const Duration(minutes: 10);
        final showTime =
            previous == null ||
            message.createdAt.difference(previous.createdAt) >=
                const Duration(minutes: 5);
        return Padding(
          padding: EdgeInsets.only(bottom: tokens.space12),
          child: Column(
            children: [
              if (showTime) ...[
                Text(
                  _formatMessageTime(message.createdAt, now),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: tokens.space8),
              ],
              DirectMessageBubble(
                key: ValueKey('direct-message-${message.id}'),
                message: message,
                mine: mine,
                hideIncomingRequestImage:
                    conversation.isIncomingRequest && !mine,
                canRecall: canRecall,
                isRecalling:
                    state.action == DirectConversationAction.recalling &&
                    state.actionTargetId == message.id,
                onRecall: () => onRecall(message),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SendingUnavailable extends StatelessWidget {
  const _SendingUnavailable({required this.conversation});

  final DirectConversation conversation;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Material(
      color: tokens.softPanel,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(tokens.space16),
          child: Text(
            _sendingDisabledReason(conversation),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}

class _ConversationFailure extends StatelessWidget {
  const _ConversationFailure({required this.state, required this.onRetry});

  final DirectConversationState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      maxWidth: 600,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: state.failure?.httpStatus == 404
              ? Icons.forum_outlined
              : Icons.cloud_off_outlined,
          title: state.failure?.httpStatus == 404 ? '会话不可访问' : '私聊会话没有加载完成',
          message: state.failure?.userMessage ?? '请稍后重试。',
          detail: state.failure?.requestId == null
              ? null
              : '请求 ID：${state.failure!.requestId}',
          action: OutlinedButton.icon(
            key: const Key('direct-conversation-retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重新加载'),
          ),
        ),
      ),
    );
  }
}

class _DirectConversationUnavailablePage extends StatelessWidget {
  const _DirectConversationUnavailablePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('私信')),
      body: const WenyouPageBody(
        maxWidth: 600,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: Icons.forum_outlined,
            title: '私信功能当前未开放',
            message: '服务端暂未启用此能力，请稍后再试。',
          ),
        ),
      ),
    );
  }
}

String _conversationSubtitle(DirectConversation conversation) {
  if (conversation.isIncomingRequest) return '发来的消息请求';
  if (conversation.isOutgoingRequest) return '等待对方接受';
  if (conversation.isBlocked) return '互动受限';
  if (conversation.otherUser.isDeactivated) return '已注销用户';
  return '私聊';
}

String _sendingDisabledReason(DirectConversation conversation) {
  if (conversation.isIncomingRequest) return '请先接受或拒绝这条消息请求。';
  if (conversation.isOutgoingRequest) return '对方接受消息请求后才能继续发送。';
  if (conversation.isBlocked) return '你们之间存在拉黑关系，历史消息仅供查看。';
  if (conversation.otherUser.isDeactivated) return '该用户已注销，历史消息仅供查看。';
  return switch (conversation.status) {
    DirectConversationStatus.declined => '该消息请求已被拒绝。',
    DirectConversationStatus.canceled => '该消息请求已取消。',
    DirectConversationStatus.unknown => '会话状态暂不受当前版本支持。',
    _ => '当前无法发送消息。',
  };
}

String _formatMessageTime(DateTime createdAt, DateTime now) {
  final local = createdAt.toLocal();
  final today = DateUtils.dateOnly(now);
  final day = DateUtils.dateOnly(local);
  if (day == today) return DateFormat('HH:mm').format(local);
  if (day == today.subtract(const Duration(days: 1))) {
    return '昨天 ${DateFormat('HH:mm').format(local)}';
  }
  if (local.year == now.year) return DateFormat('MM月dd日 HH:mm').format(local);
  return DateFormat('yyyy年MM月dd日 HH:mm').format(local);
}
