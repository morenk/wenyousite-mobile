import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_notice.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_widgets.dart';

class NewDirectConversationPage extends ConsumerStatefulWidget {
  const NewDirectConversationPage({required this.userId, super.key});

  final String userId;

  @override
  ConsumerState<NewDirectConversationPage> createState() =>
      _NewDirectConversationPageState();
}

class _NewDirectConversationPageState
    extends ConsumerState<NewDirectConversationPage> {
  var _scheduledConversationId = '';

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(directMessagesEnabledProvider);
    if (!enabled) return const _NewConversationUnavailablePage();
    final provider = directConversationTargetControllerProvider(widget.userId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    _redirectExisting(state);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('发起私聊')),
      body: switch (state.phase) {
        DirectConversationTargetPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        DirectConversationTargetPhase.failed => _TargetFailure(
          state: state,
          onRetry: notifier.load,
        ),
        DirectConversationTargetPhase.ready => _TargetReady(
          state: state,
          onReturnToUser: () => context.pop(),
          onAbandonFailedDraft: notifier.abandonFailedDraft,
          onSend: ({content, mediaId, stickerAssetId}) => _send(
            context,
            notifier,
            content: content,
            mediaId: mediaId,
            stickerAssetId: stickerAssetId,
          ),
        ),
      },
    );
  }

  void _redirectExisting(DirectConversationTargetState state) {
    final lookup = state.lookup;
    final conversation = lookup?.conversation;
    if (state.phase != DirectConversationTargetPhase.ready ||
        conversation == null ||
        (lookup!.contactState != DirectContactState.accepted &&
            lookup.contactState != DirectContactState.pending) ||
        conversation.id == _scheduledConversationId) {
      return;
    }
    _scheduledConversationId = conversation.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.replaceNamed(
        'direct-conversation',
        pathParameters: {'conversationId': conversation.id},
      );
    });
  }

  Future<bool> _send(
    BuildContext context,
    DirectConversationTargetController notifier, {
    String? content,
    String? mediaId,
    String? stickerAssetId,
  }) async {
    final result = await notifier.start(
      content: content,
      mediaId: mediaId,
      stickerAssetId: stickerAssetId,
    );
    if (!context.mounted || result == null) return false;
    showDirectMessageNotice(
      context,
      result.conversation.status == DirectConversationStatus.accepted
          ? '私聊已建立。'
          : '消息请求已发送。',
    );
    context.replaceNamed(
      'direct-conversation',
      pathParameters: {'conversationId': result.conversation.id},
    );
    return true;
  }
}

class _TargetReady extends StatelessWidget {
  const _TargetReady({
    required this.state,
    required this.onReturnToUser,
    required this.onAbandonFailedDraft,
    required this.onSend,
  });

  final DirectConversationTargetState state;
  final VoidCallback onReturnToUser;
  final VoidCallback onAbandonFailedDraft;
  final Future<bool> Function({
    String? content,
    String? mediaId,
    String? stickerAssetId,
  })
  onSend;

