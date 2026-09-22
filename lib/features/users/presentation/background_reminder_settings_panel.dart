import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/background_execution.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/application/background_reminder_preference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class BackgroundReminderSettingsPanel extends ConsumerWidget {
  const BackgroundReminderSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execution = ref.watch(backgroundExecutionGatewayProvider);
    if (!execution.isSupported) return const SizedBox.shrink();
    final preference = ref.watch(backgroundReminderPreferenceProvider);
    final controller = ref.read(backgroundReminderPreferenceProvider.notifier);
    final online = ref.watch(backgroundOnlineControllerProvider);
    final problem =
        preference.failureMessage ??
        (preference.enabled
            ? online.failureMessage ??
                  (online.permissionDenied ? '消息通知未开启。' : null)
            : null);
    return WenyouPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          WenyouSettingsToggle(
            toggleKey: const Key('background-reminder-toggle'),
            title: '后台消息提醒',
            help: '后台常驻提醒，可能增加耗电；划掉应用后停止。',
            value: preference.enabled,
            onChanged: preference.isSaving
                ? null
                : (enabled) => unawaited(controller.select(enabled)),
          ),
          if (preference.failureMessage != null)
            WenyouSettingsFailure(
              key: const Key('background-reminder-failure'),
              message: preference.failureMessage!,
              retryKey: const Key('background-reminder-retry'),
              onRetry: preference.isSaving
                  ? null
                  : preference.failedValue != null
                  ? controller.retrySave
                  : controller.retryRead,
            )
          else if (problem != null)
            WenyouStatusBanner(
              message: problem,
              tone: online.failureMessage != null
                  ? WenyouStatusTone.error
                  : WenyouStatusTone.neutral,
            ),
          if (online.permissionDenied)
            ListTile(
              title: const Text('允许消息通知'),
              trailing: TextButton(
                onPressed: online.isLoading
                    ? null
                    : () => unawaited(
                        ref
                            .read(backgroundOnlineControllerProvider.notifier)
                            .requestPermissionFromUser(),
                      ),
                child: const Text('申请权限'),
              ),
            ),
          const Divider(height: 1),
          WenyouSettingsLink(
            key: const Key('background-reminder-system-settings'),
            title: '系统消息通知设置',
            onTap: () => unawaited(_openSettings(context, execution)),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings(
    BuildContext context,
    BackgroundExecutionGateway execution,
  ) async {
    try {
      await execution.openNotificationSettings();
    } on Object {
      if (context.mounted) {
        showWenyouSnackBar(
          context,
          '打开失败，请在手机设置中开启通知。',
          tone: WenyouSnackBarTone.error,
        );
      }
    }
  }
}
