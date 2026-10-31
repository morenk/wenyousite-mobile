import 'package:flutter/rendering.dart';

/// 当前页面的可见文本位置，不保存正文或跨会话阅读记录。
class ReadingTextAnchor {
  const ReadingTextAnchor({
    required this.hash,
    required this.length,
    required this.occurrence,
    required this.position,
    required this.viewportOffset,
  });

  final int hash;
  final int length;
  final int occurrence;
  final TextPosition position;
  final double viewportOffset;
}

/// 只遍历已经创建的渲染段落。字体改变时用字符位置恢复，内容改变则回退楼层偏移。
class ReadingTextAnchors {
  final _fingerprints = Expando<({int hash, int length})>();

  ({int hash, int length}) _fingerprint(RenderParagraph paragraph) {
    final span = paragraph.text;
    return _fingerprints[span] ??= () {
      final text = span.toPlainText();
      return (hash: text.hashCode, length: text.length);
    }();
  }

  Iterable<RenderParagraph> _paragraphs(RenderObject root) sync* {
    if (root is RenderParagraph) {
      yield root;
      return;
    }
    final children = <RenderObject>[];
    root.visitChildren(children.add);
    for (final child in children) {
      yield* _paragraphs(child);
    }
  }

  ReadingTextAnchor? capture(
    RenderBox root, {
    required double readingTop,
    required double viewportTop,
    required double viewportBottom,
  }) {
    final occurrences = <({int hash, int length}), int>{};
    for (final paragraph in _paragraphs(root)) {
      if (!paragraph.attached || !paragraph.hasSize) continue;
      final fingerprint = _fingerprint(paragraph);
      final occurrence = occurrences.update(
        fingerprint,
        (n) => n + 1,
        ifAbsent: () => 0,
      );
      final top = paragraph.localToGlobal(Offset.zero).dy;
      if (fingerprint.length == 0 ||
          top + paragraph.size.height <= readingTop ||
          top >= viewportBottom) {
        continue;
      }
      final position = paragraph.getPositionForOffset(
        Offset(
          paragraph.textDirection == TextDirection.rtl
              ? paragraph.size.width - 1
              : 0,
          (readingTop - top).clamp(0, paragraph.size.height),
        ),
      );
      final caret = paragraph.getOffsetForCaret(position, Rect.zero);
      return ReadingTextAnchor(
        hash: fingerprint.hash,
        length: fingerprint.length,
        occurrence: occurrence,
        position: position,
        viewportOffset: paragraph.localToGlobal(caret).dy - viewportTop,
      );
    }
    return null;
  }

  double? offset(RenderBox root, ReadingTextAnchor anchor) {
    var occurrence = 0;
    for (final paragraph in _paragraphs(root)) {
      if (!paragraph.attached || !paragraph.hasSize) continue;
      final fingerprint = _fingerprint(paragraph);
      if (fingerprint.hash != anchor.hash ||
          fingerprint.length != anchor.length) {
        continue;
      }
      if (occurrence++ != anchor.occurrence) continue;
      final caret = paragraph.getOffsetForCaret(anchor.position, Rect.zero);
      return paragraph.localToGlobal(caret, ancestor: root).dy -
          anchor.viewportOffset;
    }
    return null;
  }
}
