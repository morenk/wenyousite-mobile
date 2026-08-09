import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

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
  });

  final String title;
  final IconData icon;
  final String headline;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: WenyouPageBody(
        maxWidth: 600,
        bottomPadding: 112,
        child: WenyouPanel(
          child: WenyouEmptyState(icon: icon, title: headline, message: detail),
        ),
      ),
    );
  }
}
