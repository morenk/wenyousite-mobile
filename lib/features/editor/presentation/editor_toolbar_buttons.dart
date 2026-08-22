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
    return IconButton(
      constraints: const BoxConstraints.tightFor(
        width: WenyouEditorContract.minimumActionExtent,
        height: WenyouEditorContract.minimumActionExtent,
      ),
      onPressed: enabled ? () => onPressed() : null,
      isSelected: selected,
      selectedIcon: WenyouIcon(
        icon,
        color: context.wenyouTokens.brandForeground,
      ),
      icon: WenyouIcon(icon),
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
    super.key,
  });

  final String icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints(
        minWidth: WenyouEditorContract.minimumActionExtent,
        minHeight: WenyouEditorContract.minimumActionExtent,
      ),
      tooltip: label,
      isSelected: selected,
      selectedIcon: WenyouIcon(
        icon,
        color: context.wenyouTokens.brandForeground,
      ),
      onPressed: onPressed,
      icon: WenyouIcon(icon),
    );
  }
}
