import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// A single-surface, keyboard-docked composer with no implicit motion.
///
/// Feature code owns validation, attachments, upload state and submission.
/// This widget only keeps their layout consistent and applies the current
/// keyboard inset immediately.
class WenyouInlineComposerDock extends StatelessWidget {
  const WenyouInlineComposerDock({
    required this.controller,
    required this.fieldKey,
    required this.dockKey,
    required this.placeholder,
    required this.maxLength,
    required this.onChanged,
    required this.leadingActions,
    required this.submitAction,
    this.supporting = const [],
    this.trailingActions = const [],
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
    this.minLines = 1,
    this.maxLines = 5,
    this.characterCountText,
    this.characterCountKey,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final Key fieldKey;
  final Key dockKey;
  final String placeholder;
  final int maxLength;
  final ValueChanged<String> onChanged;
  final List<Widget> supporting;
  final List<Widget> leadingActions;
  final List<Widget> trailingActions;
  final Widget submitAction;
  final bool enabled;
  final bool autofocus;
  final int minLines;
  final int maxLines;
  final String? characterCountText;
  final Key? characterCountKey;

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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ...leadingActions,
                        Expanded(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              TextField(
                                key: fieldKey,
                                controller: controller,
                                focusNode: focusNode,
                                enabled: enabled,
                                autofocus: autofocus,
                                minLines: minLines,
                                maxLines: maxLines,
                                maxLength: maxLength,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.newline,
                                decoration: InputDecoration(
                                  hintText: placeholder,
                                  counterText: '',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.fromLTRB(
                                    tokens.space4,
                                    tokens.space12,
                                    characterCountText == null
                                        ? 0
                                        : tokens.minimumTouchTarget,
                                    tokens.space12,
                                  ),
                                ),
                                onTapOutside: (_) => FocusManager
                                    .instance
                                    .primaryFocus
                                    ?.unfocus(),
                                onChanged: onChanged,
                              ),
                              if (characterCountText != null)
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: tokens.space4,
                                    bottom: tokens.space4,
                                  ),
                                  child: Text(
                                    characterCountText!,
                                    key: characterCountKey,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: tokens.mutedText),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        ...trailingActions,
                        Padding(
                          padding: EdgeInsets.all(tokens.space4),
                          child: submitAction,
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
