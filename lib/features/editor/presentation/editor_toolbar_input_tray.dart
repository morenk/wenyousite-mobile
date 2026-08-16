import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

class EditorInlineInputTray extends StatelessWidget {
  const EditorInlineInputTray({
    required this.primaryController,
    required this.primaryHint,
    required this.error,
    required this.onBack,
    required this.onConfirm,
    this.secondaryController,
    this.secondaryHint,
    super.key,
  });

  final TextEditingController primaryController;
  final String primaryHint;
  final TextEditingController? secondaryController;
  final String? secondaryHint;
  final String? error;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
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
        children: [
          Row(
            children: [
              IconButton(
                tooltip: '返回格式工具',
                onPressed: onBack,
                icon: const WenyouIcon(WenyouIconIds.navigationBack),
              ),
              Expanded(
                child: TextField(
                  controller: primaryController,
                  autofocus: true,
                  textInputAction: secondaryController == null
                      ? TextInputAction.done
                      : TextInputAction.next,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: primaryHint,
                    errorText: error,
                  ),
                  onSubmitted: secondaryController == null
                      ? (_) => onConfirm()
                      : null,
                ),
              ),
              if (secondaryController != null) ...[
                SizedBox(width: tokens.space4),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: secondaryController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: secondaryHint,
                    ),
                    onSubmitted: (_) => onConfirm(),
                  ),
                ),
              ],
              IconButton.filled(
                tooltip: '确认插入',
                onPressed: onConfirm,
                icon: const WenyouIcon(WenyouIconIds.actionConfirm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
