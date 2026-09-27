import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

/// 个人区页面在浅色模式使用 Foundation 柔和底色，深色沿用原背景。
Color wenyouPersonalPageBackground(BuildContext context) {
  final tokens = context.wenyouTokens;
  return Theme.of(context).brightness == Brightness.light
      ? tokens.softPanel
      : tokens.background;
}

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

/// 个人设置页的局部分组：分组间留白，组内只使用细线区分相邻设置行。
class WenyouSettingsGroup extends StatelessWidget {
  const WenyouSettingsGroup({required this.children, this.title, super.key});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space16,
              0,
              tokens.space16,
              tokens.space8,
            ),
            child: Semantics(
              header: true,
              child: Text(
                title!,
                style: Theme.of(context).textTheme.wenyouSubsectionTitle,
              ),
            ),
          ),
        ],
        WenyouPanel(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    indent: tokens.space16,
                    endIndent: tokens.space16,
                  ),
                children[index],
              ],
            ],
          ),
        ),
      ],
    );
  }
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
