import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_row.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/manual_mobile_update_check.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/mobile_update_notice_dialog.dart';

class MobileUpdateSettingsLink extends ConsumerStatefulWidget {
  const MobileUpdateSettingsLink({super.key});

  @override
  ConsumerState<MobileUpdateSettingsLink> createState() =>
      _MobileUpdateSettingsLinkState();
}

class _MobileUpdateSettingsLinkState
    extends ConsumerState<MobileUpdateSettingsLink> {
  bool _checking = false;

  @override
  Widget build(BuildContext context) => WenyouSettingsLink(
    key: const Key('settings-check-update'),
    icon: WenyouIconIds.actionDownload,
    title: '检查更新',
    isBusy: _checking,
    value: _checking ? '检查中' : null,
    onTap: _checking ? null : _check,
  );

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      // 安装器返回后重新读取版本；后续下载安全复核也不能沿用旧身份。
      ref.invalidate(installedAppInfoProvider);
      final result = await ref.refresh(manualMobileUpdateCheckProvider.future);
      if (!mounted) return;
      final update = result.update;
      if (update == null) {
        showWenyouSnackBar(context, '当前已是最新版本 ${result.installed.version}。');
        return;
      }
      setState(() => _checking = false);
      await showDialog<void>(
        context: context,
        builder: (context) => MobileUpdateNoticeDialog(
          title: '发现新版本',
          update: update,
          target:
              update.platform == MobileClientPlatform.android &&
                  update.targetVersion != null
              ? (
                  platform: update.platform,
                  build: update.targetBuild,
                  version: update.targetVersion!,
                )
              : null,
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      showWenyouSnackBar(
        context,
        error is MobileUpdateException ? error.userMessage : '检查更新失败，请稍后重试。',
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }
}
