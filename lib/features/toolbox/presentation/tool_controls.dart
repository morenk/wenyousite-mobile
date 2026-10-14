import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/toolbox/application/text_transformers.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_result_viewport.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_typography.dart';

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
          if (i > 0) SizedBox(height: context.wenyouTokens.space8),
          children[i],
        ],
      ],
    ),
  );
}

class ToolSelect<T> extends StatelessWidget {
  const ToolSelect({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.stacked = false,
    this.spaciousText = false,
    super.key,
  });
  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  final bool stacked;
  final bool spaciousText;
  @override
  Widget build(BuildContext context) {
    Future<void> select() async {
      FocusManager.instance.primaryFocus?.unfocus();
      final next = await showWenyouSheet<T>(
        context: context,
        builder: (context) => Theme(
          data: spaciousText
              ? Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.copyWith(
                    bodyMedium: Theme.of(
                      context,
                    ).textTheme.wenyouCompactBody.copyWith(height: 2),
                  ),
                )
              : Theme.of(context),
          child: ToolTypography(
            child: WenyouSheetBody(
              title: label,
              slivers: [
                SliverList.list(
                  children: [
                    for (final entry in options.entries)
                      WenyouSelectionTile(
                        label: entry.value,
                        selected: entry.key == value,
                        emphasizeSelected: false,
                        onTap: () => Navigator.of(context).pop(entry.key),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      if (context.mounted && next != null) onChanged(next);
    }

    if (!stacked) {
      return WenyouSettingsLink(
        title: label,
        value: options[value],
        onTap: select,
      );
    }
    return ListTile(
      minTileHeight: context.wenyouTokens.minimumTouchTarget,
      title: Padding(
        padding: EdgeInsets.symmetric(vertical: context.wenyouTokens.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: Theme.of(context).textTheme.wenyouRowTitle),
            SizedBox(height: context.wenyouTokens.space4),
            Text(
              options[value] ?? '',
              style: Theme.of(context).textTheme.wenyouCompactBody.copyWith(
                color: context.wenyouTokens.mutedText,
                height: spaciousText ? 2 : null,
              ),
            ),
          ],
        ),
      ),
      trailing: const WenyouIcon(WenyouIconIds.navigationNext),
      onTap: select,
    );
  }
}

class ToolNumber extends StatelessWidget {
  const ToolNumber({
    required this.label,
    required this.controller,
    this.fieldKey,
    this.unit,
    super.key,
  });
  final String label;
  final TextEditingController controller;
  final Key? fieldKey;
  final String? unit;
  @override
  Widget build(BuildContext context) => ToolInlineInput(
    label: label,
    fieldKey: fieldKey,
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(3),
    ],
    unit: unit,
  );
}

class ToolInlineInput extends StatelessWidget {
  const ToolInlineInput({
    required this.label,
    required this.controller,
    this.fieldKey,
    this.hint,
    this.unit,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    super.key,
  });
  final String label;
  final TextEditingController controller;
  final Key? fieldKey;
  final String? hint;
  final String? unit;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.space16),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(label, style: text.wenyouRowTitle)),
            SizedBox(width: tokens.space12),
            Expanded(
              flex: 3,
              child: Semantics(
                label: label,
                child: TextField(
                  key: fieldKey,
                  controller: controller,
                  textAlign: TextAlign.end,
                  style: text.wenyouCompactBody.copyWith(
                    color: tokens.mutedText,
                  ),
                  onChanged: onChanged,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  decoration: InputDecoration(
                    hintText: hint,
                    suffixText: unit == null ? null : ' $unit',
                    suffixStyle: text.wenyouCompactBody.copyWith(
                      color: tokens.mutedText,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: tokens.space12,
                    ),
                    constraints: BoxConstraints(
                      minHeight: tokens.minimumTouchTarget,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    builder: (context, value, _) => Semantics(
      label: label,
      child: TextField(
        key: const Key('tool-input'),
        controller: controller,
        minLines: 3,
        maxLines: 7,
        keyboardType: TextInputType.multiline,
        // 不吞掉超限粘贴；保留输入供用户删改，转换前仍验证 UTF-16 上限。
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: context.wenyouTokens.panel,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              context.wenyouTokens.radiusPanel,
            ),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              context.wenyouTokens.radiusPanel,
            ),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              context.wenyouTokens.radiusPanel,
            ),
            borderSide: BorderSide.none,
          ),
          errorText: value.text.length > toolTextLimit
              ? '输入最多 10,000 个字符'
              : null,
        ),
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
          foregroundColor: context.wenyouTokens.mutedText,
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
    this.revision,
    this.protectCombiningMarks = false,
    super.key,
  });
  final String text;
  final bool fixedLayout;
  final bool fromRight;
  final int? revision;
  final bool protectCombiningMarks;
  @override
  Widget build(BuildContext context) {
    final content = Text(
      text,
      key: const Key('tool-result-text'),
      style: Theme.of(context).textTheme.wenyouBody.copyWith(
        fontFamily: fixedLayout ? 'monospace' : null,
        height: protectCombiningMarks ? 2 : null,
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
        // 选择区域放在滚动视口外，让触屏横向拖动优先交给滚动器。
        SelectionArea(
          child: ToolResultViewport(
            resetToken: revision ?? text,
            horizontal: fixedLayout,
            fromRight: fromRight,
            child: protectCombiningMarks
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: context.wenyouTokens.space8,
                    ),
                    child: content,
                  )
                : content,
          ),
        ),
      ],
    );
  }
}
