import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/features/toolbox/application/advanced_name_catalog.dart';
import 'package:wenyousite_mobile/features/toolbox/application/advanced_name_data.g.dart'
    show advancedNameCountries;
import 'package:wenyousite_mobile/features/toolbox/application/advanced_name_generator.dart';
import 'package:wenyousite_mobile/features/toolbox/application/name_generator.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/advanced_name_controls.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/name_tool_results.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_controls.dart';

class NameToolPanel extends StatefulWidget {
  const NameToolPanel({super.key});
  @override
  State<NameToolPanel> createState() => _NameToolPanelState();
}

class _NameToolPanelState extends State<NameToolPanel> {
  final _generator = LocalNameGenerator();
  AdvancedNameGenerator? _advancedGenerator;
  AdvancedNameGenerator get _advanced =>
      _advancedGenerator ??= AdvancedNameGenerator();
  final _surname = TextEditingController();
  final _surnameZh = TextEditingController();
  final _count = TextEditingController(text: '10');
  var _country = 'cn';
  var _sex = NameSex.any;
  var _style = NameStyle.common;
  var _advancedExpanded = false;
  var _advancedMode = 'historical';
  String? _advancedStyleId;
  String? _structureId;
  List<GeneratedName> _results = [];
  var _requestedCount = 0;
  String? _error;

  AdvancedNameStyle? get _advancedStyle => _advancedStyleId == null
      ? null
      : _advanced.catalog.style(_advancedStyleId!);

  void _resetAdvanced() {
    _advancedMode = 'historical';
    _advancedStyleId = null;
    _structureId = null;
  }

  void _toggleAdvanced(bool enabled) {
    _resetAdvanced();
    _advancedExpanded = enabled;
    if (enabled) _setAdvancedMode('historical');
    _resetResults();
  }

  void _setAdvancedMode(String mode) {
    if (!_advancedExpanded ||
        !const ['historical', 'literary'].contains(mode)) {
      return;
    }
    final styles = _advanced.catalog.forCountry(_country, mode);
    if (styles.isEmpty) return;
    _advancedMode = mode;
    _advancedStyleId = styles.first.id;
    _structureId = styles.first.defaultStructureId;
    _resetResults();
  }

  void _setAdvancedStyle(String id) {
    if (!_advancedExpanded) return;
    final style = _advanced.catalog.style(id);
    if (style == null ||
        style.country != _country ||
        style.mode != _advancedMode) {
      return;
    }
    _advancedStyleId = style.id;
    _structureId = style.defaultStructureId;
    _resetResults();
  }

  @override
  void reassemble() {
    super.reassemble();
    // 调试中更新词库或由旧历史页切入时，只丢弃进阶临时状态。
    // 普通姓名参数保持，旧选择浮层回调也不能恢复已收起的条件。
    _advancedGenerator = null;
    _advancedExpanded = false;
    _resetAdvanced();
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
      final count = int.tryParse(_count.text) ?? 0;
      final results = _advancedExpanded
          ? _advanced.generate(
              AdvancedNameOptions(
                country: _country,
                mode: _advancedMode,
                styleId: _advancedStyleId ?? '',
                structureId: _structureId ?? '',
                sex: _sex.name,
                count: count,
              ),
            )
          : _generator.generate(
              NameOptions(
                country: _country,
                sex: _sex,
                style: _style,
                surname: _surname.text,
                surnameZh: _surnameZh.text,
                count: count,
              ),
            );
      setState(() {
        _results = results;
        _requestedCount = count;
        _error = null;
      });
      FocusManager.instance.primaryFocus?.unfocus();
    } on FormatException catch (error) {
      setState(() {
        _error = error.message;
        _results = [];
        _requestedCount = 0;
      });
    }
  }

  void _resetResults() {
    _results = [];
    _requestedCount = 0;
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
              _resetAdvanced();
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
          if (_country == 'cn' && !_advancedExpanded)
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
          if (!_advancedExpanded)
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
          if (!_advancedExpanded &&
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
      if (advancedNameCountries.contains(_country)) ...[
        AdvancedNameControls(
          expanded: _advancedExpanded,
          onToggleExpanded: () =>
              setState(() => _toggleAdvanced(!_advancedExpanded)),
          mode: _advancedMode,
          styleId: _advancedStyleId,
          styles: !_advancedExpanded
              ? const {}
              : {
                  for (final style in _advanced.catalog.forCountry(
                    _country,
                    _advancedMode,
                  ))
                    style.id: style.label,
                },
          structureId: _structureId,
          structures: {
            for (final structure
                in _advancedStyle?.structures ?? <AdvancedNameStructure>[])
              structure.id: structure.label,
          },
          onModeChanged: (value) => setState(() => _setAdvancedMode(value)),
          onStyleChanged: (value) => setState(() => _setAdvancedStyle(value)),
          onStructureChanged: (value) => setState(() {
            if (!_advancedExpanded ||
                _advancedStyle?.structure(value) == null) {
              return;
            }
            _structureId = value;
            _resetResults();
          }),
        ),
        SizedBox(height: context.wenyouTokens.space12),
      ],
      if (!_advancedExpanded &&
          _country == 'ru' &&
          _surname.text.trim().isNotEmpty)
        const Text('固定姓氏按输入保留，不随性别变形'),
      if (_error != null) ToolError(_error),
      ToolActions(
        onGenerate: _generate,
        onClear: () => setState(() {
          if (!_advancedExpanded) {
            _surname.clear();
            _surnameZh.clear();
          }
          _resetResults();
        }),
      ),
      if (_results.isNotEmpty) ...[
        SizedBox(height: context.wenyouTokens.space12),
        NameToolResults(
          names: _results,
          requestedCount: _requestedCount,
          foreign: _country != 'cn',
        ),
      ],
    ],
  );
}
