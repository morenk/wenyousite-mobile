import 'package:flutter/widgets.dart';

/// 从已构建的文字树依次读取文字，包括行内代码使用的 WidgetSpan 子树。
String markdownRenderedText(Element root, {bool inline = false}) {
  final widget = root.widget;
  if (widget is RichText) {
    return '${_spanText(widget.text, root)}${inline ? '' : '\n'}';
  }
  final output = StringBuffer();
  root.visitChildren((child) {
    output.write(markdownRenderedText(child, inline: inline));
  });
  return output.toString();
}

String _spanText(InlineSpan span, Element owner) {
  if (span is TextSpan) {
    return '${span.text ?? ''}${span.children?.map((child) => _spanText(child, owner)).join() ?? ''}';
  }
  if (span is WidgetSpan) {
    Element? found;
    void find(Element element) {
      if (identical(element.widget, span.child)) {
        found = element;
        return;
      }
      if (found == null) element.visitChildren(find);
    }

    owner.visitChildren(find);
    return found == null
        ? '\uFFFC'
        : markdownRenderedText(found!, inline: true);
  }
  return span.toPlainText();
}
