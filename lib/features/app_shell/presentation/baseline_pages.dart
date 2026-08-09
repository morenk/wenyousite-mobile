import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/auth/application/logout_controller.dart';

class NotificationsBaselinePage extends ConsumerWidget {
  const NotificationsBaselinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    return _BaselinePage(
      title: '通知',
      icon: Icons.notifications_none_rounded,
      headline: session.isAuthenticated ? '通知会话已就绪' : '登录后查看通知',
      detail: 'V1 使用站内 API 拉取，不依赖系统推送。',
    );
  }
}

class ProfileBaselinePage extends ConsumerWidget {
  const ProfileBaselinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final environment = ref.watch(appEnvironmentProvider);
    return _BaselinePage(
      title: '我的',
      icon: Icons.person_outline_rounded,
      headline: session.isAuthenticated ? '已恢复登录会话' : '当前以游客身份浏览',
      detail: environment.apiBaseUrl,
      action: session.isAuthenticated
          ? const _LogoutAction()
          : FilledButton.icon(
              onPressed: () => context.push('/auth/login?returnTo=/me'),
              icon: const Icon(Icons.login_rounded),
              label: const Text('登录'),
            ),
    );
  }
}

class _LogoutAction extends ConsumerWidget {
  const _LogoutAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logout = ref.watch(logoutControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (logout.failure != null) ...[
          WenyouStatusBanner(
            message: logout.failure!.userMessage,
            detail: logout.failure!.requestId == null
                ? null
                : '请求 ID：${logout.failure!.requestId}',
            tone: WenyouStatusTone.error,
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          key: const Key('logout-submit'),
          onPressed: logout.isSubmitting
              ? null
              : () => _confirmAndLogout(context, ref),
          icon: logout.isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout_rounded),
          label: Text(logout.failure == null ? '退出当前账号' : '重试安全退出'),
        ),
        if (logout.failure != null)
          TextButton(
            key: const Key('logout-local-only'),
            onPressed: logout.isSubmitting
                ? null
                : () => _confirmLocalLogout(context, ref),
            child: const Text('仅清除本机登录'),
          ),
      ],
    );
  }

  Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出当前账号？'),
        content: const Text('将撤销当前移动端会话，并清除本机保存的登录信息。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('logout-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认退出'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final succeeded = await ref
        .read(logoutControllerProvider.notifier)
        .submit();
    if (succeeded && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已安全退出当前账号。')));
    }
  }

  Future<void> _confirmLocalLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('仅清除本机登录？'),
        content: const Text('服务器暂未确认撤销此会话。请稍后重新登录并在终端管理中检查。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('返回重试'),
          ),
          FilledButton(
            key: const Key('logout-local-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('清除本机登录'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(logoutControllerProvider.notifier).forceLocalLogout();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('本机登录信息已清除。')));
    }
  }
}

class ComposeBaselinePage extends StatelessWidget {
  const ComposeBaselinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建主题')),
      body: const WenyouPageBody(
        maxWidth: 600,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: Icons.edit_note_rounded,
            title: '创建入口已就绪',
            message: '编辑器、草稿和图片上传将在对应垂直切片接入。',
          ),
        ),
      ),
    );
  }
}

class _BaselinePage extends StatelessWidget {
  const _BaselinePage({
    required this.title,
    required this.icon,
    required this.headline,
    required this.detail,
    this.action,
  });

  final String title;
  final IconData icon;
  final String headline;
  final String detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: WenyouPageBody(
        maxWidth: 600,
        bottomPadding: 112,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: icon,
            title: headline,
            message: detail,
            action: action == null
                ? null
                : SizedBox(width: double.infinity, child: action),
          ),
        ),
      ),
    );
  }
}
