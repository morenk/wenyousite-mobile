import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/toolbox/application/name_generator.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/name_tool_results.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_controls.dart';

class NameToolPanel extends StatefulWidget {
  const NameToolPanel({super.key});
  @override
  State<NameToolPanel> createState() => _NameToolPanelState();
}

class _NameToolPanelState extends State<NameToolPanel> {
  final _generator = LocalNameGenerator();
  final _surname = TextEditingController();
  final _surnameZh = TextEditingController();
  final _count = TextEditingController(text: '10');
  var _country = 'cn';
  var _sex = NameSex.any;
  var _style = NameStyle.common;
  List<GeneratedName> _results = [];
  String? _error;

  @override
  void dispose() {
    _surname.dispose();
    _surnameZh.dispose();
    _count.dispose();
    super.dispose();
  }

  void _generate() {
    try {
      final results = _generator.generate(
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
      ToolSection(
        children: [
          ToolFields(
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
            ],
          ),
          if (_country == 'cn')
            ToolSelect(
              label: '风格',
              value: _style,
              options: const {
                NameStyle.common: '常见姓名',
                NameStyle.classical: '古风',
                NameStyle.fantasy: '幻想',
              },
              onChanged: (value) => setState(() {
                _style = value;
                _resetResults();
              }),
            ),
          TextField(
            key: const Key('name-surname'),
            controller: _surname,
            decoration: const InputDecoration(labelText: '姓氏（选填）'),
            onChanged: (_) => setState(() {
              _surnameZh.clear();
              _resetResults();
            }),
          ),
          if (_generator.needsSurnameZh(_country, _surname.text))
            TextField(
              key: const Key('name-surname-zh'),
              controller: _surnameZh,
              decoration: const InputDecoration(labelText: '姓氏中文写法'),
              onChanged: (_) => setState(_resetResults),
            ),
          if (_country == 'ru' && _surname.text.trim().isNotEmpty)
            const Text('固定姓氏按输入保留，不随性别变形'),
          ToolNumber(label: '数量（1–50）', controller: _count),
          if (_error != null) ToolError(_error),
          ToolActions(
            onGenerate: _generate,
            onClear: () => setState(() {
              _surname.clear();
              _surnameZh.clear();
              _resetResults();
            }),
          ),
        ],
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
