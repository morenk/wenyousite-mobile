import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

@immutable
class WenyouDiceRollDetail {
  const WenyouDiceRollDetail({required this.results, required this.total});

  final List<int> results;
  final int total;

  int get subtotal => results.fold(0, (sum, value) => sum + value);

  int get modifier => total - subtotal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WenyouDiceRollDetail &&
          other.total == total &&
          listEquals(other.results, results);

  @override
  int get hashCode => Object.hash(total, Object.hashAll(results));
}

/// 阅读态与编辑态共用的骰子原子节点。
class WenyouDiceNode extends StatefulWidget {
  const WenyouDiceNode({
    required this.label,
    required this.semanticLabel,
    required this.settled,
    required this.style,
    this.detail,
    this.onLongPress,
    super.key,
  });

  final String label;
  final String semanticLabel;
  final bool settled;
  final TextStyle style;
  final WenyouDiceRollDetail? detail;
  final VoidCallback? onLongPress;

  @override
  State<WenyouDiceNode> createState() => _WenyouDiceNodeState();
}

class _WenyouDiceNodeState extends State<WenyouDiceNode> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'settled dice result');
  bool _expanded = false;

  bool get _actionable => widget.settled && widget.detail != null;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final effectiveStyle = widget.style.copyWith(
      color: widget.settled ? tokens.onAccentedBackground : tokens.warning,
      fontFamily: WenyouFoundationTypography.utility,
      fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
      fontFeatures: const [FontFeature.tabularFigures()],
      height: WenyouElementContract.diceLineHeight,
    );
    final fontSize =
        effectiveStyle.fontSize ??
        DefaultTextStyle.of(context).style.fontSize ??
        14;
    final radius = fontSize * 0.3;
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: widget.settled ? tokens.accentedBackground : tokens.warningSoft,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: fontSize * WenyouElementContract.dicePaddingInline,
          vertical: fontSize * WenyouElementContract.dicePaddingBlock,
        ),
        child: Text(
          widget.label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: effectiveStyle,
          strutStyle: StrutStyle.fromTextStyle(
            effectiveStyle,
            forceStrutHeight: true,
          ),
        ),
      ),
    );

    if (!_actionable) {
      return Semantics(
        container: true,
        label: widget.semanticLabel,
        excludeSemantics: true,
        onLongPress: widget.onLongPress,
        child: GestureDetector(onLongPress: widget.onLongPress, child: content),
      );
    }

    return Semantics(
      container: true,
      button: true,
      label: widget.semanticLabel,
      hint: WenyouElementContract.diceSettledSemanticsHint,
      expanded: _expanded,
      excludeSemantics: true,
      onTap: _openDetail,
      onLongPress: widget.onLongPress,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          focusNode: _focusNode,
          borderRadius: BorderRadius.circular(radius),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (!states.contains(WidgetState.pressed)) {
              return Colors.transparent;
            }
            return tokens.onAccentedBackground.withValues(
              alpha: WenyouElementContract.dicePressedStateOpacity,
            );
          }),
          onTap: _openDetail,
          onLongPress: widget.onLongPress,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: tokens.minimumTouchTarget,
              minHeight: tokens.minimumTouchTarget,
            ),
            child: Align(
              alignment: Alignment.center,
              widthFactor: 1,
              heightFactor: 1,
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDetail() async {
    if (_expanded || !_actionable) return;
    setState(() => _expanded = true);
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: WenyouElementContract.diceDetailUsesSafeArea,
        builder: (context) => _DiceResultSheet(detail: widget.detail!),
      );
    } finally {
      if (mounted) {
        setState(() => _expanded = false);
        if (WenyouElementContract.diceRestoresFocus) {
          _focusNode.requestFocus();
        }
      }
    }
  }
}

class _DiceResultSheet extends StatelessWidget {
  const _DiceResultSheet({required this.detail});

