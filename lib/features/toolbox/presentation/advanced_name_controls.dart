import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_advanced_options.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_controls.dart';

class AdvancedNameControls extends StatelessWidget {
  const AdvancedNameControls({
    required this.expanded,
    required this.onToggleExpanded,
    required this.mode,
    required this.styleId,
    required this.styles,
    required this.structureId,
    required this.structures,
    required this.onModeChanged,
    required this.onStyleChanged,
    required this.onStructureChanged,
    super.key,
  });

  final bool expanded;
  final VoidCallback onToggleExpanded;
  final String mode;
  final String? styleId;
  final Map<String, String> styles;
  final String? structureId;
  final Map<String, String> structures;
  final ValueChanged<String> onModeChanged;
  final ValueChanged<String> onStyleChanged;
  final ValueChanged<String> onStructureChanged;

  @override
  Widget build(BuildContext context) => ToolAdvancedOptions(
    expanded: expanded,
    onToggle: onToggleExpanded,
    children: [
      ToolSelect(
        key: const Key('name-advanced-mode'),
        label: '类型',
        stacked: MediaQuery.textScalerOf(context).scale(1) >= 1.5,
        value: mode,
        options: const {'historical': '史实参考', 'literary': '文学创作'},
        onChanged: onModeChanged,
      ),
      if (styleId != null)
        ToolSelect(
          key: const Key('name-advanced-style'),
          label: '风格',
          stacked: MediaQuery.textScalerOf(context).scale(1) >= 1.5,
          value: styleId!,
          options: styles,
          onChanged: onStyleChanged,
        ),
      if (structureId != null && structures.length > 1)
        ToolSelect(
          key: const Key('name-advanced-structure'),
          label: '姓名结构',
          stacked: MediaQuery.textScalerOf(context).scale(1) >= 1.5,
          value: structureId!,
          options: structures,
          onChanged: onStructureChanged,
        ),
    ],
  );
}
