import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

class MobileUpdateActions extends ConsumerWidget {
  const MobileUpdateActions({required this.update, super.key});

  final MobileUpdateInfo update;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(mobileUpdateControllerProvider);
    final action = current.targetBuild == update.targetBuild
        ? current
        : const MobileUpdateActionState();
    final message = mobileUpdateStatusMessage(action);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message != null) ...[
          WenyouStatusBanner(
            message: message,
            tone: action.status == MobileUpdateActionStatus.failed
                ? WenyouStatusTone.error
                : WenyouStatusTone.neutral,
          ),
          SizedBox(height: context.wenyouTokens.space12),
        ],
        if (action.status == MobileUpdateActionStatus.downloading) ...[
          Semantics(
            label: '安装包下载进度 ${((action.progress ?? 0) * 100).round()}%',
            child: LinearProgressIndicator(value: action.progress),
          ),
          SizedBox(height: context.wenyouTokens.space12),
        ],
        WenyouAsyncPrimaryButton(
          key: const Key('mobile-update-start'),
          label: mobileUpdateButtonLabel(update, action),
          loadingLabel: mobileUpdateBusyLabel(action),
          icon: WenyouIconIds.actionDownload,
          isLoading: action.isBusy,
          onPressed: current.isBusy && current.targetBuild != update.targetBuild
              ? null
              : () => ref
                    .read(mobileUpdateControllerProvider.notifier)
                    .start(
                      update,
                      refreshTarget: () => ref.refresh(
                        availableMobileReleaseUpdateProvider.future,
                      ),
                    ),
        ),
      ],
    );
  }
}

String mobileUpdateButtonLabel(
  MobileUpdateInfo update,
  MobileUpdateActionState action,
) {
  if (action.status == MobileUpdateActionStatus.permissionRequired) {
    return '权限已开启，继续安装';
  }
  if (action.status == MobileUpdateActionStatus.failed) return '重新尝试';
  if (update.platform == MobileClientPlatform.android) return '下载并安装';
  return '前往 TestFlight';
}

String mobileUpdateTargetLabel(MobileUpdateInfo update) {
  final version = update.targetVersion;
  return version == null
      ? '构建 ${update.targetBuild}'
      : '$version+${update.targetBuild}';
}

String? mobileUpdateStatusMessage(MobileUpdateActionState action) =>
    switch (action.status) {
      MobileUpdateActionStatus.idle => null,
      MobileUpdateActionStatus.checking => '正在核对安装包发布信息。',
      MobileUpdateActionStatus.downloading => null,
      MobileUpdateActionStatus.verifying => '正在校验安装包完整性。',
      MobileUpdateActionStatus.installing => '安装包已验证，正在打开系统安装器。',
      MobileUpdateActionStatus.openingExternalPage => '正在打开 TestFlight。',
      MobileUpdateActionStatus.permissionRequired =>
        '已打开系统设置。允许温油站“安装未知应用”后，返回此页继续安装。',
      MobileUpdateActionStatus.installerOpened => '系统安装器已打开，请按提示完成更新。',
      MobileUpdateActionStatus.externalPageOpened =>
        'TestFlight 已打开，请在那里完成更新后返回。',
      MobileUpdateActionStatus.failed => action.message ?? '更新失败，请重试。',
    };

String mobileUpdateBusyLabel(MobileUpdateActionState action) =>
    switch (action.status) {
      MobileUpdateActionStatus.checking => '正在检查更新',
      MobileUpdateActionStatus.verifying => '正在校验安装包',
      MobileUpdateActionStatus.installing => '正在打开安装器',
      _ => '正在下载安装包',
    };
