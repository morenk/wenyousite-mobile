import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_widgets.dart';

class DirectMessageTimeline extends StatefulWidget {
  const DirectMessageTimeline({
    required this.state,
    required this.now,
    required this.controller,
    required this.onLoadOlder,
    required this.onRecall,
    required this.onRetryMessage,
    required this.onAbandonFailedMessage,
    super.key,
  });

  final DirectConversationState state;
  final DateTime now;
  final ScrollController controller;
  final VoidCallback onLoadOlder;
  final ValueChanged<DirectMessage> onRecall;
  final ValueChanged<String> onRetryMessage;
  final ValueChanged<String> onAbandonFailedMessage;

  @override
  State<DirectMessageTimeline> createState() => _DirectMessageTimelineState();
}

class _DirectMessageTimelineState extends State<DirectMessageTimeline> {
  static const _followThreshold = 96.0;

  var _isNearBottom = true;
  var _unseenIncomingCount = 0;

  DirectConversationState get state => widget.state;
  ScrollController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant DirectMessageTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_handleScroll);
      controller.addListener(_handleScroll);
    }
    _handleTimelineUpdate(oldWidget.state, state);
  }

  @override
  void dispose() {
    controller.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (!controller.hasClients) return;
    final nearBottom = _isAtLatestEdge();
    if (nearBottom == _isNearBottom &&
        (!nearBottom || _unseenIncomingCount == 0)) {
      return;
    }
    setState(() {
      _isNearBottom = nearBottom;
      if (nearBottom) _unseenIncomingCount = 0;
    });
  }

  void _handleTimelineUpdate(
    DirectConversationState previous,
    DirectConversationState current,
  ) {
    final before = previous.messages;
    final after = current.messages;
    if (after.isEmpty || _sameMessageOrder(before, after)) return;
    if (before.isEmpty) {
      _scheduleJumpToBottom();
      return;
    }

    final previousFirstIndex = after.indexWhere(
      (message) => message.id == before.first.id,
    );
    final prepended = previousFirstIndex > 0 && after.last.id == before.last.id;
    if (prepended) {
      return;
    }

    final previousLastIndex = after.indexWhere(
      (message) => message.id == before.last.id,
    );
    if (previousLastIndex < 0) {
      final replacedOptimistic =
          before.last.clientRequestId != null &&
          after.any(
            (message) => message.clientRequestId == before.last.clientRequestId,
          );
      final nearBottomNow = controller.hasClients
          ? _isAtLatestEdge()
          : _isNearBottom;
      if (replacedOptimistic && nearBottomNow) _scheduleJumpToBottom();
      return;
    }
    if (previousLastIndex == after.length - 1) return;
    final appended = after.sublist(previousLastIndex + 1);
    final conversation = current.conversation;
    if (conversation == null) return;
    final hasOwnMessage = appended.any(
      (message) => message.isMine(conversation.otherUser.id),
    );
    final incomingCount = appended
        .where((message) => !message.isMine(conversation.otherUser.id))
        .length;
    final nearBottomNow = controller.hasClients
        ? _isAtLatestEdge()
        : _isNearBottom;
    if (nearBottomNow || hasOwnMessage) {
      _scheduleJumpToBottom();
      return;
    }
    if (incomingCount > 0) {
      setState(() => _unseenIncomingCount += incomingCount);
    }
  }

  bool _sameMessageOrder(
    List<DirectMessage> before,
    List<DirectMessage> after,
  ) {
    if (before.length != after.length) return false;
    for (var index = 0; index < before.length; index += 1) {
      if (before[index].id != after[index].id) return false;
    }
    return true;
  }

  void _scheduleJumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !controller.hasClients) return;
      controller.jumpTo(controller.position.minScrollExtent);
      if (_unseenIncomingCount != 0 || !_isNearBottom) {
        setState(() {
          _unseenIncomingCount = 0;
          _isNearBottom = true;
        });
      }
    });
  }

  void _jumpToBottom() {
    if (!controller.hasClients) return;
    controller.jumpTo(controller.position.minScrollExtent);
  }

  bool _isAtLatestEdge() {
    final position = controller.position;
    return position.pixels - position.minScrollExtent <= _followThreshold;
  }

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
            icon: WenyouIconIds.navigationMessages,
            title: '暂无可显示消息',
            message: '',
          ),
        ],
      );
    }
    return Stack(
      children: [
        ListView.builder(
          key: const PageStorageKey('direct-message-timeline'),
          controller: controller,
          addAutomaticKeepAlives: false,
          reverse: true,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            tokens.space12,
            tokens.space12,
            tokens.space12,
            tokens.space24,
          ),
          itemCount: headerCount + state.messages.length,
          itemBuilder: (context, index) {
            if (index == state.messages.length && headerCount == 1) {
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
                      onPressed: widget.onLoadOlder,
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
                    onPressed: state.isLoadingOlder ? null : widget.onLoadOlder,
                    icon: state.isLoadingOlder
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const WenyouIcon(WenyouIconIds.statusHistory),
                    label: Text(state.isLoadingOlder ? '正在加载' : '查看更早消息'),
                  ),
                ),
              );
            }
            final messageIndex = state.messages.length - index - 1;
            final message = state.messages[messageIndex];
            final previous = messageIndex == 0
                ? null
                : state.messages[messageIndex - 1];
            final next = messageIndex == state.messages.length - 1
                ? null
                : state.messages[messageIndex + 1];
            final mine = message.isMine(conversation.otherUser.id);
            final canRecall =
                mine &&
                message.deliveryState == DirectMessageDeliveryState.sent &&
                !message.isRecalled &&
                widget.now.difference(message.createdAt.toLocal()) <=
                    const Duration(minutes: 10);
            final showTime =
                previous == null ||
                message.createdAt.difference(previous.createdAt) >=
                    const Duration(minutes: 5);
            final groupEnds =
                next == null ||
                next.senderId != message.senderId ||
                next.createdAt.difference(message.createdAt) >=
                    const Duration(minutes: 5);
            return Padding(
              padding: EdgeInsets.only(
                bottom: groupEnds ? tokens.space12 : tokens.space4,
              ),
              child: Column(
                children: [
                  if (showTime) ...[
                    Text(
                      _formatMessageTime(message.createdAt, widget.now),
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
                    isGroupEnd: groupEnds,
                    failure: state.sendFailures[message.id],
                    onRetry:
                        message.deliveryState ==
                            DirectMessageDeliveryState.failed
                        ? () => widget.onRetryMessage(message.id)
                        : null,
                    onAbandon:
                        message.deliveryState ==
                            DirectMessageDeliveryState.failed
                        ? () => widget.onAbandonFailedMessage(message.id)
                        : null,
                    onRecall: () => widget.onRecall(message),
                  ),
                ],
              ),
            );
          },
        ),
        if (_unseenIncomingCount > 0)
          Positioned(
            right: tokens.space12,
            bottom: tokens.space8,
            child: FilledButton.tonalIcon(
              key: const Key('direct-conversation-new-messages'),
              onPressed: _jumpToBottom,
              icon: const WenyouIcon(WenyouIconIds.navigationDown, size: 18),
              label: Text('$_unseenIncomingCount 条新消息'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                elevation: 2,
              ),
            ),
          ),
      ],
    );
  }
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
