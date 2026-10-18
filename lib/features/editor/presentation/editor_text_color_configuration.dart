import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/editor/application/editor_text_color_preferences_ports.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_heading_tray.dart';

/// 只由主题、子帖、楼层和回复入口消费；其他编辑器不开放取色。
final editorTextColorConfigurationProvider =
    Provider<EditorTextColorConfiguration?>((ref) {
      final accountId = ref.watch(sessionScopeProvider).accountId;
      final capabilities = ref.watch(appCapabilitiesProvider);
      if (accountId == null || !capabilities.textColorSupported) return null;
      return EditorTextColorConfiguration(
        presets: [
          for (final id in WenyouEditorTextColorContract.presetOrder)
            (
              label: WenyouEditorTextColorContract.presetLabels[id]!,
              rgb: WenyouEditorTextColorContract.presets[id]!,
            ),
        ],
        maximumRecentColors: WenyouEditorTextColorContract.maximumRecentColors,
        accountId: accountId,
        store: ref.watch(editorTextColorPreferenceStoreProvider),
        writeEnabled: capabilities.textColorWriteEnabled,
      );
    });
