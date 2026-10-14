import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_chip.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class ThreadTagSelectorSheet extends StatefulWidget {
  const ThreadTagSelectorSheet({required this.initial, super.key});

  final List<String> initial;

  @override
  State<ThreadTagSelectorSheet> createState() => _ThreadTagSelectorSheetState();
}

class _ThreadTagSelectorSheetState extends State<ThreadTagSelectorSheet> {
  static final _separator = RegExp(r'[\s\u3000]+');
  static final _namePattern = RegExp(r'^[A-Za-z0-9_\u4e00-\u9fff#]+$');
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late final List<String> _tags = [...widget.initial];
  TextEditingValue _lastValue = TextEditingValue.empty;
  bool _writingRemainder = false;
  bool _compositionJustEnded = false;
  int _compositionEndEpoch = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onEditingChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  static bool _composing(TextEditingValue value) =>
      value.composing.isValid && !value.composing.isCollapsed;

  void _onEditingChanged() {
    final previous = _lastValue;
    final current = _controller.value;
    _lastValue = current;
    if (_writingRemainder || _composing(current)) return;
    if (_composing(previous)) {
      // 选词也会清除 composing，不能把这次空格／回车当成添加。
      _compositionJustEnded = true;
      final epoch = ++_compositionEndEpoch;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && epoch == _compositionEndEpoch) {
          _compositionJustEnded = false;
        }
      });
      return;
    }
    if (previous.text == current.text) return;
    _compositionJustEnded = false;
    if (_error != null) setState(() => _error = null);

    var prefix = 0;
    while (prefix < previous.text.length &&
        prefix < current.text.length &&
        previous.text[prefix] == current.text[prefix]) {
      prefix += 1;
    }
    var previousEnd = previous.text.length;
    var currentEnd = current.text.length;
    while (previousEnd > prefix &&
        currentEnd > prefix &&
        previous.text[previousEnd - 1] == current.text[currentEnd - 1]) {
      previousEnd -= 1;
      currentEnd -= 1;
    }
    if (_separator.hasMatch(current.text.substring(prefix, currentEnd))) {
      _confirm(includeTail: false);
    }
  }

  String? _validate(String value) {
    if (value.length > 20) return '标签名称不能超过 20 个字符';
    if (!_namePattern.hasMatch(value)) return '只能使用中英文、数字、下划线和 #';
    if (_tags.contains(value)) return '这个标签已经添加';
    if (_tags.length >= 5) return '最多添加 5 个标签';
    return null;
  }

  bool _confirm({required bool includeTail}) {
    if (_composing(_controller.value) || _compositionJustEnded) return false;
    final editing = _controller.value;
    final text = editing.text;
    var consumed = 0;
    String? error;
    for (final boundary in _separator.allMatches(text)) {
      final name = text.substring(consumed, boundary.start).trim();
      if (name.isNotEmpty) {
        error = _validate(name);
        if (error != null) break;
        _tags.add(name);
      }
      consumed = boundary.end;
    }
    if (error == null && includeTail && consumed < text.length) {
      final name = text.substring(consumed).trim();
      if (name.isNotEmpty) {
        error = _validate(name);
        if (error == null) _tags.add(name);
      }
      if (error == null) consumed = text.length;
    }
    if (consumed > 0) {
      final remainder = text.substring(consumed);
      int offset(int original) =>
          (original - consumed).clamp(0, remainder.length);
      _writingRemainder = true;
      _controller.value = TextEditingValue(
        text: remainder,
        selection: TextSelection(
          baseOffset: offset(editing.selection.baseOffset),
          extentOffset: offset(editing.selection.extentOffset),
        ),
      );
      _writingRemainder = false;
    }
    setState(() => _error = error);
    if (_tags.length < 5 || _controller.text.isNotEmpty) {
      _focusNode.requestFocus();
    }
    return error == null;
  }

  void _finish() {
    if (!_confirm(includeTail: true)) return;
    Navigator.pop<List<String>>(context, List<String>.unmodifiable(_tags));
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        (event.logicalKey != LogicalKeyboardKey.enter &&
            event.logicalKey != LogicalKeyboardKey.numpadEnter) ||
        _composing(_controller.value) ||
        _compositionJustEnded) {
      return KeyEventResult.ignored;
    }
    _confirm(includeTail: true);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        tokens.space16,
        0,
        tokens.space16,
        tokens.space16,
      ),
      child: WenyouConstrainedWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '编辑主题标签',
              style: Theme.of(context).textTheme.wenyouOverlayTitle,
            ),
            SizedBox(height: tokens.space12),
            Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onKeyEvent: _onKeyEvent,
              child: TextField(
                key: const Key('thread-management-tag-input'),
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                enabled: _tags.length < 5 || _controller.text.isNotEmpty,
                minLines: 1,
                maxLines: 3,
                maxLength: 20,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {},
                onSubmitted: (_) => _confirm(includeTail: true),
                decoration: InputDecoration(
                  labelText: '标签名称',
                  hintText: '标签由空格或回车分隔',
                  hintMaxLines: 3,
                  errorText: _error,
                  errorMaxLines: 3,
                ),
              ),
            ),
            SizedBox(height: tokens.space8),
            Text(
              '已选 ${_tags.length}/5',
              style: Theme.of(
                context,
              ).textTheme.wenyouCompactBody.copyWith(color: tokens.mutedText),
            ),
            if (_tags.isNotEmpty) ...[
              SizedBox(height: tokens.space8),
              Wrap(
                spacing: tokens.space8,
                runSpacing: tokens.space8,
                children: [
                  for (final tag in _tags)
                    WenyouTagChip(
                      name: tag,
                      deleteTooltip: '移除 #$tag',
                      onDeleted: () => setState(() => _tags.remove(tag)),
                    ),
                ],
              ),
            ],
            SizedBox(height: tokens.space16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  key: const Key('thread-management-tag-cancel'),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                SizedBox(width: tokens.space8),
                FilledButton(
                  key: const Key('thread-management-tag-done'),
                  onPressed: _finish,
                  child: const Text('完成'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
