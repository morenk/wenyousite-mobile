import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';

class PostComposerSheetHeader extends StatelessWidget {
  const PostComposerSheetHeader({
    required this.label,
    required this.expanded,
    required this.onResize,
    required this.onToggleExpanded,
    super.key,
  });

  final String label;
  final bool expanded;
  final ValueChanged<double>? onResize;
  final VoidCallback? onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return GestureDetector(
      key: const Key('post-composer-header'),
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onResize == null
          ? null
          : (details) => onResize!(details.delta.dy),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: tokens.space12,
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          SizedBox(
            height: tokens.minimumTouchTarget,
            child: Row(
              children: [
                SizedBox(width: tokens.space16),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.wenyouRowTitle,
                  ),
                ),
                IconButton(
                  key: const Key('post-composer-expand'),
                  tooltip: expanded ? '恢复半屏' : '展开编辑器',
                  onPressed: onToggleExpanded,
                  icon: WenyouIcon(
                    expanded
                        ? WenyouIconIds.actionExitFullscreen
                        : WenyouIconIds.actionFullscreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostComposerEditorRegion extends StatelessWidget {
  const PostComposerEditorRegion({
    required this.editorSession,
    required this.label,
    required this.placeholder,
    required this.threadId,
    required this.locked,
    required this.canvasMeasureKey,
    required this.toolbarMeasureKey,
    required this.toolbar,
    super.key,
  });

  final RichEditorSession editorSession;
  final String label;
  final String placeholder;
  final String threadId;
  final bool locked;
  final Key canvasMeasureKey;
  final Key toolbarMeasureKey;
  final Widget toolbar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Expanded(
      child: KeyedSubtree(
        key: const Key('post-composer-canvas'),
        child: ColoredBox(
          key: canvasMeasureKey,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: LayoutBuilder(
            builder: (context, canvasConstraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Semantics(
                        textField: true,
                        label: label,
                        child: QuillEditor(
                          key: const Key('post-composer-body'),
                          controller: editorSession.controller,
                          focusNode: editorSession.focusNode,
                          scrollController: editorSession.scrollController,
                          config: QuillEditorConfig(
                            scrollable: true,
                            expands: true,
                            autoFocus: true,
                            paintCursorAboveText: true,
                            padding: EdgeInsets.all(tokens.space16),
                            placeholder: placeholder,
                            customStyles: wenyouEditorTextStyles(context),
                            // Flutter Quill 尚未稳定开放自定义块前导渲染入口。
                            // ignore: experimental_member_use
                            customLeadingBlockBuilder:
                                wenyouEditorLeadingBlockBuilder(context),
                            embedBuilders: wenyouEditorEmbedBuilders(),
                            customShortcuts: editorSession.clipboardShortcuts,
                            customActions: editorSession.clipboardActions,
                            contextMenuBuilder: editorSession.buildContextMenu,
                          ),
                        ),
                      ),
                      MentionSuggestions(
                        controller: editorSession.controller,
                        focusNode: editorSession.focusNode,
                        threadId: threadId,
                        enabled: !locked && editorSession.codecFailure == null,
                      ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: canvasConstraints.maxHeight,
                  ),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: KeyedSubtree(key: toolbarMeasureKey, child: toolbar),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
