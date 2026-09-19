import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

enum WenyouAsyncButtonVariant { filled, outlined, text }

enum WenyouAsyncButtonTone { normal, destructive }

class WenyouAsyncPrimaryButton extends StatelessWidget {
  const WenyouAsyncPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.loadingLabel,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingLabel;
  final String? icon;

  @override
  Widget build(BuildContext context) => WenyouAsyncButton(
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    loadingLabel: loadingLabel,
    icon: icon,
    expand: true,
  );
}

/// 在途状态由调用方持有；组件阻止再次激活，不接管写入、重试或权限判断。
class WenyouAsyncButton extends StatelessWidget {
  const WenyouAsyncButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.loadingLabel,
    this.icon,
    this.expand = false,
    this.variant = WenyouAsyncButtonVariant.filled,
    this.compact = false,
    this.tone = WenyouAsyncButtonTone.normal,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingLabel;
  final String? icon;
  final bool expand;
  final WenyouAsyncButtonVariant variant;

  /// 工具栏仅收紧横向留白，仍保留最低触控高度与大字号换行。
  final bool compact;
  final WenyouAsyncButtonTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final scheme = Theme.of(context).colorScheme;
    final destructive = tone == WenyouAsyncButtonTone.destructive;
    final toneStyle = destructive
        ? ButtonStyle(
            backgroundColor: variant == WenyouAsyncButtonVariant.filled
                ? WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.disabled)
                        ? null
                        : scheme.error,
                  )
                : null,
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled)
                  ? null
                  : variant == WenyouAsyncButtonVariant.filled
                  ? scheme.onError
                  : scheme.error,
            ),
          )
        : null;
    final style =
        (compact
                ? ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(
                      Size(0, tokens.minimumTouchTarget),
                    ),
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: tokens.space12),
                    ),
                  )
                : const ButtonStyle())
            .merge(toneStyle);
    final child = Semantics(
      liveRegion: isLoading,
      label: isLoading ? (loadingLabel ?? '$label，处理中') : label,
      excludeSemantics: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 保留正常文案的布局尺寸，避免按钮在请求开始时收缩、相邻操作跳动。
          Visibility(
            visible: !isLoading,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  WenyouIcon(icon!, size: compact ? 18 : 20),
                  SizedBox(width: tokens.space8),
                ],
                Flexible(child: Text(label, textAlign: TextAlign.center)),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
    final callback = isLoading ? null : onPressed;
    final button = switch (variant) {
      WenyouAsyncButtonVariant.filled => FilledButton(
        style: style,
        onPressed: callback,
        child: child,
      ),
      WenyouAsyncButtonVariant.outlined => OutlinedButton(
        style: style,
        onPressed: callback,
        child: child,
      ),
      WenyouAsyncButtonVariant.text => TextButton(
        style: style,
        onPressed: callback,
        child: child,
      ),
    };
    return SizedBox(
      width: expand ? double.infinity : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
        child: button,
      ),
    );
  }
}
