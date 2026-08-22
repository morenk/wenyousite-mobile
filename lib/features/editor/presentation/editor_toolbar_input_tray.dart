import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_task_tray.dart';

class EditorInlineInputTray extends StatelessWidget {
  const EditorInlineInputTray({
    required this.primaryController,
    required this.primaryLabel,
    required this.onBack,
    required this.onConfirm,
    required this.onInputChanged,
    this.secondaryController,
    this.secondaryLabel,
    this.primaryError,
    this.secondaryError,
    super.key,
  });

  final TextEditingController primaryController;
  final String primaryLabel;
  final TextEditingController? secondaryController;
  final String? secondaryLabel;
  final String? primaryError;
  final String? secondaryError;
  final VoidCallback onBack;
  final VoidCallback onConfirm;
  final VoidCallback onInputChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final primary = TextField(
      controller: primaryController,
      autofocus: true,
      textInputAction: secondaryController == null
          ? TextInputAction.done
          : TextInputAction.next,
      decoration: InputDecoration(
        isDense: true,
        labelText: primaryLabel,
        errorText: primaryError,
      ),
      onChanged: (_) => onInputChanged(),
      onSubmitted: secondaryController == null ? (_) => onConfirm() : null,
    );
    final secondary = secondaryController == null
        ? null
        : TextField(
            controller: secondaryController,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              isDense: true,
              labelText: secondaryLabel,
              errorText: secondaryError,
            ),
            onChanged: (_) => onInputChanged(),
            onSubmitted: (_) => onConfirm(),
          );
    return EditorTaskTray(
      title: '插入链接',
      onBack: onBack,
      onInsert: onConfirm,
      insertKey: const Key('editor-link-insert'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (secondary == null) return primary;
          if (constraints.maxWidth < 420 ||
              MediaQuery.textScalerOf(context).scale(16) >= 21) {
            return Column(
              children: [
                primary,
                SizedBox(height: tokens.space8),
                secondary,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: primary),
              SizedBox(width: tokens.space8),
              Expanded(flex: 2, child: secondary),
            ],
          );
        },
      ),
    );
  }
}
