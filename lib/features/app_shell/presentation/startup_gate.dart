import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';

class StartupGate extends ConsumerWidget {
  const StartupGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(startupControllerProvider);
    return switch (state.status) {
      StartupStatus.ready => child,
      StartupStatus.checking => const _CheckingPage(),
      StartupStatus.incompatible => _IncompatiblePage(
        reason: state.reason ?? '服务端契约与当前应用不兼容。',
        contractVersion: state.contract?.contractVersion,
      ),
      StartupStatus.failed => _FailurePage(
        message: state.failure?.userMessage ?? '启动检查失败。',
        requestId: state.failure?.requestId,
        onRetry: ref.read(startupControllerProvider.notifier).check,
      ),
    };
  }
}

class _CheckingPage extends StatelessWidget {
  const _CheckingPage();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Scaffold(
      body: WenyouPageBody(
        maxWidth: 420,
        child: WenyouPanel(
          child: Semantics(
            label: '正在检查服务端兼容性',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: tokens.space16),
                Text('正在连接温油站', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: tokens.space8),
                Text(
                  '正在检查公网服务与客户端兼容性。',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IncompatiblePage extends StatelessWidget {
  const _IncompatiblePage({required this.reason, this.contractVersion});

  final String reason;
  final String? contractVersion;

  @override
  Widget build(BuildContext context) {
    return _MessagePage(
      icon: Icons.system_update_rounded,
      title: '需要升级温油站',
      message: reason,
      detail: contractVersion == null ? null : '服务端契约：$contractVersion',
    );
  }
}

class _FailurePage extends StatelessWidget {
  const _FailurePage({
    required this.message,
    required this.onRetry,
    this.requestId,
  });

  final String message;
  final String? requestId;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessagePage(
      icon: Icons.cloud_off_rounded,
      title: '暂时连不上温油站',
      message: message,
      detail: requestId == null ? null : '请求 ID：$requestId',
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('重试'),
      ),
    );
  }
}

class _MessagePage extends StatelessWidget {
  const _MessagePage({
    required this.icon,
    required this.title,
    required this.message,
    this.detail,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WenyouPageBody(
        maxWidth: 520,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: icon,
            title: title,
            message: message,
            detail: detail,
            action: action,
          ),
        ),
      ),
    );
  }
}
