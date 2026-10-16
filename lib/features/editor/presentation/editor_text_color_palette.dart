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
    final unavailable = !writeEnabled
        ? '文字颜色暂未开放'
        : !selection.enabled
        ? '先选中文字'
        : null;
    Widget choice(String? rgb, String label) {
      final selected =
          selection.enabled && !selection.mixed && selection.color == rgb;
      return Semantics(
        button: true,
        enabled: enabled,
        selected: selected,
        label: unavailable == null ? label : '$label，$unavailable',
        excludeSemantics: true,
        onTap: enabled ? () => onSelect(rgb) : null,
        child: Tooltip(
          message: unavailable ?? label,
          triggerMode: enabled
              ? TooltipTriggerMode.longPress
              : TooltipTriggerMode.tap,
          child: TextButton(
            key: rgb == null
                ? const Key('editor-color-default')
                : ValueKey('editor-text-color-$rgb'),
            onPressed: enabled ? () => onSelect(rgb) : null,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.square(tokens.minimumTouchTarget),
              maximumSize: Size.square(tokens.minimumTouchTarget),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Opacity(
              opacity: enabled ? 1 : .38,
              child: Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? tokens.text : tokens.border,
                      width: selected ? 2 : 1,
                    ),
                    color: rgb == null
                        ? tokens.panel
                        : Color(int.parse('FF${rgb.substring(1)}', radix: 16)),
                  ),
                  child: rgb == null
                      ? WenyouIcon(
                          WenyouIconIds.editorTextColor,
                          size: 18,
                          color: tokens.text,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      key: const Key('editor-color-row'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: const Key('editor-color-swatches'),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                choice(null, '恢复默认色'),
                for (final preset in presets) choice(preset.rgb, preset.label),
                if (recent.isNotEmpty)
                  SizedBox(
                    width: tokens.space8,
                    height: 20,
                    child: VerticalDivider(width: 1, color: tokens.border),
                  ),
                for (final rgb in recent) choice(rgb, '最近使用 $rgb'),
              ],
            ),
          ),
        ),
        Tooltip(
          message: unavailable ?? WenyouEditorTextColorContract.customLabel,
          triggerMode: enabled
              ? TooltipTriggerMode.longPress
              : TooltipTriggerMode.tap,
          child: TextButton(
            key: const Key('editor-color-custom'),
            style: TextButton.styleFrom(
              minimumSize: Size.square(tokens.minimumTouchTarget),
              padding: EdgeInsets.symmetric(horizontal: tokens.space8),
            ),
            onPressed: enabled ? onCustom : null,
            child: const Text(WenyouEditorTextColorContract.customLabel),
          ),
        ),
      ],
    );
  }
}
