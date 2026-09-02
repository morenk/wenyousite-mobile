import 'package:flutter/foundation.dart';

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
}
