import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

void inheritEditorTrailingEmptyLineAlignment({
  required Document document,
  required Delta before,
  required Object? insertedData,
  required int replacedLength,
}) {
  if (insertedData != '\n' || replacedLength != 0) return;
  final patch = MarkdownDeltaAlignment.inheritTrailingEmptyLineAlignment(
    before: before,
    after: document.toDelta(),
    imageEmbed: MarkdownDeltaCodec.imageEmbed,
    horizontalRuleEmbed: MarkdownDeltaCodec.horizontalRuleEmbed,
  );
  if (patch.isNotEmpty) document.compose(patch, ChangeSource.local);
}

/// Keeps locally typed Quill lines inside the Markdown paragraph-alignment
/// contract before the editor session attempts serialization.
void normalizeEditorDocumentAlignment(
  QuillController controller,
  DocChange change,
) {
  final inheritedAlignmentPatch = change.source == ChangeSource.local
      ? MarkdownDeltaAlignment.inheritTrailingLineAlignment(
          before: change.before,
          after: controller.document.toDelta(),
          change: change.change,
          imageEmbed: MarkdownDeltaCodec.imageEmbed,
          horizontalRuleEmbed: MarkdownDeltaCodec.horizontalRuleEmbed,
        )
      : null;
  if (inheritedAlignmentPatch?.isNotEmpty ?? false) {
    controller.document.compose(inheritedAlignmentPatch!, ChangeSource.local);
  }

  final alignmentPatch = MarkdownDeltaAlignment.sanitize(
    controller.document.toDelta(),
    imageEmbed: MarkdownDeltaCodec.imageEmbed,
    horizontalRuleEmbed: MarkdownDeltaCodec.horizontalRuleEmbed,
  );
  if (alignmentPatch.isNotEmpty) {
    controller.document.compose(alignmentPatch, ChangeSource.local);
  }
}
