import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/features/toolbox/application/text_transformers.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_controls.dart';

class TransformToolPanel extends StatefulWidget {
  const TransformToolPanel({required this.tool, super.key});
  final TextTool tool;
  @override
  State<TransformToolPanel> createState() => _TransformToolPanelState();
}

class _TransformToolPanelState extends State<TransformToolPanel> {
  final _input = TextEditingController();
  var _decode = false;
  var _style = FancyStyle.bold;
  String? _result;
  String? _error;
  var _resultRevision = 0;
  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _generate() {
    try {
      final result = widget.tool == TextTool.fancy
          ? fancyText(_input.text, _style)
          : _decode
          ? decodeMorse(_input.text)
          : encodeMorse(_input.text);
      setState(() {
        _result = result;
        _resultRevision++;
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
      WenyouSettingsGroup(
        children: [
          if (widget.tool == TextTool.fancy)
            ToolSelect(
              label: '样式',
              value: _style,
              options: {
                for (final style in FancyStyle.values)
                  style: '${style.label}  ${fancyText('Abc', style)}',
              },
              onChanged: (value) => setState(() {
                _style = value;
                _result = null;
                _error = null;
              }),
            )
          else
            ToolSelect(
              label: '转换方式',
              value: _decode,
              options: const {false: '文字 → 摩斯', true: '摩斯 → 文字'},
              onChanged: (value) => setState(() {
                _decode = value;
                _result = null;
                _error = null;
              }),
            ),
        ],
      ),
      SizedBox(height: context.wenyouTokens.space12),
      ToolTextInput(controller: _input, label: _decode ? '输入摩斯编码' : '输入文字'),
      SizedBox(height: context.wenyouTokens.space12),
      if (_decode) const Text('空格分隔字符，/ 分隔单词'),
      if (_error != null && _input.text.length <= toolTextLimit)
        ToolError(_error),
      ToolActions(
        label: '转换',
        onGenerate: _generate,
        onClear: () => setState(() {
          _input.clear();
          _result = null;
          _error = null;
        }),
      ),
      if (_result != null && _result!.isNotEmpty) ...[
        SizedBox(height: context.wenyouTokens.space12),
        ToolResult(text: _result!, revision: _resultRevision),
      ],
    ],
  );
}
