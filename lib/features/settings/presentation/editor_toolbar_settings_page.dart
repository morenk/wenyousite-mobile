import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_preference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';
import 'package:wenyousite_mobile/features/settings/presentation/editor_toolbar_arrangement.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';

class EditorToolbarSettingsPage extends ConsumerWidget {
  const EditorToolbarSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorToolbarPreferenceControllerProvider);
    final controller = ref.read(
      editorToolbarPreferenceControllerProvider.notifier,
    );
    return WenyouSettingsTypography(
      child: Scaffold(
        backgroundColor: wenyouPersonalPageBackground(context),
        appBar: AppBar(
          backgroundColor: wenyouPersonalPageBackground(context),
          title: const Text('编辑器工具栏'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                if (state.failureMessage case final message?)
                  WenyouSettingsFailure(
                    message: message,
                    retryKey: const Key('editor-toolbar-layout-retry'),
                    onRetry: state.isSaving
                        ? null
                        : () => unawaited(controller.retry()),
                  ),
                EditorToolbarArrangement(
                  key: const ValueKey('toolbar-resolved-preview-v2'),
                  capabilities: WenyouEditorCapabilities.forAlignment(
                    ref.watch(appCapabilitiesProvider).markdownAlignment,
                  ),
                  stickersEnabled: ref.watch(stickersEnabledProvider),
                  layout: state.layout,
                  enabled: !state.isSaving,
                  onChanged: (layout) => unawaited(controller.select(layout)),
                ),
                Center(
                  child: TextButton(
                    key: const Key('editor-toolbar-layout-reset'),
                    onPressed:
                        state.isSaving ||
                            (state.layout.isDefault && !state.readFailed)
                        ? null
                        : () => unawaited(
                            controller.select(
                              const EditorToolbarLayout.defaults(),
                            ),
                          ),
                    child: const Text('恢复默认'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
