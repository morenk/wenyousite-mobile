import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/application/background_execution.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/application/background_reminder_preference.dart';
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
          SwitchListTile(
            key: const Key('background-reminder-toggle'),
            title: const Text('后台消息提醒'),
            subtitle: const Text('后台常驻提醒，可能增加耗电；划掉应用后停止。'),
            value: preference.enabled,
            onChanged: preference.isSaving
                ? null
                : (enabled) => unawaited(controller.select(enabled)),
          ),
          if (problem != null)
            ListTile(
              title: Text(problem),
              trailing: preference.readFailed
                  ? TextButton(
                      onPressed: preference.isSaving
                          ? null
                          : controller.retryRead,
                      child: const Text('重试'),
                    )
                  : null,
            ),
          if (online.permissionDenied)
            ListTile(
              title: const Text('允许消息通知'),
              subtitle: const Text('也可在系统设置中开启。'),
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
          ListTile(
            key: const Key('background-reminder-system-settings'),
            title: const Text('系统消息通知设置'),
            subtitle: const Text('管理消息弹窗'),
            trailing: const WenyouIcon(WenyouIconIds.navigationNext),
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
