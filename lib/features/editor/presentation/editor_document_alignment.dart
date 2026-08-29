import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

void repairEditorTrailingNewlineAlignment({
  required QuillController controller,
  required Delta before,
  required Object? insertedData,
  required int replacedLength,
  required TextSelection? selection,
}) {
  if (insertedData != '\n' || replacedLength != 0) return;
  final patch = MarkdownDeltaAlignment.repairTrailingNewlineAlignment(
    before: before,
    after: controller.document.toDelta(),
    imageEmbed: MarkdownDeltaCodec.imageEmbed,
    horizontalRuleEmbed: MarkdownDeltaCodec.horizontalRuleEmbed,
  );
  if (patch.isEmpty) return;
  final insertedParagraph = patch.operations.any(
    (operation) => operation.isInsert,
  );
  controller.document.compose(patch, ChangeSource.local);
  if (insertedParagraph && selection != null) {
    controller.updateSelection(selection, ChangeSource.local);
  }
}

/// Keeps locally typed Quill lines inside the Markdown paragraph-alignment
/// contract before the editor session attempts serialization.
void normalizeEditorDocumentAlignment(QuillController controller) {
  final alignmentPatch = MarkdownDeltaAlignment.sanitize(
    controller.document.toDelta(),
    imageEmbed: MarkdownDeltaCodec.imageEmbed,
    horizontalRuleEmbed: MarkdownDeltaCodec.horizontalRuleEmbed,
  );
  if (alignmentPatch.isNotEmpty) {
    controller.document.compose(alignmentPatch, ChangeSource.local);
  }
}
