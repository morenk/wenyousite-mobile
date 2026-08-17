import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/thread_subscription_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';

class ThreadSubscriptionControls extends ConsumerWidget {
  const ThreadSubscriptionControls({
    required this.threadId,
    required this.hasAutomaticUpdates,
    this.viewerUserId,
    this.compact = false,
    super.key,
  });

  final String threadId;
  final bool hasAutomaticUpdates;
  final String? viewerUserId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticated = ref.watch(
      sessionControllerProvider.select((session) => session.isAuthenticated),
    );
    if (!authenticated || hasAutomaticUpdates) return const SizedBox.shrink();

    final target = ThreadSubscriptionTarget(
      threadId: threadId,
      viewerUserId: viewerUserId,
    );
    final provider = threadSubscriptionControllerProvider(target);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final tokens = context.wenyouTokens;

    if (compact) {
      return switch (state.phase) {
        ThreadSubscriptionPhase.loading => const SizedBox.square(
          key: Key('thread-subscription-loading'),
          dimension: 48,
          child: Center(
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        ThreadSubscriptionPhase.failed => IconButton(
          key: const Key('thread-subscription-retry'),
          onPressed: notifier.load,
          tooltip: '订阅状态加载失败，点击重试',
          icon: const WenyouIcon(WenyouIconIds.statusNotificationsOff),
          color: Theme.of(context).colorScheme.error,
        ),
        ThreadSubscriptionPhase.ready => IconButton(
          key: const Key('thread-subscription-menu'),
          onPressed: state.isPending
              ? null
              : () => _showPlayerSheet(
                  context,
                  target,
                  includeThreadToggle: true,
                ),
          tooltip: state.threadSubscription == null ? '管理更新订阅' : '已订阅官方更新，管理订阅',
          icon: WenyouIcon(
            state.threadSubscription == null
                ? WenyouIconIds.statusNotifications
                : WenyouIconIds.statusNotificationsActive,
          ),
          color: state.threadSubscription == null
              ? tokens.mutedText
              : tokens.brandForeground,
        ),
      };
    }

    return Padding(
      padding: EdgeInsets.only(top: tokens.space12),
      child: switch (state.phase) {
        ThreadSubscriptionPhase.loading => const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox.square(
            key: Key('thread-subscription-loading'),
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        ThreadSubscriptionPhase.failed => WenyouStatusBanner(
          tone: WenyouStatusTone.error,
          message: state.failure?.userMessage ?? '订阅状态加载失败。',
          detail: state.failure?.requestId == null
              ? null
              : '问题编号：${state.failure!.requestId}',
          action: TextButton(
            key: const Key('thread-subscription-retry'),
            onPressed: notifier.load,
            child: const Text('重试'),
          ),
        ),
        ThreadSubscriptionPhase.ready => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: tokens.space8,
              runSpacing: tokens.space8,
              children: [
                OutlinedButton.icon(
                  key: const Key('thread-subscription-official'),
                  onPressed: state.isPending
                      ? null
                      : () => _toggleThread(context, notifier),
                  icon: state.pendingType == ThreadSubscriptionType.thread
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : WenyouIcon(
                          state.threadSubscription == null
                              ? WenyouIconIds.statusNotifications
                              : WenyouIconIds.statusNotificationsActive,
                        ),
                  label: Text(
                    state.threadSubscription == null ? '订阅官方更新' : '已订阅官方更新',
                  ),
                ),
                if (state.candidates.isNotEmpty)
                  OutlinedButton.icon(
                    key: const Key('thread-subscription-players'),
                    onPressed: state.isPending
                        ? null
                        : () => _showPlayerSheet(context, target),
                    icon: const WenyouIcon(WenyouIconIds.identityMembers),
                    label: Text(
                      '玩家发言 ${state.userSubscriptionCount}/${state.candidates.length}',
                    ),
                  ),
              ],
            ),
            if (state.actionFailure != null) ...[
              SizedBox(height: tokens.space12),
              _ActionFailure(
                message: state.actionFailure!.userMessage,
                requestId: state.actionFailure!.requestId,
                onDismiss: notifier.clearActionFailure,
              ),
            ],
            if (state.actionOutcome != null) ...[
              SizedBox(height: tokens.space12),
              _ActionOutcome(
                outcome: state.actionOutcome!,
                requestId: state.actionRequestId,
                onRefresh: notifier.load,
              ),
            ],
          ],
        ),
      },
    );
  }

  Future<void> _toggleThread(
    BuildContext context,
    ThreadSubscriptionController notifier,
  ) async {
    final succeeded = await notifier.toggleThread();
    if (!context.mounted || !succeeded) return;
    _showSuccess(context, notifier);
  }

  Future<void> _showPlayerSheet(
    BuildContext context,
    ThreadSubscriptionTarget target, {
    bool includeThreadToggle = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.72,
        child: _PlayerSubscriptionSheet(
          target: target,
          includeThreadToggle: includeThreadToggle,
        ),
      ),
    );
  }
}

class _PlayerSubscriptionSheet extends ConsumerWidget {
  const _PlayerSubscriptionSheet({
    required this.target,
    this.includeThreadToggle = false,
  });

