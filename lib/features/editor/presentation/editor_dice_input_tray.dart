import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

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
  return MarkdownDeltaCodec.normalizeDiceNotation(
    '${parsedQuantity}d$parsedSides$modifierSuffix',
  );
}

class EditorDiceInputTray extends StatelessWidget {
  const EditorDiceInputTray({
    required this.quantityController,
    required this.sidesController,
    required this.modifierController,
    required this.error,
    required this.onBack,
    required this.onConfirm,
    required this.onInputChanged,
    super.key,
  });

  final TextEditingController quantityController;
  final TextEditingController sidesController;
  final TextEditingController modifierController;
  final String? error;
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
    return Container(
      padding: EdgeInsets.fromLTRB(
        tokens.space4,
        tokens.space4,
        tokens.space4,
        tokens.space8,
      ),
      decoration: BoxDecoration(
        color: tokens.accentedBackground,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: '返回格式工具',
                onPressed: onBack,
                icon: const WenyouIcon(WenyouIconIds.navigationBack),
              ),
              Expanded(
                child: Text(
                  WenyouElementContract.diceInsertionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton.filled(
                tooltip: '确认插入',
                onPressed: onConfirm,
                icon: const WenyouIcon(WenyouIconIds.actionConfirm),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.space4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DiceNumberField(
                    key: const Key('editor-dice-quantity'),
                    controller: quantityController,
                    label: WenyouElementContract.diceQuantityLabel,
                    autofocus: true,
                    maxLength: 3,
                    signed: false,
                    textInputAction: TextInputAction.next,
                    onChanged: onInputChanged,
                  ),
                ),
                SizedBox(width: tokens.space8),
                Expanded(
                  child: _DiceNumberField(
                    key: const Key('editor-dice-sides'),
                    controller: sidesController,
                    label: WenyouElementContract.diceSidesLabel,
                    maxLength: 4,
                    signed: false,
                    textInputAction: TextInputAction.next,
                    onChanged: onInputChanged,
                  ),
                ),
                SizedBox(width: tokens.space8),
                Expanded(
                  child: _DiceNumberField(
                    key: const Key('editor-dice-modifier'),
                    controller: modifierController,
                    label: WenyouElementContract.diceModifierLabel,
                    maxLength: 6,
                    signed: true,
                    textInputAction: TextInputAction.done,
                    onChanged: onInputChanged,
                    onSubmitted: onConfirm,
                  ),
                ),
              ],
            ),
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
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      key: const Key('editor-dice-quick-sides'),
                      spacing: tokens.space8,
                      runSpacing: tokens.space4,
                      children: [
                        for (final sides
                            in WenyouElementContract.diceQuickSides)
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
                      ],
                    ),
                    SizedBox(height: tokens.space8),
                    Semantics(
                      liveRegion: true,
                      label: notation == null ? '骰子预览不可用' : '骰子预览 $notation，待掷',
                      excludeSemantics: true,
                      child: Text(
                        notation == null ? '预览：—' : '预览：$notation = ?',
                        key: const Key('editor-dice-preview'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: notation == null
                              ? tokens.mutedText
                              : tokens.brandForeground,
                          fontFamily: WenyouFoundationTypography.utility,
                          fontFamilyFallback:
                              WenyouFoundationTypography.chineseFallback,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (error case final message?) ...[
            SizedBox(height: tokens.space4),
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.space4),
                child: Text(
                  message,
                  key: const Key('editor-dice-error'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
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
      decoration: InputDecoration(isDense: true, labelText: label),
      onChanged: (_) => onChanged(),
      onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
    );
  }
}
