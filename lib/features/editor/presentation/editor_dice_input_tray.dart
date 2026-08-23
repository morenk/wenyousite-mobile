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

class EditorDiceInputTray extends StatefulWidget {
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
  State<EditorDiceInputTray> createState() => _EditorDiceInputTrayState();
}

class _EditorDiceInputTrayState extends State<EditorDiceInputTray> {
  late final FocusNode _quantityFocusNode;
  late final FocusNode _sidesFocusNode;
  late final FocusNode _modifierFocusNode;
  late final Listenable _inputs;

  @override
  void initState() {
    super.initState();
    _quantityFocusNode = FocusNode(debugLabel: 'dice quantity');
    _sidesFocusNode = FocusNode(debugLabel: 'dice sides');
    _modifierFocusNode = FocusNode(debugLabel: 'dice modifier');
    _inputs = Listenable.merge([
      widget.quantityController,
      widget.sidesController,
      widget.modifierController,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final text = widget.quantityController.text;
      widget.quantityController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: text.length,
      );
      _quantityFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _quantityFocusNode.dispose();
    _sidesFocusNode.dispose();
    _modifierFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final quantityField = _DiceNumberField(
      key: const Key('editor-dice-quantity'),
      controller: widget.quantityController,
      focusNode: _quantityFocusNode,
      label: WenyouElementContract.diceQuantityLabel,
      error: widget.errors.quantity,
      autofocus: true,
      maxLength: 3,
      signed: false,
      textInputAction: TextInputAction.next,
      onChanged: widget.onInputChanged,
      onSubmitted: _sidesFocusNode.requestFocus,
    );
    final sidesField = _DiceNumberField(
      key: const Key('editor-dice-sides'),
      controller: widget.sidesController,
      focusNode: _sidesFocusNode,
      label: WenyouElementContract.diceSidesLabel,
      error: widget.errors.sides,
      maxLength: 4,
      signed: false,
      textInputAction: TextInputAction.next,
      onChanged: widget.onInputChanged,
      onSubmitted: _modifierFocusNode.requestFocus,
      suffix: _DiceQuickSidesMenu(
        controller: widget.sidesController,
        focusNode: _sidesFocusNode,
        onChanged: widget.onInputChanged,
      ),
    );
    final modifierField = _DiceNumberField(
      key: const Key('editor-dice-modifier'),
      controller: widget.modifierController,
      focusNode: _modifierFocusNode,
      label: WenyouElementContract.diceModifierLabel,
      error: widget.errors.modifier,
      maxLength: 6,
      signed: true,
      textInputAction: TextInputAction.done,
      onChanged: widget.onInputChanged,
      onSubmitted: widget.onConfirm,
    );
    return ListenableBuilder(
      listenable: _inputs,
      builder: (context, _) => EditorTaskTray(
        title: WenyouElementContract.diceInsertionTitle,
        headerSupport: _buildHeaderSupport(context),
        onBack: widget.onBack,
        onInsert: widget.onConfirm,
        insertEnabled: widget.insertEnabled,
        insertKey: const Key('editor-dice-insert'),
        showInsertIcon: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useTwoRows =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(16) >= 24;
            if (useTwoRows) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: quantityField),
                      _diceSeparator(context),
                      Expanded(child: sidesField),
                    ],
                  ),
                  SizedBox(height: tokens.space8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: constraints.maxWidth * .55,
                      child: modifierField,
                    ),
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 8, child: quantityField),
                _diceSeparator(context),
                Expanded(flex: 11, child: sidesField),
                SizedBox(width: tokens.space8),
                Expanded(flex: 10, child: modifierField),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSupport(BuildContext context) {
    final tokens = context.wenyouTokens;
    final maximum = MarkdownDiceContract.maximumNodesPerPost;
    final firstError = _firstDiceError(widget.errors);
    final notation = canonicalDiceNotation(
      quantity: widget.quantityController.text,
      sides: widget.sidesController.text,
      modifier: widget.modifierController.text,
    );
    late final String visibleText;
    late final String semanticLabel;
    late final Color color;
    late final Key key;
    if (!widget.insertEnabled) {
      visibleText = '已达 $maximum/$maximum，请先删除一个骰子';
      semanticLabel = '当前正文已达 $maximum/$maximum，请先删除一个骰子';
      color = Theme.of(context).colorScheme.error;
      key = const Key('editor-dice-limit');
    } else if (firstError != null) {
      visibleText = firstError;
      semanticLabel = '$firstError；当前正文 ${widget.currentCount}/$maximum';
      color = Theme.of(context).colorScheme.error;
      key = const Key('editor-dice-status');
    } else if (notation == null) {
      visibleText = '表达式未完成 · ${widget.currentCount}/$maximum';
      semanticLabel = '骰子表达式未完成；当前正文 ${widget.currentCount}/$maximum';
      color = tokens.mutedText;
      key = const Key('editor-dice-status');
    } else {
      visibleText = '$notation = ? · ${widget.currentCount}/$maximum';
      semanticLabel = '骰子预览 $notation，待掷；当前正文 ${widget.currentCount}/$maximum';
      color = tokens.mutedText;
      key = const Key('editor-dice-status');
    }
    return Semantics(
      key: key,
      liveRegion: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Text(
        visibleText,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontFamily: firstError == null && widget.insertEnabled
              ? WenyouFoundationTypography.utility
              : null,
          fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _diceSeparator(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.space4),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
        child: Align(
          alignment: Alignment.center,
          widthFactor: 1,
          child: Text(
            'd',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: tokens.mutedText,
              fontFamily: WenyouFoundationTypography.utility,
            ),
          ),
        ),
      ),
    );
  }
}

