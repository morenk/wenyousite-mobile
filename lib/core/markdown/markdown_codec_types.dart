import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_document.dart';

enum MarkdownCodecIssueKind {
  unknownProtocol,
  invalidDice,
  duplicateDice,
  invalidSticker,
  unsafeImage,
}

class MarkdownCodecIssue {
  const MarkdownCodecIssue({
    required this.kind,
    required this.rawToken,
    required this.message,
  });

  final MarkdownCodecIssueKind kind;
  final String rawToken;
  final String message;
}

class MarkdownDeltaDocument {
  const MarkdownDeltaDocument({
    required this.delta,
    required this.editorDocument,
    required this.issues,
  });

  final Delta delta;
  final MarkdownEditorDocument editorDocument;
  final List<MarkdownCodecIssue> issues;

  bool get isSourceCompatible => issues.isNotEmpty;
}

class MarkdownCodecException implements Exception {
  const MarkdownCodecException(this.message);

  final String message;

  @override
  String toString() => 'MarkdownCodecException: $message';
}
