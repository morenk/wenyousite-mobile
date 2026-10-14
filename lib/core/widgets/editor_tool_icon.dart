import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';

String editorToolIconId(EditorTool tool) => switch (tool) {
  EditorTool.heading => WenyouIconIds.editorHeading,
  EditorTool.bold => WenyouIconIds.editorBold,
  EditorTool.italic => WenyouIconIds.editorItalic,
  EditorTool.image => WenyouIconIds.editorImage,
  EditorTool.quote => WenyouIconIds.editorQuote,
  EditorTool.sticker => WenyouIconIds.editorSticker,
  EditorTool.drafts => WenyouIconIds.editorContentDrafts,
  EditorTool.alignCenter => WenyouIconIds.editorAlignCenter,
  EditorTool.alignRight => WenyouIconIds.editorAlignRight,
  EditorTool.link => WenyouIconIds.editorLink,
  EditorTool.inlineCode => WenyouIconIds.editorInlineCode,
  EditorTool.horizontalRule => WenyouIconIds.editorHorizontalRule,
  EditorTool.dice => WenyouIconIds.editorDice,
  EditorTool.strike => WenyouIconIds.editorStrikethrough,
};