  final ThreadSubscriptionTarget target;
  final bool includeThreadToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = threadSubscriptionControllerProvider(target);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final tokens = context.wenyouTokens;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.space16,
          0,
          tokens.space16,
          tokens.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              includeThreadToggle ? '管理更新订阅' : '订阅玩家发言',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: tokens.space4),
            Text(
              includeThreadToggle
                  ? '选择要接收的官方更新或玩家发言提醒。'
                  : '只列出本帖中已标记的普通玩家；可同时订阅多人。',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
            ),
            if (state.actionFailure != null) ...[
              SizedBox(height: tokens.space12),
              _ActionFailure(
                message: state.actionFailure!.userMessage,
                requestId: state.actionFailure!.requestId,
                onDismiss: notifier.clearActionFailure,
              ),
            ],
            if (state.actionOutcome != null) ...[
              SizedBox(height: tokens.space12),
              _ActionOutcome(
                outcome: state.actionOutcome!,
                requestId: state.actionRequestId,
                onRefresh: notifier.load,
              ),
            ],
            SizedBox(height: tokens.space12),
            if (includeThreadToggle) ...[
              ListTile(
                key: const Key('thread-subscription-official'),
                contentPadding: EdgeInsets.zero,
                leading: WenyouIcon(
                  state.threadSubscription == null
                      ? WenyouIconIds.statusNotifications
                      : WenyouIconIds.statusNotificationsActive,
                ),
                title: const Text('官方更新'),
                subtitle: Text(
                  state.threadSubscription == null ? '尚未订阅' : '已订阅',
                ),
                trailing: state.pendingType == ThreadSubscriptionType.thread
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: state.threadSubscription != null,
                        onChanged: state.isPending
                            ? null
                            : (_) => _toggleThread(context, notifier),
                      ),
                onTap: state.isPending
                    ? null
                    : () => _toggleThread(context, notifier),
              ),
              Divider(height: 1, color: tokens.border),
              SizedBox(height: tokens.space12),
              Text('玩家发言', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: tokens.space4),
            ],
            Expanded(
              child: state.candidates.isEmpty
                  ? Center(
                      child: Text(
                        '暂无可订阅的玩家',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : ListView.separated(
                      itemCount: state.candidates.length,
                      separatorBuilder: (_, _) => Divider(color: tokens.border),
                      itemBuilder: (context, index) {
                        final candidate = state.candidates[index];
                        final subscribed =
                            state.userSubscriptionFor(candidate.userId) != null;
                        final pending =
                            state.pendingType == ThreadSubscriptionType.user &&
                            state.pendingTargetUserId == candidate.userId;
                        return ListTile(
                          key: ValueKey(
                            'thread-subscription-candidate-${candidate.userId}',
                          ),
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: tokens.softPanel,
                            child: Text(
                              candidate.username.isEmpty
                                  ? '?'
                                  : candidate.username.characters.first,
                            ),
                          ),
                          title: Text(candidate.username),
                          subtitle: Text('Lv.${candidate.level}'),
                          trailing: OutlinedButton(
                            key: ValueKey(
                              'thread-subscription-user-${candidate.userId}',
                            ),
                            onPressed: state.isPending
                                ? null
                                : () => _toggleUser(
                                    context,
                                    notifier,
                                    candidate.userId,
                                  ),
                            child: pending
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(subscribed ? '取消订阅' : '订阅发言'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleUser(
    BuildContext context,
    ThreadSubscriptionController notifier,
    String userId,
  ) async {
    final succeeded = await notifier.toggleUser(userId);
    if (!context.mounted || !succeeded) return;
    _showSuccess(context, notifier);
  }

  Future<void> _toggleThread(
    BuildContext context,
    ThreadSubscriptionController notifier,
  ) async {
    final succeeded = await notifier.toggleThread();
    if (!context.mounted || !succeeded) return;
    _showSuccess(context, notifier);
  }
}

class _ActionFailure extends StatelessWidget {
  const _ActionFailure({
    required this.message,
    required this.onDismiss,
    this.requestId,
  });

  final String message;
  final String? requestId;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return WenyouStatusBanner(
      tone: WenyouStatusTone.error,
      message: message,
      detail: requestId == null ? null : '问题编号：$requestId',
      action: TextButton(
        key: const Key('thread-subscription-error-dismiss'),
        onPressed: onDismiss,
        child: const Text('知道了'),
      ),
    );
  }
}

class _ActionOutcome extends StatelessWidget {
  const _ActionOutcome({
    required this.outcome,
    required this.onRefresh,
    this.requestId,
  });

  final WriteOutcomeStatus outcome;
  final String? requestId;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final confirming = outcome == WriteOutcomeStatus.confirming;
    return WenyouWriteOutcomeBanner(
      key: Key(
        confirming
            ? 'thread-subscription-confirming'
            : 'thread-subscription-indeterminate',
      ),
      status: outcome,
      confirmingMessage: '正在确认订阅状态…',
      indeterminateMessage: '订阅结果暂时无法确定，请稍后刷新查看。',
      requestId: requestId,
      onRefresh: onRefresh,
      refreshKey: const Key('thread-subscription-refresh-result'),
    );
  }
}

void _showSuccess(BuildContext context, ThreadSubscriptionController notifier) {
  final message = notifier.takeSuccessMessage();
  if (message == null) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
