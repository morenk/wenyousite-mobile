import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// A single-surface, keyboard-docked composer with no implicit motion.
///
/// Feature code owns validation, attachments, upload state and submission.
/// This widget only keeps their layout consistent and applies the current
/// keyboard inset immediately.
class WenyouInlineComposerDock extends StatelessWidget {
  const WenyouInlineComposerDock({
    required this.editor,
    required this.dockKey,
    required this.leadingActions,
    required this.submitAction,
    this.supporting = const [],
    this.trailingActions = const [],
    super.key,
  });

  final Widget editor;
  final Key dockKey;
  final List<Widget> supporting;
  final List<Widget> leadingActions;
  final List<Widget> trailingActions;
  final Widget submitAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return TextFieldTapRegion(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Material(
          color: tokens.panel,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space12,
                tokens.space8,
                tokens.space12,
                tokens.space8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...supporting,
                  DecoratedBox(
                    key: dockKey,
                    decoration: BoxDecoration(
                      color: tokens.softPanel,
                      borderRadius: BorderRadius.circular(tokens.radius20),
                      border: Border.all(color: tokens.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        editor,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ...leadingActions,
                            ...trailingActions,
                            const Spacer(),
                            Padding(
                              padding: EdgeInsets.all(tokens.space4),
                              child: submitAction,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
