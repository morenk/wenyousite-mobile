import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';

class HomeBaselinePage extends ConsumerWidget {
  const HomeBaselinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contract = ref.watch(startupControllerProvider).contract;
    return _BaselinePage(
      title: '温油站',
      icon: Icons.wb_sunny_outlined,
      headline: '公网开发环境已连接',
      detail: contract == null
          ? '正在读取契约信息'
          : 'API ${contract.contractVersion} · Markdown v${contract.markdownContractVersion}',
    );
  }
}

class SearchBaselinePage extends StatelessWidget {
  const SearchBaselinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BaselinePage(
      title: '搜索',
      icon: Icons.search_rounded,
      headline: '搜索模块已进入规划',
      detail: '主题、用户和正文将按需加载。',
    );
  }
}

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
          ? null
          : FilledButton.icon(
              onPressed: () => context.push('/auth/login?returnTo=/me'),
              icon: const Icon(Icons.login_rounded),
              label: const Text('登录'),
            ),
    );
  }
}

class ComposeBaselinePage extends StatelessWidget {
  const ComposeBaselinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建主题')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            '创建入口已经固定；编辑器、草稿和图片上传将在对应垂直切片接入。',
            textAlign: TextAlign.center,
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 18),
                  Text(headline, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(detail, style: Theme.of(context).textTheme.bodyMedium),
                  if (action != null) ...[const SizedBox(height: 20), action!],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
