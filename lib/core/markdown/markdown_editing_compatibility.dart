import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

/// 读取降级不得成为覆盖原文的依据；写能力必须显式具备。
abstract final class MarkdownEditingCompatibility {
  static ({String read, bool create, bool edit, String reason}) assess(
    String source, {
    bool knownProfile = true,
    bool blockAlignment = true,
    bool imageAlignment = false,
    bool quoteEmptyRows = true,
    bool lossless = true,
    MarkdownDeltaDocument? decoded,
  }) {
    if (!knownProfile) return _deny('unknown-profile');
    if (MarkdownContent.unsupportedLineIndexes(
      source,
      imageAlignment: true,
    ).isNotEmpty) {
      return _deny('unsupported-markdown');
    }
    final document =
        decoded ?? MarkdownDeltaCodec.decode(source, imageAlignment: true);
    if (document.issues.isNotEmpty) return _deny('unsupported-markdown');
    final normalized = MarkdownContent.normalize(source);
    if ((!blockAlignment &&
            MarkdownAlignmentContract.analyze(
              normalized,
              imageAlignment: true,
            ).blocks.isNotEmpty) ||
        (!imageAlignment &&
            MarkdownContent.unsupportedLineIndexes(normalized).isNotEmpty) ||
        (!quoteEmptyRows &&
            normalized
                .split('\n')
                .any(MarkdownContent.isQuotedEmptyParagraphLine))) {
      return _deny('missing-feature');
    }
    if (!lossless) return _deny('lossy-roundtrip', read: 'full');
    return (read: 'full', create: true, edit: true, reason: 'supported');
  }

  static ({String read, bool create, bool edit, String reason}) _deny(
    String reason, {
    String read = 'safe-fallback',
  }) => (read: read, create: false, edit: false, reason: reason);
}