String? _firstDiceError(EditorDiceInputErrors errors) {
  if (errors.quantity != null) {
    return '${WenyouElementContract.diceQuantityLabel}${errors.quantity}';
  }
  if (errors.sides != null) {
    return '${WenyouElementContract.diceSidesLabel}${errors.sides}';
  }
  if (errors.modifier != null) {
    return '${WenyouElementContract.diceModifierLabel}${errors.modifier}';
  }
  return null;
}

class _DiceQuickSidesMenu extends StatelessWidget {
  const _DiceQuickSidesMenu({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final selectedSides = int.tryParse(controller.text.trim());
    return PopupMenuButton<int>(
      key: const Key('editor-dice-quick-sides'),
      tooltip: '选择常用面数',
      requestFocus: false,
      position: PopupMenuPosition.under,
      initialValue: selectedSides,
      onCanceled: _restoreFocus,
      onSelected: (sides) {
        controller.value = TextEditingValue(
          text: '$sides',
          selection: TextSelection.collapsed(offset: '$sides'.length),
        );
        onChanged();
        _restoreFocus();
      },
      itemBuilder: (context) => [
        for (final sides in WenyouElementContract.diceQuickSides)
          PopupMenuItem<int>(
            key: ValueKey('editor-dice-quick-d$sides'),
            value: sides,
            height: tokens.minimumTouchTarget,
            child: Semantics(
              selected: selectedSides == sides,
              child: Text(
                'd$sides',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selectedSides == sides
                      ? tokens.brandForeground
                      : tokens.text,
                  fontFamily: WenyouFoundationTypography.utility,
                  fontWeight: selectedSides == sides
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
      ],
      child: SizedBox.square(
        dimension: tokens.minimumTouchTarget,
        child: const Center(
          child: WenyouIcon(WenyouIconIds.editorChevronDown, size: 18),
        ),
      ),
    );
  }

  void _restoreFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.canRequestFocus) focusNode.requestFocus();
    });
  }
}

class _DiceNumberField extends StatelessWidget {
  const _DiceNumberField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.error,
    required this.maxLength,
    required this.signed,
    required this.textInputAction,
    required this.onChanged,
    required this.onSubmitted,
    this.autofocus = false,
    this.suffix,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String? error;
  final int maxLength;
  final bool signed;
  final bool autofocus;
  final TextInputAction textInputAction;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final decorationTheme = Theme.of(context).inputDecorationTheme;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.numberWithOptions(signed: signed),
      textInputAction: textInputAction,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontFamily: WenyouFoundationTypography.utility,
        fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
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
        suffixIcon: suffix,
        suffixIconConstraints: suffix == null
            ? null
            : BoxConstraints(
                minWidth: tokens.minimumTouchTarget,
                minHeight: tokens.minimumTouchTarget,
              ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.space12,
          vertical: tokens.space12,
        ),
        enabledBorder: error == null ? null : decorationTheme.errorBorder,
        focusedBorder: error == null
            ? null
            : decorationTheme.focusedErrorBorder,
      ),
      onChanged: (_) => onChanged(),
      onSubmitted: (_) => onSubmitted(),
    );
  }
}
