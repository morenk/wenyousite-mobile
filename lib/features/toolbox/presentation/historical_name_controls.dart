import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_row.dart';
import 'package:wenyousite_mobile/features/toolbox/application/historical_name_catalog.dart';
import 'package:wenyousite_mobile/features/toolbox/application/name_generator.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_advanced_options.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_controls.dart';

class HistoricalNameControls extends StatelessWidget {
  const HistoricalNameControls({
    required this.expanded,
    required this.onToggleExpanded,
    required this.profiles,
    required this.profile,
    required this.role,
    required this.familyId,
    required this.sex,
    required this.includePatronymic,
    required this.onEnabledChanged,
    required this.onProfileChanged,
    required this.onRoleChanged,
    required this.onFamilyChanged,
    required this.onPatronymicChanged,
    super.key,
  });
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final List<HistoricalProfile> profiles;
  final HistoricalProfile? profile;
  final HistoricalRole? role;
  final String familyId;
  final NameSex sex;
  final bool includePatronymic;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<String> onProfileChanged;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onFamilyChanged;
  final ValueChanged<bool> onPatronymicChanged;

  @override
  Widget build(BuildContext context) => ToolAdvancedOptions(
    expanded: expanded,
    onToggle: onToggleExpanded,
    summary: !expanded && profile != null && role != null
        ? profile!.activeSummary(role!)
        : null,
    children: [
      WenyouSettingsToggle(
        title: '历史起名',
        toggleKey: const Key('name-history-enabled'),
        value: profile != null,
        onChanged: onEnabledChanged,
      ),
      if (profile != null && role != null) ...[
        ToolSelect(
          key: const Key('name-history-profile'),
          label: '时代与地区',
          stacked: MediaQuery.textScalerOf(context).scale(1) >= 1.5,
          value: profile!.id,
          options: {for (final item in profiles) item.id: item.label},
          onChanged: onProfileChanged,
        ),
        if (profile!.roles.length > 1)
          ToolSelect(
            key: const Key('name-history-role'),
            label: '姓名类型',
            stacked: MediaQuery.textScalerOf(context).scale(1) >= 1.5,
            value: role!.id,
            options: {
              for (final item in profile!.roles) item.id: item.displayLabel,
            },
            onChanged: onRoleChanged,
          ),
        ToolSelect(
          key: const Key('name-history-family'),
          label: role!.id == 'lineage' ? '家族' : '姓氏',
          stacked: MediaQuery.textScalerOf(context).scale(1) >= 1.5,
          value: familyId,
          options: {
            '': '随机',
            for (final item in profile!.familiesFor(role!))
              item.id: item.displayLabel(sex, lineage: role!.id == 'lineage'),
          },
          onChanged: onFamilyChanged,
        ),
        if (profile!.patronymics.isNotEmpty)
          WenyouSettingsToggle(
            title: '包含父称',
            toggleKey: const Key('name-history-patronymic'),
            value: includePatronymic,
            onChanged: onPatronymicChanged,
          ),
      ],
    ],
  );
}
