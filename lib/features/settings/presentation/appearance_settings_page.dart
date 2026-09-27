import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
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
      backgroundColor: wenyouPersonalPageBackground(context),
      appBar: AppBar(
        backgroundColor: wenyouPersonalPageBackground(context),
        title: const Text('外观'),
      ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WenyouSettingsGroup(
                title: '显示模式',
                children: [
                  for (final preference in AppearancePreference.values)
                    WenyouSelectionTile(
                      key: Key('appearance-option-${preference.name}'),
                      label: preference.label,
                      leading: WenyouIcon(preference.icon),
                      emphasizeSelected: false,
                      selected: state.preference == preference,
                      onTap: state.isSaving
                          ? null
                          : () => unawaited(controller.select(preference)),
                    ),
                ],
              ),
              SizedBox(height: context.wenyouTokens.cardGap),
              const _DataSaverSetting(),
            ],
          ),
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
    return WenyouSettingsGroup(
      title: '浏览',
      children: [
        WenyouSettingsToggle(
          toggleKey: const Key('cover-data-saver'),
          title: '省流量',
          icon: WenyouIconIds.actionImage,
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
    );
  }
}
