import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/navigation/internal_link.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

class WenyouInternalReferenceText extends StatefulWidget {
  const WenyouInternalReferenceText({
    required this.content,
    this.style,
    this.selectable = false,
    super.key,
  });

  final String content;
  final TextStyle? style;
  final bool selectable;

  @override
  State<WenyouInternalReferenceText> createState() =>
      _WenyouInternalReferenceTextState();
}

class _WenyouInternalReferenceTextState
    extends State<WenyouInternalReferenceText> {
  late List<InternalReferenceTextSegment> _segments;
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void initState() {
    super.initState();
    _rebuildSegments();
  }

  @override
  void didUpdateWidget(covariant WenyouInternalReferenceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _disposeRecognizers();
      _rebuildSegments();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final children = <InlineSpan>[];
    var portalIndex = 0;
    for (final segment in _segments) {
      switch (segment) {
        case InternalReferencePlainText(:final value):
          children.add(TextSpan(text: value));
        case InternalReferencePortal(:final label):
          final recognizer = _recognizers[portalIndex++];
          children.add(
            TextSpan(
              text: label,
              recognizer: recognizer,
              style:
                  widget.style?.copyWith(
                    color: tokens.brandForeground,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: tokens.brandForeground,
                  ) ??
                  TextStyle(
                    color: tokens.brandForeground,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: tokens.brandForeground,
                  ),
            ),
          );
      }
    }
    final span = TextSpan(style: widget.style, children: children);
    final text = Text.rich(span);
    if (widget.selectable) return SelectionArea(child: text);
    return text;
  }

  void _rebuildSegments() {
    _segments = tokenizeInternalReferenceText(widget.content);
    for (final segment in _segments) {
      if (segment case InternalReferencePortal(:final reference)) {
        _recognizers.add(
          TapGestureRecognizer()
            ..onTap = () {
              if (mounted) {
                openInternalWenyouLink(context, reference.location);
              }
            },
        );
      }
    }
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }
}
