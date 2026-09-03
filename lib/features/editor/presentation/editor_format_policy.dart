import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

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

  static MarkdownAlignmentSelectionState alignmentSelection(
    QuillController controller, {
    bool imageAlignment = false,
  }) {
    final selection = controller.selection;
    return MarkdownDeltaAlignment.selectionState(
      controller.document.toDelta(),
      start: selection.start,
      end: selection.end,
      imageEmbed: MarkdownDeltaCodec.imageEmbed,
      horizontalRuleEmbed: MarkdownDeltaCodec.horizontalRuleEmbed,
      imageAlignment: imageAlignment,
    );
  }

  static void applyAlignment(
    QuillController controller,
    WenyouTextAlignment alignment, {
    bool imageAlignment = false,
  }) {
    final selection = controller.selection;
    final patch = MarkdownDeltaAlignment.applySelection(
      controller.document.toDelta(),
      start: selection.start,
      end: selection.end,
      alignment: alignment,
      imageEmbed: MarkdownDeltaCodec.imageEmbed,
      horizontalRuleEmbed: MarkdownDeltaCodec.horizontalRuleEmbed,
      imageAlignment: imageAlignment,
    );
    if (patch.isNotEmpty) {
      controller.compose(patch, controller.selection, ChangeSource.local);
    }
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
      clearAlignment: true,
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
    bool clearAlignment = false,
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
    if (clearAlignment) {
      controller.formatSelection(Attribute.clone(Attribute.align, null));
    }
  }
}
