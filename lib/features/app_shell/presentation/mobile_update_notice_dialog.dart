import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/mobile_release_content.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/mobile_update_actions.dart';

class MobileUpdateNoticeDialog extends StatelessWidget {
  const MobileUpdateNoticeDialog({
    required this.title,
    this.target,
    this.update,
    this.preloadedRelease,
    this.onVisible,
    this.onClose,
    super.key,
  });

  final String title;
  final MobileReleaseTarget? target;
  final MobileUpdateInfo? update;
  final MobileRelease? preloadedRelease;
  final VoidCallback? onVisible;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final target = this.target;
    final update = this.update;
    if (target == null && update?.platform == MobileClientPlatform.ios) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) onVisible?.call();
      });
    }
    return WenyouNoticeDialog(
      key: const Key('mobile-update-notice'),
      title: title,
      onClose: onClose,
      closeLabel: update == null ? '知道了' : '暂不更新',
      closeKey: const Key('mobile-update-dismiss'),
      primaryAction: update == null
          ? null
          : SizedBox(width: 420, child: MobileUpdateActions(update: update)),
      content: SizedBox(
        width: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (update != null && onClose == null) ...[
              const Text('当前版本已停止支持。更新后即可继续访问温油站。'),
              SizedBox(height: tokens.space12),
            ],
            Text(
              target != null
                  ? '${update == null ? '当前安装版本' : '更新至'} ${target.version}\nAndroid · 构建 ${target.build}'
                  : '更新至${mobileUpdateTargetLabel(update!)}',
              style: Theme.of(context).textTheme.wenyouLabel,
            ),
            if (target != null) ...[
              SizedBox(height: tokens.space16),
              MobileReleaseSection(
                target: target,
                onVisible: onVisible,
                preloadedRelease: preloadedRelease,
              ),
            ],
            if (update != null) MobileUpdateStatus(update: update),
          ],
        ),
      ),
    );
  }
}