  final WenyouDiceRollDetail detail;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final maximumHeight =
        MediaQuery.sizeOf(context).height *
        WenyouElementContract.diceDetailMaximumHeightFraction;
    return ConstrainedBox(
      key: const Key('wenyou-dice-detail-sheet'),
      constraints: BoxConstraints(maxHeight: maximumHeight),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space16,
                tokens.space8,
                tokens.space8,
                tokens.space8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      WenyouElementContract.diceDetailTitle,
                      style: Theme.of(context).textTheme.wenyouOverlayTitle,
                    ),
                  ),
                  IconButton(
                    key: const Key('wenyou-dice-detail-close'),
                    tooltip: '关闭骰子结果',
                    onPressed: () => Navigator.pop(context),
                    icon: const WenyouIcon(WenyouIconIds.actionClose),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                key: const Key('wenyou-dice-detail-scroll'),
                padding: EdgeInsets.all(tokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      WenyouElementContract.diceDetailResultsLabel,
                      style: Theme.of(context).textTheme.wenyouRowTitle,
                    ),
                    SizedBox(height: tokens.space12),
                    _DiceResultTray(results: detail.results),
                    SizedBox(height: tokens.space20),
                    _DiceCalculation(detail: detail),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiceResultTray extends StatelessWidget {
  const _DiceResultTray({required this.results});

  final List<int> results;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fontSize = Theme.of(context).textTheme.wenyouBody.fontSize!;
    final style = Theme.of(
      context,
    ).textTheme.wenyouUtilityBody.copyWith(color: tokens.text);
    return Wrap(
      key: const Key('wenyou-dice-result-tray'),
      spacing: tokens.space8,
      runSpacing: tokens.space8,
      children: [
        for (var index = 0; index < results.length; index++)
          Semantics(
            label:
                '第 ${index + WenyouElementContract.diceDetailResultIndexOrigin} 枚，${results[index]} 点',
            excludeSemantics: true,
            child: Container(
              key: ValueKey('wenyou-dice-result-$index'),
              constraints: BoxConstraints(
                minWidth:
                    fontSize * WenyouElementContract.diceDetailCellMinimumWidth,
              ),
              padding: EdgeInsets.symmetric(
                horizontal:
                    fontSize *
                    WenyouElementContract.diceDetailCellPaddingInline,
                vertical:
                    fontSize * WenyouElementContract.diceDetailCellPaddingBlock,
              ),
              decoration: BoxDecoration(
                color: tokens.softPanel,
                borderRadius: BorderRadius.circular(
                  fontSize * WenyouElementContract.diceDetailCellRadius,
                ),
              ),
              child: Text(
                '${results[index]}',
                textAlign: TextAlign.center,
                style: style,
              ),
            ),
          ),
      ],
    );
  }
}

class _DiceCalculation extends StatelessWidget {
  const _DiceCalculation({required this.detail});

  final WenyouDiceRollDetail detail;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: tokens.space12),
        child: Column(
          children: [
            _CalculationRow(
              key: const Key('wenyou-dice-subtotal'),
              label: WenyouElementContract.diceDetailSubtotalLabel,
              value: '${detail.subtotal}',
            ),
            if (detail.modifier != 0) ...[
              SizedBox(height: tokens.space8),
              _CalculationRow(
                key: const Key('wenyou-dice-modifier'),
                label: WenyouElementContract.diceDetailModifierLabel,
                value: detail.modifier > 0
                    ? '+${detail.modifier}'
                    : '−${detail.modifier.abs()}',
              ),
            ],
            SizedBox(height: tokens.space8),
            _CalculationRow(
              key: const Key('wenyou-dice-total'),
              label: WenyouElementContract.diceDetailTotalLabel,
              value: '${detail.total}',
              emphasized: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculationRow extends StatelessWidget {
  const _CalculationRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    super.key,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final valueStyle = textTheme.wenyouUtilityBody.copyWith(
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w400,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: textTheme.wenyouCompactBody)),
        Text(value, style: valueStyle),
      ],
    );
  }
}
