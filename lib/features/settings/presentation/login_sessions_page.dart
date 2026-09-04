import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/settings/application/login_sessions_controller.dart';
import 'package:wenyousite_mobile/features/settings/domain/login_session_models.dart';

class LoginSessionsPage extends ConsumerWidget {
  const LoginSessionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginSessionsControllerProvider);
    final notifier = ref.read(loginSessionsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('登录终端')),
      body: switch (state.phase) {
        LoginSessionsPhase.loading => const WenyouPageBody(
          maxWidth: 600,
          child: WenyouListSkeleton(label: '正在加载登录终端'),
        ),
        LoginSessionsPhase.failed => WenyouPageBody(
          maxWidth: 600,
          child: WenyouPanel(
            child: WenyouEmptyState(
              icon: WenyouIconIds.actionDevices,
              title: '登录终端加载失败',
              message: state.failure?.userMessage ?? '请稍后重试。',
              detail: wenyouFailureDetail(state.failure),
              action: OutlinedButton.icon(
                key: const Key('login-sessions-retry'),
                onPressed: notifier.load,
                icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                label: const Text('重新加载'),
              ),
            ),
          ),
        ),
        LoginSessionsPhase.ready => _ReadyLoginSessions(
          state: state,
          onRefresh: notifier.load,
          onRevoke: (session) => _confirmAndRevoke(context, notifier, session),
          onDismissFailure: notifier.clearActionFailure,
        ),
      },
    );
  }

  Future<void> _confirmAndRevoke(
    BuildContext context,
    LoginSessionsController notifier,
    LoginSessionModel session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出这个登录终端？'),
        content: Text('${_platformLabel(session.platform)}将立即失效，需要重新登录才能继续使用。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('login-session-revoke-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('退出终端'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final succeeded = await notifier.revokeSession(session.id);
    if (!context.mounted || !succeeded) return;
    showWenyouSnackBar(context, '该登录终端已退出。');
  }
}

class _ReadyLoginSessions extends StatelessWidget {
  const _ReadyLoginSessions({
    required this.state,
    required this.onRefresh,
    required this.onRevoke,
    required this.onDismissFailure,
  });

  final LoginSessionsState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function(LoginSessionModel session) onRevoke;
  final VoidCallback onDismissFailure;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = wenyouHorizontalPagePadding(context);
    return RefreshIndicator(
      onRefresh: state.isMutating ? () async {} : onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontal,
          tokens.space16,
          horizontal,
          tokens.space32,
        ),
        children: [
          if (state.actionFailure != null) ...[
            _CenteredContent(
              child: WenyouFailureBanner(
                failure: state.actionFailure!,
                action: TextButton(
                  key: const Key('login-session-error-dismiss'),
                  onPressed: onDismissFailure,
                  child: const Text('知道了'),
                ),
              ),
            ),
          ],
          if (state.actionOutcome != null) ...[
            if (state.actionFailure != null) SizedBox(height: tokens.space12),
            _CenteredContent(
              child: WenyouWriteOutcomeBanner(
                key: const Key('login-session-write-outcome'),
                status: state.actionOutcome!,
                confirmingMessage: '正在确认终端退出状态…',
                indeterminateMessage: '现在无法继续退出终端。请先刷新终端列表查看是否已生效；应用不会自动重复提交。',
                failure: state.actionOutcomeFailure,
                requestId: state.actionRequestId,
                onRefresh: onRefresh,
                refreshKey: const Key('login-session-refresh-result'),
              ),
            ),
          ],
          if (state.actionFailure != null || state.actionOutcome != null)
            SizedBox(height: tokens.space12),
          if (state.sessions.isEmpty)
            const _CenteredContent(
              child: WenyouPanel(
                child: WenyouEmptyState(
                  icon: WenyouIconIds.actionDevices,
                  title: '暂无活跃登录终端',
                  message: '下拉刷新后仍为空时，请重新登录以恢复当前终端。',
                ),
              ),
            )
          else
            for (var index = 0; index < state.sessions.length; index++) ...[
              if (index > 0) SizedBox(height: tokens.space12),
              _CenteredContent(
                child: _LoginSessionCard(
                  session: state.sessions[index],
                  isPending: state.pendingSessionId == state.sessions[index].id,
                  disableAction:
                      state.isMutating &&
                      state.pendingSessionId != state.sessions[index].id,
                  onRevoke: () => onRevoke(state.sessions[index]),
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class _LoginSessionCard extends StatelessWidget {
  const _LoginSessionCard({
    required this.session,
    required this.isPending,
    required this.disableAction,
    required this.onRevoke,
  });

  final LoginSessionModel session;
  final bool isPending;
  final bool disableAction;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final titleStyle = Theme.of(context).textTheme.wenyouRowTitle;
    final detailStyle = Theme.of(
      context,
    ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText);
    return WenyouPanel(
      key: ValueKey('login-session-${session.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WenyouIcon(
                _platformIcon(session.platform),
                color: tokens.mutedText,
              ),
              SizedBox(width: tokens.space12),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: tokens.space8,
                  runSpacing: tokens.space4,
                  children: [
                    Text(_platformLabel(session.platform), style: titleStyle),
                    if (session.isCurrent) const _CurrentSessionPill(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space12),
          _SessionTimeRow(
            label: '登录时间',
            value: _formatTime(session.signedInAt),
            style: detailStyle,
          ),
          SizedBox(height: tokens.space4),
          _SessionTimeRow(
            label: '最近活动',
            value: _formatTime(session.lastActiveAt),
            style: detailStyle,
          ),
          SizedBox(height: tokens.space4),
          _SessionTimeRow(
            label: '有效期至',
            value: _formatTime(session.expiresAt),
            style: detailStyle,
          ),
          if (session.isCurrent) ...[
            SizedBox(height: tokens.space12),
            Text('当前正在使用的终端需通过“退出当前账号”安全退出。', style: detailStyle),
          ] else ...[
            SizedBox(height: tokens.space16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: ValueKey('login-session-revoke-${session.id}'),
                onPressed: isPending || disableAction ? null : onRevoke,
                icon: isPending
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const WenyouIcon(WenyouIconIds.actionLogout),
                label: Text(isPending ? '正在退出' : '退出此终端'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SessionTimeRow extends StatelessWidget {
  const _SessionTimeRow({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text('$label：$value', style: style);
  }
}

class _CurrentSessionPill extends StatelessWidget {
  const _CurrentSessionPill();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space8,
        vertical: tokens.space4,
      ),
      decoration: BoxDecoration(
        color: tokens.brandForeground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '当前终端',
        style: Theme.of(
          context,
        ).textTheme.wenyouCaption.copyWith(color: tokens.brandForeground),
      ),
    );
  }
}

class _CenteredContent extends StatelessWidget {
  const _CenteredContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WenyouConstrainedWidth(child: child);
  }
}

String _platformLabel(LoginSessionPlatform platform) => switch (platform) {
  LoginSessionPlatform.mobile => '手机端登录',
  LoginSessionPlatform.web => '网页端登录',
  LoginSessionPlatform.unknown => '其他终端登录',
};

String _platformIcon(LoginSessionPlatform platform) => switch (platform) {
  LoginSessionPlatform.mobile => WenyouIconIds.securityDeviceMobile,
  LoginSessionPlatform.web => WenyouIconIds.securityDeviceDesktop,
  LoginSessionPlatform.unknown => WenyouIconIds.actionDevices,
};

String _formatTime(DateTime value) {
  return DateFormat('yyyy-MM-dd HH:mm').format(value.toLocal());
}
