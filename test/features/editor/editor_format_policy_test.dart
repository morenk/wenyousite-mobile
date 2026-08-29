import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';

void main() {
  test('十五种兼容行内组合都能安全往返', () {
    const inlineAttributes = <Attribute>[
      Attribute.bold,
      Attribute.italic,
      Attribute.strikeThrough,
    ];
    for (var mask = 1; mask < 16; mask++) {
      final controller = _selectedController();
      addTearDown(controller.dispose);
      for (var bit = 0; bit < inlineAttributes.length; bit++) {
        if (mask & (1 << bit) != 0) {
          WenyouEditorFormatPolicy.toggle(controller, inlineAttributes[bit]);
        }
      }
      if (mask & 8 != 0) {
        WenyouEditorFormatPolicy.applyLink(
          controller,
          selection: _bodySelection,
          url: 'https://wenyou.site/help',
        );
      }

      final markdown = MarkdownDeltaCodec.encode(controller.document.toDelta());
      expect(
        MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(markdown).delta),
        markdown,
        reason: 'inline mask $mask',
      );
    }
  });

  test('行内代码与强调和链接双向切换时清除冲突属性', () {
    final toCode = _selectedController();
    addTearDown(toCode.dispose);
    for (final attribute in const [
      Attribute.bold,
      Attribute.italic,
      Attribute.strikeThrough,
    ]) {
      WenyouEditorFormatPolicy.toggle(toCode, attribute);
    }
    WenyouEditorFormatPolicy.applyLink(
      toCode,
      selection: _bodySelection,
      url: 'https://wenyou.site/help',
    );
    WenyouEditorFormatPolicy.toggle(toCode, Attribute.inlineCode);
    final codeAttributes = _inlineAttributes(toCode);
    expect(codeAttributes[Attribute.inlineCode.key], true);
    for (final key in const ['bold', 'italic', 'strike', 'link']) {
      expect(codeAttributes, isNot(contains(key)));
    }
    expect(MarkdownDeltaCodec.encode(toCode.document.toDelta()), '`正文`');

    for (final attribute in const [
      Attribute.bold,
      Attribute.italic,
      Attribute.strikeThrough,
    ]) {
      final controller = _selectedController();
      addTearDown(controller.dispose);
      WenyouEditorFormatPolicy.toggle(controller, Attribute.inlineCode);
      WenyouEditorFormatPolicy.toggle(controller, attribute);
      expect(_inlineAttributes(controller), isNot(contains('code')));
      expect(
        MarkdownDeltaCodec.encode(controller.document.toDelta()),
        isNot(contains('`')),
      );
    }

    final toLink = _selectedController();
    addTearDown(toLink.dispose);
    WenyouEditorFormatPolicy.toggle(toLink, Attribute.inlineCode);
    WenyouEditorFormatPolicy.applyLink(
      toLink,
      selection: _bodySelection,
      url: 'https://wenyou.site/help',
    );
    expect(_inlineAttributes(toLink), isNot(contains('code')));
    expect(
      MarkdownDeltaCodec.encode(toLink.document.toDelta()),
      '[正文](https://wenyou.site/help)',
    );
  });

  test('正文、标题、引用和两种列表转换后只保留目标块样式', () {
    final transitions = <void Function(QuillController)>[
      (controller) => WenyouEditorFormatPolicy.applyHeading(controller, 0),
      (controller) => WenyouEditorFormatPolicy.applyHeading(controller, 2),
      (controller) => WenyouEditorFormatPolicy.applyHeading(controller, 3),
      (controller) =>
          WenyouEditorFormatPolicy.toggle(controller, Attribute.blockQuote),
      (controller) => WenyouEditorFormatPolicy.toggle(controller, Attribute.ul),
      (controller) => WenyouEditorFormatPolicy.toggle(controller, Attribute.ol),
    ];

    for (var source = 0; source < transitions.length; source++) {
      for (var target = 0; target < transitions.length; target++) {
        final controller = _selectedController();
        addTearDown(controller.dispose);
        transitions[source](controller);
        transitions[target](controller);
        final attributes = _lineAttributes(controller);
        final activeBlocks = const [
          'header',
          'blockquote',
          'list',
        ].where(attributes.containsKey).toList();
        expect(
          activeBlocks.length,
          lessThanOrEqualTo(1),
          reason: 'block transition $source -> $target',
        );
        expect(
          () => MarkdownDeltaCodec.encode(controller.document.toDelta()),
          returnsNormally,
          reason: 'block transition $source -> $target',
        );
      }
    }
  });

  for (var indent = 0; indent <= 3; indent++) {
    test('$indent 级列表保留合法缩进并能与行内组合往返', () {
      final controller = _selectedController();
      addTearDown(controller.dispose);
      WenyouEditorFormatPolicy.toggle(controller, Attribute.ul);
      if (indent > 0) {
        controller.formatSelection(Attribute.getIndentLevel(indent));
      }
      WenyouEditorFormatPolicy.toggle(controller, Attribute.bold);
      WenyouEditorFormatPolicy.toggle(controller, Attribute.italic);
      WenyouEditorFormatPolicy.toggle(controller, Attribute.strikeThrough);

      final markdown = MarkdownDeltaCodec.encode(controller.document.toDelta());
      expect(
        MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(markdown).delta),
        markdown,
      );
      expect(
        _lineAttributes(controller)[Attribute.indent.key],
        indent == 0 ? null : indent,
      );
    });
  }

  test('折叠光标切换粗体后新输入继承格式，再次切换即可关闭', () {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);
    controller.updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.local,
    );
    WenyouEditorFormatPolicy.toggle(controller, Attribute.bold);
    controller.replaceText(
      0,
      0,
      '粗体',
      const TextSelection.collapsed(offset: 2),
    );
    WenyouEditorFormatPolicy.toggle(controller, Attribute.bold);
    controller.replaceText(
      2,
      0,
      '正文',
      const TextSelection.collapsed(offset: 4),
    );

    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      '**粗体**正文',
    );
  });

  test('合法正文和标题可直接设置左、居中和右并无损保存', () {
    final controller = QuillController(
      document: Document.fromDelta(
        MarkdownDeltaCodec.decode('[wenyousite-align-v1-center]: #\n正文').delta,
      ),
      selection: const TextSelection.collapsed(offset: 1),
    );
    addTearDown(controller.dispose);

    final initial = WenyouEditorFormatPolicy.alignmentSelection(controller);
    expect(initial.canApply, isTrue);
    expect(initial.alignment, WenyouTextAlignment.center);
    WenyouEditorFormatPolicy.applyAlignment(
      controller,
      WenyouTextAlignment.right,
    );
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      '[wenyousite-align-v1-right]: #\n正文',
    );
    WenyouEditorFormatPolicy.applyAlignment(
      controller,
      WenyouTextAlignment.left,
    );
    expect(MarkdownDeltaCodec.encode(controller.document.toDelta()), '正文');
    WenyouEditorFormatPolicy.applyAlignment(
      controller,
      WenyouTextAlignment.center,
    );
    WenyouEditorFormatPolicy.applyHeading(controller, 2);
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      '[wenyousite-align-v1-center]: #\n## 正文',
    );
  });

  test('列表转换清除对齐，普通图片块不响应对齐切换', () {
    final paragraph = _selectedController();
    addTearDown(paragraph.dispose);
    WenyouEditorFormatPolicy.applyAlignment(
      paragraph,
      WenyouTextAlignment.center,
    );
    WenyouEditorFormatPolicy.toggle(paragraph, Attribute.ul);
    expect(_lineAttributes(paragraph), isNot(contains('align')));
    expect(MarkdownDeltaCodec.encode(paragraph.document.toDelta()), '- 正文');

    final image = QuillController(
      document: Document.fromDelta(
        MarkdownDeltaCodec.decode(
          '![图片](https://cdn.example.com/images/a.png)',
        ).delta,
      ),
      selection: const TextSelection.collapsed(offset: 0),
    );
    addTearDown(image.dispose);
    final before = image.document.toDelta().toJson();
    final imageSelection = WenyouEditorFormatPolicy.alignmentSelection(image);
    expect(imageSelection.canApply, isFalse);
    expect(imageSelection.alignment, isNull);
    WenyouEditorFormatPolicy.applyAlignment(image, WenyouTextAlignment.center);
    expect(image.document.toDelta().toJson(), before);
  });

  test('混合对齐选区不预选分段但仍可直接统一目标方向', () {
    final controller = QuillController(
      document: Document.fromDelta(
        Delta()
          ..insert('第一行')
          ..insert('\n')
          ..insert('第二行')
          ..insert('\n', {'align': 'right'}),
      ),
      selection: const TextSelection(baseOffset: 0, extentOffset: 8),
    );
    addTearDown(controller.dispose);

    final mixed = WenyouEditorFormatPolicy.alignmentSelection(controller);
    expect(mixed.canApply, isTrue);
    expect(mixed.alignment, isNull);
    WenyouEditorFormatPolicy.applyAlignment(
      controller,
      WenyouTextAlignment.center,
    );
    final unified = WenyouEditorFormatPolicy.alignmentSelection(controller);
    expect(unified.alignment, WenyouTextAlignment.center);
  });
}

const _bodySelection = TextSelection(baseOffset: 0, extentOffset: 2);

QuillController _selectedController() => QuillController(
  document: Document()..insert(0, '正文'),
  selection: _bodySelection,
);

Map<String, dynamic> _inlineAttributes(QuillController controller) =>
    controller.document.toDelta().operations.first.attributes ?? const {};

Map<String, dynamic> _lineAttributes(QuillController controller) {
  final newline = controller.document.toDelta().operations.last;
  return newline.attributes ?? const {};
}
