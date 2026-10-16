import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_tool_area.dart';

/// 取色过程只更新此面板；正文事务由应用回调提交。
class EditorRgbPickerTray extends StatefulWidget {
  const EditorRgbPickerTray({
    required this.initialColor,
    required this.onApply,
    required this.onCancel,
    super.key,
  });

  final Color initialColor;
  final ValueChanged<Color> onApply;
  final VoidCallback onCancel;

  @override
  State<EditorRgbPickerTray> createState() => _EditorRgbPickerTrayState();
}

class _EditorRgbPickerTrayState extends State<EditorRgbPickerTray> {
  late HSVColor _hsv;
  late final List<TextEditingController> _channels;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor.withValues(alpha: 1));
    _channels = List.generate(3, (_) => TextEditingController());
    _syncChannels();
  }

  @override
  void dispose() {
    for (final channel in _channels) {
      channel.dispose();
    }
    super.dispose();
  }

  Color get _color => _hsv.toColor().withValues(alpha: 1);

  int? _channelValue(int index) {
    final value = int.tryParse(_channels[index].text);
    return value != null &&
            value >= WenyouEditorTextColorContract.channelMinimum &&
            value <= WenyouEditorTextColorContract.channelMaximum
        ? value
        : null;
  }

  bool get _valid => List.generate(3, _channelValue).every((v) => v != null);

  void _syncChannels() {
    final rgb = _color.toARGB32();
    for (var i = 0; i < 3; i++) {
      final text = '${(rgb >> (16 - i * 8)) & 255}';
      _channels[i].value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _setHsv(HSVColor value) => setState(() {
    _hsv = value;
    _syncChannels();
  });

  void _readChannels() => setState(() {
    if (_valid) {
      _hsv = HSVColor.fromColor(
        Color.fromARGB(
          255,
          _channelValue(0)!,
          _channelValue(1)!,
          _channelValue(2)!,
        ),
      );
    }
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final media = MediaQuery.of(context);
    final available = media.size.height - media.viewInsets.bottom;
    final height = math.min(
      (available * .6).clamp(192.0, 400.0),
      EditorToolArea.heightOf(context) ?? double.infinity,
    );
    return Container(
      key: const Key('editor-rgb-picker'),
      constraints: BoxConstraints(maxHeight: height),
      color: tokens.panel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.space8),
            child: Row(
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text(WenyouEditorTextColorContract.cancelLabel),
                ),
                const Expanded(child: Center(child: Text('自定义颜色'))),
                TextButton(
                  key: const Key('editor-color-apply'),
                  onPressed: _valid ? () => widget.onApply(_color) : null,
                  child: const Text(WenyouEditorTextColorContract.applyLabel),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              key: const Key('editor-color-scroll'),
              padding: EdgeInsets.all(tokens.space8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 128,
                    child: _SaturationValuePlane(
                      value: _hsv,
                      onChanged: _setHsv,
                    ),
                  ),
                  Semantics(
                    label: '色相',
                    child: Slider(
                      key: const Key('editor-color-hue'),
                      min: 0,
                      max: 360,
                      value: _hsv.hue,
                      activeColor: HSVColor.fromAHSV(
                        1,
                        _hsv.hue,
                        1,
                        1,
                      ).toColor(),
                      onChanged: (value) => _setHsv(_hsv.withHue(value)),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: tokens.space4,
                            ),
                            child: TextField(
                              key: Key('editor-color-${['r', 'g', 'b'][i]}'),
                              controller: _channels[i],
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              decoration: InputDecoration(
                                labelText: ['R', 'G', 'B'][i],
                                errorText: _channelValue(i) == null
                                    ? '0–255'
                                    : null,
                              ),
                              onChanged: (_) => _readChannels(),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(tokens.space8),
                    child: Text(
                      '文字预览 Aa',
                      key: const Key('editor-color-preview'),
                      style: Theme.of(
                        context,
                      ).textTheme.wenyouBody.copyWith(color: _color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaturationValuePlane extends StatelessWidget {
  const _SaturationValuePlane({required this.value, required this.onChanged});
  final HSVColor value;
  final ValueChanged<HSVColor> onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      void select(Offset offset) => onChanged(
        value
            .withSaturation((offset.dx / constraints.maxWidth).clamp(0, 1))
            .withValue((1 - offset.dy / constraints.maxHeight).clamp(0, 1)),
      );
      return Semantics(
        label: '饱和度和亮度，可用下方 RGB 输入精确设置',
        child: GestureDetector(
          key: const Key('editor-color-plane'),
          onTapDown: (details) => select(details.localPosition),
          onPanDown: (details) => select(details.localPosition),
          onPanUpdate: (details) => select(details.localPosition),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      HSVColor.fromAHSV(1, value.hue, 1, 1).toColor(),
                    ],
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black],
                  ),
                ),
              ),
              Positioned(
                left: (value.saturation * constraints.maxWidth - 8).clamp(
                  0,
                  constraints.maxWidth - 16,
                ),
                top: ((1 - value.value) * constraints.maxHeight - 8).clamp(
                  0,
                  constraints.maxHeight - 16,
                ),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, blurRadius: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
