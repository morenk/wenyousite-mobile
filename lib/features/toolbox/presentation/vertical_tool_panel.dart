import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/toolbox/application/text_transformers.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_controls.dart';

class VerticalToolPanel extends StatefulWidget {
  const VerticalToolPanel({super.key});
  @override
  State<VerticalToolPanel> createState() => _VerticalToolPanelState();
}

class _VerticalToolPanelState extends State<VerticalToolPanel> {
  final _input = TextEditingController();
  final _width = TextEditingController(text: '10');
  final _height = TextEditingController(text: '20');
  final _gap = TextEditingController(text: '2');
  final _separator = TextEditingController();
  var _direction = ReadingDirection.right;
  var _customSeparator = false;
  String? _result;
  String? _error;
  var _resultDirection = ReadingDirection.right;
  @override
  void dispose() {
    for (final controller in [_input, _width, _height, _gap, _separator]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _generate() {
    try {
      final result = verticalText(
        _input.text,
        VerticalOptions(
          width: int.tryParse(_width.text) ?? 0,
          height: int.tryParse(_height.text) ?? 0,
          gap: _customSeparator ? 0 : int.tryParse(_gap.text) ?? -1,
          direction: _direction,
          separator: _customSeparator ? _separator.text : null,
        ),
      );
      setState(() {
        _result = result;
        _resultDirection = _direction;
        _error = null;
      });
      FocusManager.instance.primaryFocus?.unfocus();
    } on FormatException catch (error) {
      setState(() {
        _error = error.message;
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ToolSection(
        children: [
          ToolTextInput(controller: _input),
          ToolFields(
            children: [
              ToolNumber(label: '页宽（1–100）', controller: _width),
              ToolNumber(label: '页高（1–100）', controller: _height),
            ],
          ),
          ToolSelect(
            label: '阅读顺序',
            value: _direction,
            options: const {
              ReadingDirection.right: '从右向左',
              ReadingDirection.left: '从左向右',
            },
            onChanged: (value) => setState(() => _direction = value),
          ),
          ToolFields(
            children: [
              ToolSelect(
                label: '列间分隔',
                value: _customSeparator,
                options: const {false: '空格', true: '自定义'},
                onChanged: (value) => setState(() => _customSeparator = value),
              ),
              if (_customSeparator)
                TextField(
                  controller: _separator,
                  decoration: const InputDecoration(labelText: '分隔符（最多 20 字）'),
                )
              else
                ToolNumber(label: '空格数（0–10）', controller: _gap),
            ],
          ),
          if (_error != null && _input.text.length <= toolTextLimit)
            ToolError(_error),
          ToolActions(
            onGenerate: _generate,
            onClear: () => setState(() {
              _input.clear();
              _result = null;
              _error = null;
            }),
          ),
        ],
      ),
      if (_result != null && _result!.isNotEmpty) ...[
        SizedBox(height: context.wenyouTokens.space12),
        ToolResult(
          text: _result!,
          fixedLayout: true,
          fromRight: _resultDirection == ReadingDirection.right,
        ),
      ],
    ],
  );
}