  @override
  Widget build(BuildContext context) {
    final user = state.user!;
    final lookup = state.lookup!;
    final copy = _entryCopy(lookup, user);
    if (!copy.canInitiate) {
      return WenyouPageBody(
        maxWidth: 600,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: WenyouIconIds.statusMessagesDisabled,
            title: copy.title,
            message: copy.description,
            action: OutlinedButton.icon(
              key: const Key('direct-message-new-return-user'),
              onPressed: onReturnToUser,
              icon: const WenyouIcon(WenyouIconIds.navigationBack),
              label: const Text('返回用户主页'),
            ),
          ),
        ),
      );
    }
    final tokens = context.wenyouTokens;
    return Column(
      children: [
        Material(
          color: tokens.panel,
          child: Padding(
            padding: EdgeInsets.all(tokens.space16),
            child: Row(
              children: [
                DirectMessageAvatar(user: user),
                SizedBox(width: tokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '给 ${user.username} 发私聊',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: tokens.space4),
                      if (copy.headerSubtitle != null)
                        Text(
                          copy.headerSubtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.space24),
              child: WenyouConstrainedWidth(
                maxWidth: 520,
                child: WenyouPanel(
                  child: Column(
                    children: [
                      WenyouIcon(
                        WenyouIconIds.statusGreeting,
                        size: 36,
                        color: tokens.brandForeground,
                      ),
                      SizedBox(height: tokens.space12),
                      Text(
                        copy.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: tokens.space8),
                      Text(
                        copy.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        DirectMessageComposer(
          disabled: state.isSending,
          submitLabel: copy.submitLabel!,
          placeholder: '礼貌地介绍一下来意…',
          failure: state.failure,
          failedDraft: state.failedDraft,
          onAbandonFailedDraft: onAbandonFailedDraft,
          onSend: onSend,
        ),
      ],
    );
  }
}

class _TargetFailure extends StatelessWidget {
  const _TargetFailure({required this.state, required this.onRetry});

  final DirectConversationTargetState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      maxWidth: 600,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: state.failure?.httpStatus == 404
              ? WenyouIconIds.statusUserUnavailable
              : WenyouIconIds.statusOffline,
          title: state.failure?.httpStatus == 404 ? '无法向该用户发起私聊' : '联系状态加载失败',
          message: state.failure?.userMessage ?? '请稍后重试。',
          detail: state.failure?.requestId == null
              ? null
              : '问题编号：${state.failure!.requestId}',
          action: OutlinedButton.icon(
            key: const Key('direct-message-new-retry'),
            onPressed: onRetry,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            label: const Text('重新加载'),
          ),
        ),
      ),
    );
  }
}

class _NewConversationUnavailablePage extends StatelessWidget {
  const _NewConversationUnavailablePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发起私聊')),
      body: const WenyouPageBody(
        maxWidth: 600,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: WenyouIconIds.statusMessagesDisabled,
            title: '私聊功能当前未开放',
            message: '私聊暂不可用，请稍后再试。',
          ),
        ),
      ),
    );
  }
}

class _EntryCopy {
  const _EntryCopy.disabled({required this.title, required this.description})
    : canInitiate = false,
      headerSubtitle = null,
      submitLabel = null;

  const _EntryCopy.enabled({
    required this.title,
    required this.description,
    this.headerSubtitle,
    required this.submitLabel,
  }) : canInitiate = true;

  final bool canInitiate;
  final String title;
  final String description;
  final String? headerSubtitle;
  final String? submitLabel;
}

_EntryCopy _entryCopy(DirectConversationLookup lookup, DirectMessageUser user) {
  if (user.isDeactivated) {
    return const _EntryCopy.disabled(
      title: '该用户已注销',
      description: '注销账号不能接收新的私聊。',
    );
  }
  if (!lookup.canInitiate) {
    if (lookup.contactState == DirectContactState.declined) {
      return const _EntryCopy.disabled(
        title: '消息请求已被拒绝',
        description: '对方拒绝了此前的消息请求，你不能再次主动发起私聊。',
      );
    }
    return const _EntryCopy.disabled(
      title: '当前无法发起私聊',
      description: '对方账号不可用，或你们之间的联系已受限。',
    );
  }
  if (lookup.contactState == DirectContactState.declined) {
    return const _EntryCopy.enabled(
      title: '你曾拒绝过对方的消息请求',
      description: '现在由你主动发送消息，会直接建立私聊。',
      headerSubtitle: '由你主动重新建立私聊',
      submitLabel: '建立私聊',
    );
  }
  if (user.isMutualFollow) {
    return const _EntryCopy.enabled(
      title: '你们已互相关注',
      description: '发送后会直接建立私聊，不会作为消息请求。',
      headerSubtitle: '已互相关注',
      submitLabel: '发送',
    );
  }
  return const _EntryCopy.enabled(
    title: '这会先作为消息请求',
    description: '你们尚未互相关注，对方接受前只能发送这一条消息。',
    submitLabel: '发送',
  );
}
