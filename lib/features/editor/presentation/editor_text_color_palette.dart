import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_selection.dart';

typedef EditorTextColorPreset = ({String label, String rgb});

/// 预设来自已发布 Foundation，最近色由账号存储注入。
class EditorTextColorPalette extends StatelessWidget {
  const EditorTextColorPalette({
    required this.presets,
    required this.recent,
    required this.selection,
    required this.writeEnabled,
    required this.onSelect,
    required this.onCustom,
    super.key,
  });
  final List<EditorTextColorPreset> presets;
  final List<String> recent;
  final EditorTextColorSelection selection;
  final bool writeEnabled;
  final ValueChanged<String?> onSelect;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final enabled = selection.enabled && writeEnabled;
    Widget swatch(String rgb, String label) {
      final selected = !selection.mixed && selection.color == rgb;
      return Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Tooltip(
          message: label,
          child: InkWell(
            key: ValueKey('editor-text-color-$rgb'),
            onTap: enabled ? () => onSelect(rgb) : null,
            child: SizedBox(
              width: tokens.minimumTouchTarget,
              height: tokens.minimumTouchTarget,
              child: Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? tokens.text : tokens.border,
                      width: selected ? 3 : 1,
                    ),
                    color: Color(int.parse('FF${rgb.substring(1)}', radix: 16)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(
              key: const Key('editor-color-default'),
              onPressed: enabled ? () => onSelect(null) : null,
              child: const Text(WenyouEditorTextColorContract.defaultLabel),
            ),
            for (final preset in presets) swatch(preset.rgb, preset.label),
          ],
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final rgb in recent) swatch(rgb, '最近使用 $rgb'),
            TextButton(
              key: const Key('editor-color-custom'),
              onPressed: enabled ? onCustom : null,
              child: const Text(WenyouEditorTextColorContract.customLabel),
            ),
          ],
        ),
      ],
    );
  }
}
