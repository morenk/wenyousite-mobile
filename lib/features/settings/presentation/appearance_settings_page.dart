import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/application/appearance_preference.dart';
import 'package:wenyousite_mobile/core/application/data_saver_preference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class AppearanceSettingsPage extends ConsumerWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appearancePreferenceControllerProvider);
    final controller = ref.read(
      appearancePreferenceControllerProvider.notifier,
    );
    final page = Scaffold(
      appBar: AppBar(title: const Text('外观')),
      body: WenyouSettingsBody(
        children: [
          if (state.failureMessage != null)
            WenyouSettingsFailure(
              key: const Key('appearance-failure'),
              message: state.failureMessage!,
              retryKey: const Key('appearance-retry'),
              onRetry: state.isSaving
                  ? null
                  : () => unawaited(controller.retry()),
            ),
          WenyouPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < AppearancePreference.values.length;
                  index++
                ) ...[
                  if (index > 0) const Divider(height: 1),
                  WenyouSelectionTile(
                    key: Key(
                      'appearance-option-${AppearancePreference.values[index].name}',
                    ),
                    label: AppearancePreference.values[index].label,
                    leading: WenyouIcon(
                      AppearancePreference.values[index].icon,
                    ),
                    selected:
                        state.preference == AppearancePreference.values[index],
                    onTap: state.isSaving
                        ? null
                        : () => unawaited(
                            controller.select(
                              AppearancePreference.values[index],
                            ),
                          ),
                  ),
                ],
              ],
            ),
          ),
          const _DataSaverSetting(),
        ],
      ),
    );
    return WenyouSettingsTypography(child: page);
  }
}

class _DataSaverSetting extends ConsumerWidget {
  const _DataSaverSetting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dataSaverPreferenceControllerProvider);
    final controller = ref.read(dataSaverPreferenceControllerProvider.notifier);
    return WenyouPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          WenyouSettingsToggle(
            toggleKey: const Key('cover-data-saver'),
            title: '省流量',
            help: '开启后，帖子列表封面保持静态。',
            value: state.enabled,
            onChanged: state.isSaving
                ? null
                : (value) => unawaited(controller.select(value)),
          ),
          if (state.failureMessage != null)
            WenyouSettingsFailure(
              key: const Key('data-saver-failure'),
              message: state.failureMessage!,
              retryKey: const Key('data-saver-retry'),
              onRetry: state.isSaving
                  ? null
                  : () => unawaited(
                      state.readFailed
                          ? controller.retryRead()
                          : controller.select(state.enabled),
                    ),
            ),
        ],
      ),
    );
  }
}
