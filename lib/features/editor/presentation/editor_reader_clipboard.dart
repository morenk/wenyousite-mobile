import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_clipboard_text.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';

typedef ReaderMarkdownClipboardWriter =
    Future<void> Function({
      required String markdown,
      required Map<String, String> diceLabels,
      required SessionScope scope,
    });

final readerMarkdownClipboardWriterProvider =
    Provider<ReaderMarkdownClipboardWriter>((ref) {
      return ({required markdown, required diceLabels, required scope}) =>
          copyReaderMarkdownToClipboard(
            markdown: markdown,
            diceLabels: diceLabels,
            scope: scope,
          );
    });

/// Captures a complete mobile reader item for a later editor paste.
///
/// The system clipboard remains readable visible text, while the process-local
/// payload keeps supported text structure. Reader media deliberately becomes
/// labels; dice keeps only its notation and receives a new identity on paste.
Future<void> copyReaderMarkdownToClipboard({
  required String markdown,
  required SessionScope scope,
  Map<String, String> diceLabels = const {},
  EditorClipboardGateway? clipboardGateway,
  WenyouEditorClipboardStore? clipboardStore,
}) async {
  final gateway = clipboardGateway ?? const PlatformEditorClipboardGateway();
  final store = clipboardStore ?? wenyouEditorClipboardStore;

  // A failed replacement must not leave the previous structured payload
  // eligible for a later paste that happens to share the same visible text.
  store.clear();
  try {
    final delta = _readerClipboardDelta(
      MarkdownDeltaCodec.decode(markdown).delta,
    );
    final marker = const Uuid().v4();
    final fallback = store.capture(
      delta: delta,
      plainTextFallback: MarkdownClipboardText.projectDelta(
        delta,
        diceLabels: diceLabels,
      ),
      operation: WenyouEditorClipboardOperation.copy,
      marker: marker,
      scope: scope,
    );
    await gateway.write(text: fallback, marker: marker);
  } on Object {
    store.clear();
    rethrow;
  }
}

Delta _readerClipboardDelta(Delta source) {
  final output = Delta();
  for (final operation in source.operations) {
    final data = operation.data;
    if (data is Map && data.length == 1) {
      final type = data.keys.single;
      final label = switch (type) {
        MarkdownDeltaCodec.imageEmbed => '[图片]',
        MarkdownDeltaCodec.stickerEmbed => '[表情]',
        _ => null,
      };
      if (label != null) {
        output.insert(label, {
          ...?operation.attributes,
          MarkdownDeltaCodec.literalTextAttribute: true,
        });
        continue;
      }
    }
    output.insert(data, operation.attributes);
  }
  return output;
}
