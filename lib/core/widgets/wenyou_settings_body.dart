import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

/// 独立设置页共用内容宽度、滚动、安全区和底部留白。
class WenyouSettingsBody extends StatelessWidget {
  const WenyouSettingsBody({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => WenyouPageBody(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) SizedBox(height: context.wenyouTokens.space12),
          children[index],
        ],
      ],
    ),
  );
}

/// 重试的目标由设置自身决定，呈现与禁用规则保持一致。
class WenyouSettingsFailure extends StatelessWidget {
  const WenyouSettingsFailure({
    required this.message,
    required this.onRetry,
    this.retryKey,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final Key? retryKey;

  @override
  Widget build(BuildContext context) => WenyouStatusBanner(
    message: message,
    tone: WenyouStatusTone.error,
    action: TextButton.icon(
      key: retryKey,
      onPressed: onRetry,
      icon: const WenyouIcon(WenyouIconIds.actionRefresh),
      label: const Text('重试'),
    ),
  );
}
