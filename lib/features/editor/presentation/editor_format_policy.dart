import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Keeps toolbar-created Delta inside the Markdown editor contract.
abstract final class WenyouEditorFormatPolicy {
  static const _inlineCodeConflicts = <Attribute>[
    Attribute.bold,
    Attribute.italic,
    Attribute.strikeThrough,
    Attribute.link,
  ];

  static bool isActive(Style style, Attribute attribute) {
    final current = style.attributes[attribute.key];
    return current != null && current.value == attribute.value;
  }

  static void applyHeading(QuillController controller, int level) {
    _clearBlockAttributes(controller, clearIndent: true);
    final heading = switch (level) {
      2 => Attribute.h2,
      3 => Attribute.h3,
      _ => null,
    };
    if (heading != null) controller.formatSelection(heading);
  }

  static void toggle(QuillController controller, Attribute attribute) {
    if (attribute.key == Attribute.blockQuote.key ||
        attribute.key == Attribute.list.key) {
      _toggleBlock(controller, attribute);
      return;
    }
    _toggleInline(controller, attribute);
  }

  static void applyLink(
    QuillController controller, {
    required TextSelection selection,
    required String url,
  }) {
    final length = selection.end - selection.start;
    if (length <= 0) return;
    controller.formatText(
      selection.start,
      length,
      Attribute.clone(Attribute.inlineCode, null),
    );
    controller.formatText(selection.start, length, LinkAttribute(url));
    if (controller.selection.isCollapsed) {
      controller.formatSelection(Attribute.clone(Attribute.inlineCode, null));
    }
  }

  static void _toggleInline(QuillController controller, Attribute attribute) {
    final style = controller.getSelectionStyle();
    if (isActive(style, attribute)) {
      controller.formatSelection(Attribute.clone(attribute, null));
      return;
    }
    if (attribute.key == Attribute.inlineCode.key) {
      for (final conflict in _inlineCodeConflicts) {
        controller.formatSelection(Attribute.clone(conflict, null));
      }
    } else {
      controller.formatSelection(Attribute.clone(Attribute.inlineCode, null));
    }
    controller.formatSelection(attribute);
  }

  static void _toggleBlock(QuillController controller, Attribute attribute) {
    final active = isActive(controller.getSelectionStyle(), attribute);
    if (active) {
      controller.formatSelection(Attribute.clone(attribute, null));
      if (attribute.key == Attribute.list.key) {
        controller.formatSelection(Attribute.clone(Attribute.indent, null));
      }
      return;
    }

    final currentIndent = controller
        .getSelectionStyle()
        .attributes[Attribute.indent.key]
        ?.value;
    _clearBlockAttributes(
      controller,
      clearIndent: attribute.key != Attribute.list.key,
    );
    controller.formatSelection(attribute);
    if (attribute.key == Attribute.list.key &&
        currentIndent is int &&
        currentIndent > 3) {
      controller.formatSelection(Attribute.indentL3);
    }
  }

  static void _clearBlockAttributes(
    QuillController controller, {
    required bool clearIndent,
  }) {
    for (final attribute in const <Attribute>[
      Attribute.header,
      Attribute.list,
      Attribute.blockQuote,
    ]) {
      controller.formatSelection(Attribute.clone(attribute, null));
    }
    if (clearIndent) {
      controller.formatSelection(Attribute.clone(Attribute.indent, null));
    }
  }
}
