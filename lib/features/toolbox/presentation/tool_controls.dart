import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/toolbox/application/text_transformers.dart';

class ToolSection extends StatelessWidget {
  const ToolSection({required this.children, super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => WenyouPanel(
    padding: EdgeInsets.all(context.wenyouTokens.space16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: context.wenyouTokens.space16),
          children[i],
        ],
      ],
    ),
  );
}

class ToolFields extends StatelessWidget {
  const ToolFields({required this.children, super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final gap = context.wenyouTokens.space12;
      final minimumWidth = MediaQuery.textScalerOf(context).scale(126);
      final columns = (constraints.maxWidth / (minimumWidth + gap))
          .floor()
          .clamp(1, children.length);
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children)
            SizedBox(
              width: (constraints.maxWidth - gap * (columns - 1)) / columns,
              child: child,
            ),
        ],
      );
    },
  );
}

class ToolSelect<T> extends StatelessWidget {
  const ToolSelect({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });
  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    key: ValueKey('$label-$value'),
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    itemHeight: null,
    items: [
      for (final entry in options.entries)
        DropdownMenuItem(
          value: entry.key,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: context.wenyouTokens.minimumTouchTarget,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(entry.value),
            ),
          ),
        ),
    ],
    onChanged: (next) {
      if (next != null) onChanged(next);
    },
  );
}

class ToolNumber extends StatelessWidget {
  const ToolNumber({required this.label, required this.controller, super.key});
  final String label;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(3),
    ],
    decoration: InputDecoration(labelText: label),
  );
}

class ToolTextInput extends StatelessWidget {
  const ToolTextInput({
    required this.controller,
    this.label = '输入文字',
    super.key,
  });
  final TextEditingController controller;
  final String label;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: controller,
    builder: (context, value, _) => TextField(
      key: const Key('tool-input'),
      controller: controller,
      minLines: 3,
      maxLines: 7,
      keyboardType: TextInputType.multiline,
      // 不吞掉超限粘贴；保留输入供用户删改，转换前仍验证 UTF-16 上限。
      decoration: InputDecoration(
        labelText: label,
        errorText: value.text.length > toolTextLimit ? '输入最多 10,000 个字符' : null,
      ),
    ),
  );
}

class ToolActions extends StatelessWidget {
  const ToolActions({
    required this.onGenerate,
    required this.onClear,
    this.label = '生成',
    super.key,
  });
  final VoidCallback onGenerate;
  final VoidCallback onClear;
  final String label;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: context.wenyouTokens.space8,
    runSpacing: context.wenyouTokens.space8,
    children: [
      FilledButton(
        key: const Key('tool-generate'),
        style: FilledButton.styleFrom(
          minimumSize: Size(0, context.wenyouTokens.minimumTouchTarget),
        ),
        onPressed: onGenerate,
        child: Text(label),
      ),
      TextButton(
        style: TextButton.styleFrom(
          minimumSize: Size(0, context.wenyouTokens.minimumTouchTarget),
        ),
        onPressed: onClear,
        child: const Text('清空'),
      ),
    ],
  );
}

class ToolError extends StatelessWidget {
  const ToolError(this.message, {super.key});
  final String? message;
  @override
  Widget build(BuildContext context) => message == null
      ? const SizedBox.shrink()
      : Semantics(
          liveRegion: true,
          child: Text(
            message!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        );
}

Future<void> copyToolText(BuildContext context, String text) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.removeCurrentSnackBar();
      messenger.showWenyouSnackBar(
        '复制成功',
        pacing: WenyouSnackBarPacing.quick,
        tone: WenyouSnackBarTone.success,
      );
    }
  } on PlatformException {
    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.removeCurrentSnackBar();
      messenger.showWenyouSnackBar(
        '复制失败，请长按选择文字',
        tone: WenyouSnackBarTone.error,
      );
    }
  }
}

class ToolResult extends StatelessWidget {
  const ToolResult({
    required this.text,
    this.fixedLayout = false,
    this.fromRight = false,
    super.key,
  });
  final String text;
  final bool fixedLayout;
  final bool fromRight;
  @override
  Widget build(BuildContext context) {
    final content = SelectableText(
      text,
      key: const Key('tool-result-text'),
      style: Theme.of(context).textTheme.wenyouBody.copyWith(
        fontFamily: fixedLayout ? 'monospace' : null,
      ),
    );
    return ToolSection(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            key: const Key('tool-copy'),
            style: TextButton.styleFrom(
              minimumSize: Size(0, context.wenyouTokens.minimumTouchTarget),
            ),
            onPressed: () => copyToolText(context, text),
            child: const Text('复制结果'),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: fixedLayout
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: fromRight,
                    child: content,
                  )
                : content,
          ),
        ),
      ],
    );
  }
}
