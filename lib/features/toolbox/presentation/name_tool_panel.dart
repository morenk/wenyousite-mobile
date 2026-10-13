import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/features/toolbox/application/historical_name_catalog.dart';
import 'package:wenyousite_mobile/features/toolbox/application/historical_name_data.g.dart'
    show historicalNameCountries;
import 'package:wenyousite_mobile/features/toolbox/application/historical_name_generator.dart';
import 'package:wenyousite_mobile/features/toolbox/application/name_generator.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/historical_name_controls.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/name_tool_results.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_controls.dart';

class NameToolPanel extends StatefulWidget {
  const NameToolPanel({super.key});
  @override
  State<NameToolPanel> createState() => _NameToolPanelState();
}

class _NameToolPanelState extends State<NameToolPanel> {
  final _generator = LocalNameGenerator();
  HistoricalNameGenerator? _historicalGenerator;
  HistoricalNameGenerator get _historical =>
      _historicalGenerator ??= HistoricalNameGenerator();
  final _surname = TextEditingController();
  final _surnameZh = TextEditingController();
  final _count = TextEditingController(text: '10');
  var _country = 'cn';
  var _sex = NameSex.any;
  var _style = NameStyle.common;
  var _advancedExpanded = false;
  String? _profileId;
  var _historicalRole = 'period';
  var _familyId = '';
  var _includePatronymic = false;
  List<GeneratedName> _results = [];
  String? _error;

  HistoricalProfile? get _profile =>
      _profileId == null ? null : _historical.catalog.profile(_profileId!);

  void _resetHistorical() {
    _profileId = null;
    _historicalRole = 'period';
    _familyId = '';
    _includePatronymic = false;
  }

  void _changeHistorical(bool enabled) {
    _resetHistorical();
    _style = NameStyle.common;
    _surname.clear();
    _surnameZh.clear();
    if (enabled) {
      _profileId = _historical.catalog.forCountry(_country).first.id;
    }
    _resetResults();
  }

  @override
  void dispose() {
    _surname.dispose();
    _surnameZh.dispose();
    _count.dispose();
    super.dispose();
  }

  void _generate() {
    try {
      final results = _profileId != null
          ? _historical.generate(
              HistoricalNameOptions(
                country: _country,
                profileId: _profileId!,
                role: _historicalRole,
                familyId: _familyId,
                sex: _sex.name,
                count: int.tryParse(_count.text) ?? 0,
                includePatronymic: _includePatronymic,
              ),
            )
          : _generator.generate(
              NameOptions(
                country: _country,
                sex: _sex,
                style: _style,
                surname: _surname.text,
                surnameZh: _surnameZh.text,
                count: int.tryParse(_count.text) ?? 0,
              ),
            );
      setState(() {
        _results = results;
        _error = null;
      });
      FocusManager.instance.primaryFocus?.unfocus();
    } on FormatException catch (error) {
      setState(() {
        _error = error.message;
        _results = [];
      });
    }
  }

  void _resetResults() {
    _results = [];
    _error = null;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      WenyouSettingsGroup(
        children: [
          ToolSelect(
            label: '国家',
            value: _country,
            options: nameCountries,
            onChanged: (value) => setState(() {
              _country = value;
              _style = NameStyle.common;
              _surname.clear();
              _surnameZh.clear();
              _resetHistorical();
              _advancedExpanded = false;
              _resetResults();
            }),
          ),
          ToolSelect(
            label: '性别',
            value: _sex,
            options: const {
              NameSex.any: '不限',
              NameSex.female: '女',
              NameSex.male: '男',
            },
            onChanged: (value) => setState(() {
              _sex = value;
              _resetResults();
            }),
          ),
          if (_country == 'cn' && _profileId == null)
            ToolSelect(
              label: '风格',
              value: _style,
              options: const {
                NameStyle.common: '常见',
                NameStyle.classical: '古风',
                NameStyle.fantasy: '幻想',
              },
              onChanged: (value) => setState(() {
                _style = value;
                _resetResults();
              }),
            ),
          if (_profileId == null)
            ToolInlineInput(
              fieldKey: const Key('name-surname'),
              controller: _surname,
              label: '姓氏',
              hint: '选填',
              onChanged: (_) => setState(() {
                _surnameZh.clear();
                _resetResults();
              }),
            ),
          if (_profileId == null &&
              _generator.needsSurnameZh(_country, _surname.text))
            ToolInlineInput(
              fieldKey: const Key('name-surname-zh'),
              controller: _surnameZh,
              label: '中文姓氏',
              onChanged: (_) => setState(_resetResults),
            ),
          ToolNumber(
            label: '数量',
            controller: _count,
            fieldKey: const Key('name-count'),
          ),
        ],
      ),
      SizedBox(height: context.wenyouTokens.space12),
      if (historicalNameCountries.contains(_country)) ...[
        HistoricalNameControls(
          expanded: _advancedExpanded,
          onToggleExpanded: () =>
              setState(() => _advancedExpanded = !_advancedExpanded),
          profiles: _profileId == null
              ? const []
              : _historical.catalog.forCountry(_country),
          profile: _profile,
          role: _profile?.role(_historicalRole),
          familyId: _familyId,
          sex: _sex,
          includePatronymic: _includePatronymic,
          onEnabledChanged: (value) => setState(() => _changeHistorical(value)),
          onProfileChanged: (value) => setState(() {
            _profileId = value;
            _historicalRole = 'period';
            _familyId = '';
            _includePatronymic = false;
            _resetResults();
          }),
          onRoleChanged: (value) => setState(() {
            _historicalRole = value;
            _familyId = '';
            _includePatronymic = false;
            _resetResults();
          }),
          onFamilyChanged: (value) => setState(() {
            _familyId = value;
            _resetResults();
          }),
          onPatronymicChanged: (value) => setState(() {
            _includePatronymic = value;
            _resetResults();
          }),
        ),
        SizedBox(height: context.wenyouTokens.space12),
      ],
      if (_profileId == null &&
          _country == 'ru' &&
          _surname.text.trim().isNotEmpty)
        const Text('固定姓氏按输入保留，不随性别变形'),
      if (_error != null) ToolError(_error),
      ToolActions(
        onGenerate: _generate,
        onClear: () => setState(() {
          _surname.clear();
          _surnameZh.clear();
          _familyId = '';
          _resetResults();
        }),
      ),
      if (_results.isNotEmpty) ...[
        SizedBox(height: context.wenyouTokens.space12),
        NameToolResults(
          names: _results,
          requestedCount: int.tryParse(_count.text) ?? 0,
          foreign: _country != 'cn',
        ),
      ],
    ],
  );
}
