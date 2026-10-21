enum TextFontTransferFailureKind { temporary, quarantined, cancelled }

class TextFontTransferFailure implements Exception {
  const TextFontTransferFailure(this.kind, {this.retryAfter});
  final TextFontTransferFailureKind kind;
  final Duration? retryAfter;
}
