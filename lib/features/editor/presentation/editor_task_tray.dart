import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

class EditorTaskTray extends StatelessWidget {
  const EditorTaskTray({
    required this.title,
    required this.onBack,
    required this.onInsert,
    required this.child,
    this.headerSupport,
    this.insertEnabled = true,
    this.insertKey,
    this.showInsertIcon = true,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onInsert;
  final bool insertEnabled;
  final Key? insertKey;
  final Widget? headerSupport;
  final bool showInsertIcon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final scheme = Theme.of(context).colorScheme;
    final maximumHeight = (MediaQuery.sizeOf(context).height * .32).clamp(
      168.0,
      224.0,
    );
    return Container(
      constraints: BoxConstraints(maxHeight: maximumHeight),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space4,
              tokens.space4,
              tokens.space8,
              0,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: '返回格式工具',
                  onPressed: onBack,
                  icon: const WenyouIcon(WenyouIconIds.navigationBack),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ?headerSupport,
                    ],
                  ),
                ),
                if (showInsertIcon)
                  FilledButton.icon(
                    key: insertKey,
                    style: _insertStyle(
                      tokens: tokens,
                      scheme: scheme,
                      minimumWidth: 80,
                    ),
                    onPressed: insertEnabled ? onInsert : null,
                    icon: const WenyouIcon(
                      WenyouIconIds.actionConfirm,
                      size: 18,
                    ),
                    label: const Text('插入'),
                  )
                else
                  FilledButton(
                    key: insertKey,
                    style:
                        _insertStyle(
                          tokens: tokens,
                          scheme: scheme,
                          minimumWidth: 64,
                        ).copyWith(
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: tokens.space16),
                          ),
                        ),
                    onPressed: insertEnabled ? onInsert : null,
                    child: const Text('插入'),
                  ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              key: const Key('editor-task-tray-scroll'),
              padding: EdgeInsets.fromLTRB(
                tokens.space8,
                tokens.space4,
                tokens.space8,
                tokens.space8,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _insertStyle({
    required WenyouThemeTokens tokens,
    required ColorScheme scheme,
    required double minimumWidth,
  }) {
    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(minimumWidth, tokens.minimumTouchTarget),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? tokens.border
            : scheme.primary,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? tokens.mutedText
            : scheme.onPrimary,
      ),
    );
  }
}
