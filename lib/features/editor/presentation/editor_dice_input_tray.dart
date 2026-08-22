import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_task_tray.dart';

typedef EditorDiceInputErrors = ({
  String? quantity,
  String? sides,
  String? modifier,
});

const noEditorDiceInputErrors = (quantity: null, sides: null, modifier: null);

EditorDiceInputErrors validateEditorDiceInputs({
  required String quantity,
  required String sides,
  required String modifier,
}) {
  final parsedQuantity = int.tryParse(quantity.trim());
  final parsedSides = int.tryParse(sides.trim());
  final trimmedModifier = modifier.trim();
  final parsedModifier = trimmedModifier.isEmpty
      ? 0
      : int.tryParse(trimmedModifier);
  return (
    quantity:
        parsedQuantity == null ||
            parsedQuantity < MarkdownDiceContract.minimumQuantity ||
            parsedQuantity > MarkdownDiceContract.maximumQuantity
        ? '需为 1～100'
        : null,
    sides:
        parsedSides == null ||
            parsedSides < MarkdownDiceContract.minimumSides ||
            parsedSides > MarkdownDiceContract.maximumSides
        ? '需为 2～1000'
        : null,
    modifier:
        parsedModifier == null ||
            parsedModifier.abs() > MarkdownDiceContract.maximumModifierMagnitude
        ? '需为 -10000～10000'
        : null,
  );
}

bool hasEditorDiceInputErrors(EditorDiceInputErrors errors) =>
    errors.quantity != null || errors.sides != null || errors.modifier != null;

String? canonicalDiceNotation({
  required String quantity,
  required String sides,
  required String modifier,
}) {
  final parsedQuantity = int.tryParse(quantity.trim());
  final parsedSides = int.tryParse(sides.trim());
  final trimmedModifier = modifier.trim();
  final parsedModifier = trimmedModifier.isEmpty
      ? 0
      : int.tryParse(trimmedModifier);
  if (parsedQuantity == null || parsedSides == null || parsedModifier == null) {
    return null;
  }
  final modifierSuffix = switch (parsedModifier) {
    > 0 => '+$parsedModifier',
    < 0 => '$parsedModifier',
    _ => '',
  };
  return MarkdownDiceContract.normalizeNotation(
    '${parsedQuantity}d$parsedSides$modifierSuffix',
  );
}

class EditorDiceInputTray extends StatelessWidget {
  const EditorDiceInputTray({
    required this.quantityController,
    required this.sidesController,
    required this.modifierController,
    required this.errors,
    required this.currentCount,
    required this.insertEnabled,
    required this.onBack,
    required this.onConfirm,
    required this.onInputChanged,
    super.key,
  });

  final TextEditingController quantityController;
  final TextEditingController sidesController;
  final TextEditingController modifierController;
  final EditorDiceInputErrors errors;
  final int currentCount;
  final bool insertEnabled;
  final VoidCallback onBack;
  final VoidCallback onConfirm;
  final VoidCallback onInputChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final inputs = Listenable.merge([
      quantityController,
      sidesController,
      modifierController,
    ]);
    final fields = [
      _DiceNumberField(
        key: const Key('editor-dice-quantity'),
        controller: quantityController,
        label: WenyouElementContract.diceQuantityLabel,
        error: errors.quantity,
        autofocus: true,
        maxLength: 3,
        signed: false,
        textInputAction: TextInputAction.next,
        onChanged: onInputChanged,
      ),
      _DiceNumberField(
        key: const Key('editor-dice-sides'),
        controller: sidesController,
        label: WenyouElementContract.diceSidesLabel,
        error: errors.sides,
        maxLength: 4,
        signed: false,
        textInputAction: TextInputAction.next,
        onChanged: onInputChanged,
      ),
      _DiceNumberField(
        key: const Key('editor-dice-modifier'),
        controller: modifierController,
        label: WenyouElementContract.diceModifierLabel,
        error: errors.modifier,
        maxLength: 6,
        signed: true,
        textInputAction: TextInputAction.done,
        onChanged: onInputChanged,
        onSubmitted: onConfirm,
      ),
    ];
    return EditorTaskTray(
      title: WenyouElementContract.diceInsertionTitle,
      onBack: onBack,
      onInsert: onConfirm,
      insertEnabled: insertEnabled,
      insertKey: const Key('editor-dice-insert'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 340 ||
                  MediaQuery.textScalerOf(context).scale(16) >= 21;
              if (stacked) {
                return Column(
                  children: [
                    for (var index = 0; index < fields.length; index++) ...[
                      fields[index],
                      if (index < fields.length - 1)
                        SizedBox(height: tokens.space8),
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < fields.length; index++) ...[
                    Expanded(child: fields[index]),
                    if (index < fields.length - 1)
                      SizedBox(width: tokens.space8),
                  ],
                ],
              );
            },
          ),
          SizedBox(height: tokens.space8),
          ListenableBuilder(
            listenable: inputs,
            builder: (context, _) {
              final selectedSides = int.tryParse(sidesController.text.trim());
              final notation = canonicalDiceNotation(
                quantity: quantityController.text,
                sides: sidesController.text,
                modifier: modifierController.text,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SingleChildScrollView(
                    key: const Key('editor-dice-quick-sides'),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final sides
                            in WenyouElementContract.diceQuickSides) ...[
                          ChoiceChip(
                            key: ValueKey('editor-dice-quick-d$sides'),
                            label: Text('d$sides'),
                            selected: selectedSides == sides,
                            showCheckmark: false,
                            onSelected: (_) {
                              sidesController.text = '$sides';
                              sidesController.selection =
                                  TextSelection.collapsed(
                                    offset: sidesController.text.length,
                                  );
                              onInputChanged();
                            },
                          ),
                          SizedBox(width: tokens.space8),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: tokens.space8),
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          liveRegion: true,
                          label: notation == null
                              ? '骰子预览不可用'
                              : '骰子预览 $notation，待掷',
                          excludeSemantics: true,
                          child: Text(
                            notation == null ? '预览：—' : '预览：$notation = ?',
                            key: const Key('editor-dice-preview'),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: notation == null
                                      ? tokens.mutedText
                                      : tokens.brandForeground,
                                  fontFamily:
                                      WenyouFoundationTypography.utility,
                                  fontFamilyFallback: WenyouFoundationTypography
                                      .chineseFallback,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                        ),
                      ),
                      Text(
                        '当前正文 $currentCount/${MarkdownDiceContract.maximumNodesPerPost}',
                        key: const Key('editor-dice-count'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          if (!insertEnabled) ...[
            SizedBox(height: tokens.space4),
            Semantics(
              liveRegion: true,
              child: Text(
                '当前正文最多可插入 ${MarkdownDiceContract.maximumNodesPerPost} 个骰子，请先删除一个。',
                key: const Key('editor-dice-limit'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiceNumberField extends StatelessWidget {
  const _DiceNumberField({
    required this.controller,
    required this.label,
    required this.error,
    required this.maxLength,
    required this.signed,
    required this.textInputAction,
    required this.onChanged,
    this.autofocus = false,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? error;
  final int maxLength;
  final bool signed;
  final bool autofocus;
  final TextInputAction textInputAction;
  final VoidCallback onChanged;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.numberWithOptions(signed: signed),
      textInputAction: textInputAction,
      inputFormatters: [
        if (signed)
          TextInputFormatter.withFunction((oldValue, newValue) {
            return RegExp(r'^[+-]?\d*$').hasMatch(newValue.text)
                ? newValue
                : oldValue;
          })
        else
          FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        errorText: error,
      ),
      onChanged: (_) => onChanged(),
      onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
    );
  }
}
