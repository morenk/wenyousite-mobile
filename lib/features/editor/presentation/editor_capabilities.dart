import 'package:flutter/foundation.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';

@immutable
class WenyouEditorCapabilities {
  const WenyouEditorCapabilities({
    this.headings = true,
    this.inlineStyles = true,
    this.images = true,
    this.links = true,
    this.blockStyles = true,
    this.alignment = false,
    this.imageAlignment = false,
    this.dice = true,
    this.stickers = true,
    this.drafts = true,
  });

  static const richMarkdown = WenyouEditorCapabilities();
  static const richMarkdownWithAlignment = WenyouEditorCapabilities(
    alignment: true,
  );
  static const richMarkdownWithImageAlignment = WenyouEditorCapabilities(
    alignment: true,
    imageAlignment: true,
  );

  static WenyouEditorCapabilities forAlignment(
    bool enabled, {
    bool imageAlignment = false,
  }) => !enabled
      ? richMarkdown
      : imageAlignment
      ? richMarkdownWithImageAlignment
      : richMarkdownWithAlignment;

  final bool headings;
  final bool inlineStyles;
  final bool images;
  final bool links;
  final bool blockStyles;
  final bool alignment;
  final bool imageAlignment;
  final bool dice;
  final bool stickers;
  final bool drafts;

  bool get hasMoreActions =>
      inlineStyles || links || blockStyles || alignment || dice || stickers;

  Set<EditorTool> availableTools({required bool stickerCallback}) => {
    if (headings) EditorTool.heading,
    if (inlineStyles) ...[
      EditorTool.bold,
      EditorTool.italic,
      EditorTool.inlineCode,
      EditorTool.strike,
    ],
    if (images) EditorTool.image,
    if (blockStyles) ...[EditorTool.quote, EditorTool.horizontalRule],
    if (alignment) ...[EditorTool.alignCenter, EditorTool.alignRight],
    if (links) EditorTool.link,
    if (dice) EditorTool.dice,
    if (drafts) EditorTool.drafts,
    if (stickers && stickerCallback) EditorTool.sticker,
  };

  /// 编辑器与摆放预览共用扣除内边距后的实际宽度和能力规则。
  ResolvedEditorToolbarLayout resolveToolbar(
    EditorToolbarLayout layout, {
    required double width,
    required bool showSubmit,
    required bool stickerCallback,
  }) => layout.resolve(
    slots: (width / WenyouEditorContract.minimumActionExtent).floor(),
    showMore: hasMoreActions || !layout.isDefault,
    showSubmit: showSubmit,
    available: availableTools(stickerCallback: stickerCallback),
  );
}
