import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class WenyouEditorToolbarButton extends StatelessWidget {
  const WenyouEditorToolbarButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.selected = false,
    super.key,
  });

  final String icon;
  final String label;
  final bool enabled;
  final bool selected;
  final FutureOr<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return IconButton(
      constraints: const BoxConstraints.tightFor(
        width: WenyouEditorContract.minimumActionExtent,
        height: WenyouEditorContract.minimumActionExtent,
      ),
      onPressed: enabled ? () => onPressed() : null,
      isSelected: selected,
      style: _editorIconButtonStyle(tokens, selected: selected),
      selectedIcon: WenyouIcon(icon, color: tokens.onActionSurface),
      icon: WenyouIcon(icon, color: tokens.text),
      tooltip: label,
    );
  }
}

class WenyouEditorSubmitButton extends StatelessWidget {
  const WenyouEditorSubmitButton({
    required this.enabled,
    required this.loading,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final bool enabled;
  final bool loading;
  final String label;
  final FutureOr<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return WenyouComposerSubmitButton(
      key: const Key('editor-submit'),
      enabled: enabled,
      loading: loading,
      label: label,
      onPressed: () => onPressed(),
    );
  }
}

class WenyouEditorTrayButton extends StatelessWidget {
  const WenyouEditorTrayButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.enabled = true,
    super.key,
  });

  final String icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return IconButton(
      constraints: const BoxConstraints(
        minWidth: WenyouEditorContract.minimumActionExtent,
        minHeight: WenyouEditorContract.minimumActionExtent,
      ),
      tooltip: label,
      isSelected: selected,
      style: _editorIconButtonStyle(tokens, selected: selected),
      selectedIcon: WenyouIcon(icon, color: tokens.onActionSurface),
      onPressed: enabled ? onPressed : null,
      icon: WenyouIcon(icon, color: tokens.text),
    );
  }
}

ButtonStyle wenyouEditorSegmentedButtonStyle(BuildContext context) {
  final tokens = context.wenyouTokens;
  return ButtonStyle(
    minimumSize: WidgetStatePropertyAll(
      Size.square(WenyouEditorContract.minimumActionExtent),
    ),
    padding: const WidgetStatePropertyAll(EdgeInsets.zero),
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? tokens.actionSurface
          : tokens.panel,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? tokens.mutedText
          : states.contains(WidgetState.selected)
          ? tokens.onActionSurface
          : tokens.text,
    ),
    side: WidgetStateProperty.resolveWith(
      (states) => BorderSide(
        color: states.contains(WidgetState.selected)
            ? tokens.actionSurface
            : tokens.border,
      ),
    ),
  );
}

ButtonStyle _editorIconButtonStyle(
  WenyouThemeTokens tokens, {
  required bool selected,
}) {
  return ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(
      selected ? tokens.actionSurface : Colors.transparent,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? tokens.mutedText
          : selected
          ? tokens.onActionSurface
          : tokens.text,
    ),
  );
}
