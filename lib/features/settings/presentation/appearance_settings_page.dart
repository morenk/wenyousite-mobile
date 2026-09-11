import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/appearance_preference.dart';
import 'package:wenyousite_mobile/core/application/data_saver_preference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class AppearanceSettingsPage extends ConsumerWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appearancePreferenceControllerProvider);
    final controller = ref.read(
      appearancePreferenceControllerProvider.notifier,
    );
    final tokens = context.wenyouTokens;
    final page = Scaffold(
      appBar: AppBar(title: const Text('外观')),
      body: WenyouPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.failureMessage != null) ...[
              WenyouStatusBanner(
                key: const Key('appearance-failure'),
                message: state.failureMessage!,
                tone: WenyouStatusTone.error,
                action: TextButton.icon(
                  key: const Key('appearance-retry'),
                  onPressed: state.isSaving
                      ? null
                      : () => unawaited(controller.retry()),
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                  label: const Text('重试'),
                ),
              ),
              SizedBox(height: tokens.space12),
            ],
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
                    _AppearanceOption(
                      preference: AppearancePreference.values[index],
                      selected:
                          state.preference ==
                          AppearancePreference.values[index],
                      enabled: !state.isSaving,
                      onSelected: (preference) =>
                          unawaited(controller.select(preference)),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: tokens.space16),
            const _DataSaverSetting(),
          ],
        ),
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
          SwitchListTile(
            key: const Key('cover-data-saver'),
            title: const Text('省流量'),
            subtitle: const Text('开启后，帖子列表封面保持静态'),
            value: state.enabled,
            onChanged: state.isSaving
                ? null
                : (value) => unawaited(controller.select(value)),
          ),
          if (state.failureMessage != null)
            ListTile(
              title: Text(state.failureMessage!),
              trailing: TextButton(
                onPressed: state.isSaving
                    ? null
                    : () => unawaited(
                        state.readFailed
                            ? controller.retryRead()
                            : controller.select(state.enabled),
                      ),
                child: const Text('重试'),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.preference,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final AppearancePreference preference;
  final bool selected;
  final bool enabled;
  final ValueChanged<AppearancePreference> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: ListTile(
        key: Key('appearance-option-${preference.name}'),
        enabled: enabled,
        selected: selected,
        leading: WenyouIcon(preference.icon),
        title: Text(preference.label),
        subtitle: Text(switch (preference) {
          AppearancePreference.system => '随设备外观自动切换',
          AppearancePreference.light => '始终使用亮色外观',
          AppearancePreference.dark => '始终使用深色外观',
        }),
        trailing: selected
            ? const WenyouIcon(WenyouIconIds.actionConfirm)
            : null,
        onTap: enabled ? () => onSelected(preference) : null,
      ),
    );
  }
}
