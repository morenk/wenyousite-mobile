import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

enum _Format { body, h2, h3, bullet, ordered, quote, center, right }

void main() {
  testWidgets('空选区链接不生成假正文，链接正文删空后可以保存', (tester) async {
    final session = _session('');
    WenyouEditorFormatPolicy.applyLink(
      session.controller,
      selection: const TextSelection.collapsed(offset: 0),
      url: 'https://example.com',
    );
    expect(await session.flush(), isTrue);
    expect(_encode(session), isEmpty);
    session.controller.replaceText(
      0,
      0,
      '链接',
      const TextSelection.collapsed(offset: 2),
    );
    WenyouEditorFormatPolicy.applyLink(
      session.controller,
      selection: const TextSelection(baseOffset: 0, extentOffset: 2),
      url: 'https://example.com',
    );
    expect(await session.flush(), isTrue);
    final nodes = _elements(
      md.Document().parseLines(_encode(session).split('\n')),
    );
    expect(nodes.where((node) => node.tag == 'a').single.textContent, '链接');
    session.controller.replaceText(
      0,
      2,
      '',
      const TextSelection.collapsed(offset: 0),
    );
    await tester.pump();
    expect(await session.flush(), isTrue);
    expect(MarkdownContent.hasVisibleContent(_encode(session)), isFalse);
  });

  testWidgets('空正文插入分隔线后可保存重开但不绕过文字校验', (tester) async {
    final session = _session('');
    session.insertHorizontalRule();
    await tester.pump();
    expect(await session.flush(), isTrue);
    final saved = _encode(session);
    expect(
      (md.Document().parseLines(saved.split('\n')).single as md.Element).tag,
      'hr',
    );
    expect(MarkdownContent.hasVisibleContent(saved), isFalse);
    expect(
      _session(saved).controller.document.toPlainText(),
      session.controller.document.toPlainText(),
    );
  });

  test('空块也不能绕过未知属性与互斥格式校验', () {
    for (final attributes in <Map<String, dynamic>>[
      {'header': 2, 'list': 'bullet'},
      {'list': 'checked'},
      {'header': 1},
      {'align': 'justify', 'list': 'ordered'},
      {'list': 'bullet', 'indent': 4},
      {'unknown-format': true},
    ]) {
      expect(
        () => MarkdownDeltaCodec.encode(Delta()..insert('\n', attributes)),
        throwsA(isA<MarkdownCodecException>()),
      );
    }
  });

  test('空白字符引用不绕过发布校验，也不吞掉代码和转义原文', () {
    for (final source in ['## &#32;', '- &#9;', '> &#x20;']) {
      expect(MarkdownContent.hasVisibleContent(source), isFalse);
    }
    for (final source in ['`&#32;`', r'\&#32;', '```\n&#32;\n```']) {
      expect(MarkdownContent.hasVisibleContent(source), isTrue);
    }
  });
  for (final ordered in [false, true]) {
    test('列表标记与提及节点分开解码时仍属于同一列表项 $ordered', () {
      final source = '${ordered ? '1.' : '-'} [@旅人](/users/user-one)';
      final session = _session(source);
      expect(session.controller.document.toPlainText(), '\uFFFC\n');
      expect(
        session.controller.document
            .toDelta()
            .operations
            .last
            .attributes?['list'],
        ordered ? 'ordered' : 'bullet',
      );
      expect(_encode(session), source);
      final list = md.Document().parseLines([source]).single as md.Element;
      expect(list.tag, ordered ? 'ol' : 'ul');
      expect((list.children!.single as md.Element).tag, 'li');
    });
  }
  for (final format in _Format.values) {
    for (final whitespace in [' ', '  ', '\t', '\u00a0', '\u200b']) {
      testWidgets('$format 仅输入空白 ${whitespace.codeUnits} 仍可保存且不算正文', (
        tester,
      ) async {
        final session = _session('');
        _apply(session.controller, format);
        session.controller.replaceText(
          0,
          0,
          whitespace,
          TextSelection.collapsed(offset: whitespace.length),
        );
        await tester.pump();
        expect(await session.flush(), isTrue);
        final saved = _encode(session);
        expect(
          _session(saved).controller.document.toPlainText(),
          '$whitespace\n',
        );
        expect(MarkdownContent.hasVisibleContent(saved), isFalse);
      });
    }
    for (final initial in ['', '<br />', '<br />\n\n<br />']) {
      testWidgets('$format 空行 ${initial.length} 选择、续写、删空和重开', (tester) async {
        final session = _session(initial);
        if (format == _Format.center || format == _Format.right) {
          // 共享契约不允许为独占 br 存储对齐；新建空正文可暂存输入方向。
          expect(
            WenyouEditorFormatPolicy.alignmentSelection(
              session.controller,
            ).canApply,
            initial.isEmpty,
          );
        }
        _apply(session.controller, format);
        await tester.pump(const Duration(milliseconds: 400));
        expect(session.codecFailure, isNull);
        expect(await session.flush(), isTrue);
        final empty = _encode(session);
        expect(MarkdownContent.hasVisibleContent(empty), isFalse);
        final reopened = _session(empty);
        expect(
          reopened.controller.document.toPlainText(),
          session.controller.document.toPlainText(),
        );
        _expectBlock(reopened.controller, format, empty: true);
        session.controller.replaceText(
          0,
          0,
          '甲',
          const TextSelection.collapsed(offset: 1),
        );
        await tester.pump();
        expect(await session.flush(), isTrue);
        final filled = _encode(session);
        expect(MarkdownContent.hasVisibleContent(filled), isTrue);
        _expectBlock(
          _session(filled).controller,
          initial.isNotEmpty &&
                  (format == _Format.center || format == _Format.right)
              ? _Format.body
              : format,
          empty: false,
        );
        session.controller.replaceText(
          0,
          1,
          '',
          const TextSelection.collapsed(offset: 0),
        );
        await tester.pump();
        expect(await session.flush(), isTrue);
        expect(_encode(session), empty);
      });
    }

    testWidgets('$format 三次回车及逐行续写始终可以序列化', (tester) async {
      final session = _session('');
      _apply(session.controller, format);
      for (var step = 0; step < 3; step++) {
        final position = session.controller.selection.start;
        session.controller.replaceText(
          position,
          0,
          '\n',
          TextSelection.collapsed(offset: position + 1),
        );
        await tester.pump();
        expect(await session.flush(), isTrue, reason: 'Enter $step');
        final reopened = _session(_encode(session));
        expect(
          reopened.controller.document.toPlainText(),
          session.controller.document.toPlainText(),
        );
      }
    });

    for (final next in _Format.values.where((value) => value != format)) {
      testWidgets('空行格式切换 $format → $next 不产生不可保存状态', (tester) async {
        final session = _session('');
        _apply(session.controller, format);
        expect(await session.flush(), isTrue, reason: '$format');
        _apply(session.controller, next);
        await tester.pump();
        expect(await session.flush(), isTrue, reason: '$format → $next');
        expect(MarkdownContent.hasVisibleContent(_encode(session)), isFalse);
      });
    }
  }

  for (final marker in ['-', '1.']) {
    for (final suffix in ['', ' ', '\t', '   ', '\t ']) {
      test('空列表 $marker ${suffix.codeUnits} 与独立阅读 AST 一致', () {
        final source = '$marker$suffix';
        final reading = md.Document().parseLines([source]);
        final list = reading.single as md.Element;
        expect(list.tag, marker == '-' ? 'ul' : 'ol');
        expect((list.children!.single as md.Element).tag, 'li');
        expect(list.textContent, isEmpty);
        final decoded = MarkdownDeltaCodec.decode(source);
        expect(
          decoded.delta.operations.last.attributes?['list'],
          marker == '-' ? 'bullet' : 'ordered',
        );
        expect(
          decoded.delta.operations
              .where((op) => op.data is String)
              .map((op) => op.data as String)
              .join(),
          '\n',
        );
        expect(MarkdownContent.hasVisibleContent(source), isFalse);
      });
    }
    testWidgets('正文后选择空 $marker 列表不把上一行变成标题', (tester) async {
      final session = _session('正文');
      session.controller.replaceText(
        2,
        0,
        '\n',
        const TextSelection.collapsed(offset: 3),
      );
      _apply(
        session.controller,
        marker == '-' ? _Format.bullet : _Format.ordered,
      );
      await tester.pump();
      expect(await session.flush(), isTrue);
      final saved = _encode(session);
      final reading = md.Document().parseLines(saved.split('\n'));
      expect((reading[0] as md.Element).tag, 'p');
      expect(reading[0].textContent, '正文');
      expect((reading[1] as md.Element).tag, marker == '-' ? 'ul' : 'ol');
      expect(reading[1].textContent, isEmpty);
      final reopened = _session(saved);
      expect(reopened.controller.document.toPlainText(), '正文\n\n');
      reopened.controller.updateSelection(
        const TextSelection.collapsed(offset: 3),
        ChangeSource.local,
      );
      expect(
        reopened.controller.getSelectionStyle().attributes['list']?.value,
        marker == '-' ? 'bullet' : 'ordered',
      );
    });

    testWidgets('$marker 已有列表回车创建空项、切换类型、取消仍保留文字与行数', (tester) async {
      final session = _session('$marker 正文');
      session.controller.replaceText(
        2,
        0,
        '\n',
        const TextSelection.collapsed(offset: 3),
      );
      await tester.pump();
      expect(await session.flush(), isTrue);
      final nodes = md.Document().parseLines(_encode(session).split('\n'));
      expect(_elements(nodes).where((node) => node.tag == 'li').length, 2);
      expect(
        _session(_encode(session)).controller.document.toPlainText(),
        '正文\n\n',
      );
      _apply(
        session.controller,
        marker == '-' ? _Format.ordered : _Format.bullet,
      );
      expect(await session.flush(), isTrue);
      _apply(session.controller, _Format.body);
      expect(await session.flush(), isTrue);
      expect(
        _session(_encode(session)).controller.document.toPlainText(),
        '正文\n\n',
      );
    });
  }

  for (final ordered in [false, true]) {
    final marker = ordered ? '1.' : '-';
    for (final depth in ordered ? [0] : [0, 1, 2]) {
      testWidgets('深度 $depth 的 $marker 列表末项删空、保存与续写', (tester) async {
        final source = [
          for (var level = 0; level <= depth; level++)
            '${'  ' * level}$marker 甲',
        ].join('\n');
        final session = _session(source);
        final position = depth * 2;
        session.controller.replaceText(
          position,
          1,
          '',
          TextSelection.collapsed(offset: position),
        );
        await tester.pump();
        expect(await session.flush(), isTrue);
        final saved = _encode(session);
        final reading = md.Document().parseLines(saved.split('\n'));
        final items = _elements(reading).where((node) => node.tag == 'li');
        expect(items.length, depth + 1);
        expect(items.last.textContent, isEmpty);
        final reopened = _session(saved);
        reopened.controller.updateSelection(
          TextSelection.collapsed(offset: position),
          ChangeSource.local,
        );
        expect(
          reopened.controller.getSelectionStyle().attributes['list']?.value,
          ordered ? 'ordered' : 'bullet',
        );
        expect(
          reopened.controller.getSelectionStyle().attributes['indent']?.value,
          depth == 0 ? isNull : depth,
        );
        reopened.controller.replaceText(
          position,
          0,
          '乙',
          TextSelection.collapsed(offset: position + 1),
        );
        await tester.pump();
        expect(await reopened.flush(), isTrue);
        expect(_encode(reopened), '${source.substring(0, source.length - 1)}乙');
      });
    }
  }

  for (final position in [0, 2]) {
    testWidgets('嵌套无序列表删空父项 $position 保留子项及所属层级', (tester) async {
      final session = _session('- 甲\n  - 乙\n    - 丙');
      session.controller.replaceText(
        position,
        1,
        '',
        TextSelection.collapsed(offset: position),
      );
      await tester.pump();
      expect(await session.flush(), isTrue);
      final saved = _encode(session);
      final items = _elements(
        md.Document().parseLines(saved.split('\n')),
      ).where((node) => node.tag == 'li').toList();
      expect(items, hasLength(3));
      expect(
        items[position ~/ 2].children!
            .where(
              (node) => node is! md.Element || !['ul', 'ol'].contains(node.tag),
            )
            .map((node) => node.textContent)
            .join()
            .trim(),
        isEmpty,
      );
      expect(items.last.textContent, '丙');
      for (var depth = 0; depth < 2; depth++) {
        final childList = items[depth].children!
            .whereType<md.Element>()
            .singleWhere((node) => node.tag == 'ul');
        expect(childList.children!.single, same(items[depth + 1]));
      }
      expect(
        _session(saved).controller.document.toPlainText(),
        position == 0 ? '\n乙\n丙\n' : '甲\n\n丙\n',
      );
    });
  }

  testWidgets('旧两空格有序缩进删空不得静默丢失阅读列表项', (tester) async {
    final session = _session('1. 甲\n  1. 乙\n    1. 丙');
    session.controller.replaceText(
      4,
      1,
      '',
      const TextSelection.collapsed(offset: 4),
    );
    await tester.pump();
    // 该历史缩进映射需要跨端契约调整；在此之前必须保留编辑内容并拒绝有损保存。
    expect(await session.flush(), isFalse);
    expect(session.controller.document.toPlainText(), '甲\n乙\n\n');
    expect(session.codecFailure, contains('列表层级'));
  });

  for (final format in _Format.values) {
    for (final mark in [
      Attribute.bold,
      Attribute.italic,
      Attribute.strikeThrough,
      Attribute.inlineCode,
    ]) {
      testWidgets('$format 与 ${mark.key} 空格式、输入、删空组合', (tester) async {
        final session = _session('');
        _apply(session.controller, format);
        WenyouEditorFormatPolicy.toggle(session.controller, mark);
        expect(await session.flush(), isTrue);
        expect(MarkdownContent.hasVisibleContent(_encode(session)), isFalse);
        session.controller.replaceText(
          0,
          0,
          '甲',
          const TextSelection.collapsed(offset: 1),
        );
        await tester.pump();
        expect(await session.flush(), isTrue);
        final saved = _encode(session);
        final nodes = _elements(
          md.Document(
            extensionSet: md.ExtensionSet.gitHubFlavored,
          ).parseLines(saved.split('\n')),
        );
        final tag = switch (mark.key) {
          'bold' => 'strong',
          'italic' => 'em',
          'strike' => 'del',
          _ => 'code',
        };
        expect(nodes.where((node) => node.tag == tag).single.textContent, '甲');
        session.controller.replaceText(
          0,
          1,
          '',
          const TextSelection.collapsed(offset: 0),
        );
        await tester.pump();
        expect(await session.flush(), isTrue);
        expect(MarkdownContent.hasVisibleContent(_encode(session)), isFalse);
      });
    }
  }
}

Iterable<md.Element> _elements(Iterable<md.Node> nodes) sync* {
  for (final node in nodes.whereType<md.Element>()) {
    yield node;
    yield* _elements(node.children ?? const []);
  }
}

RichEditorSession _session(String markdown) {
  final session = RichEditorSession(
    initialMarkdown: markdown,
    onMarkdownChanged: (_) {},
  );
  addTearDown(session.dispose);
  return session;
}

String _encode(RichEditorSession session) =>
    MarkdownDeltaCodec.encode(session.controller.document.toDelta());

void _apply(QuillController controller, _Format format) {
  switch (format) {
    case _Format.body:
      WenyouEditorFormatPolicy.applyHeading(controller, 0);
    case _Format.h2:
      WenyouEditorFormatPolicy.applyHeading(controller, 2);
    case _Format.h3:
      WenyouEditorFormatPolicy.applyHeading(controller, 3);
    case _Format.bullet:
      WenyouEditorFormatPolicy.toggle(controller, Attribute.ul);
    case _Format.ordered:
      WenyouEditorFormatPolicy.toggle(controller, Attribute.ol);
    case _Format.quote:
      WenyouEditorFormatPolicy.toggle(controller, Attribute.blockQuote);
    case _Format.center:
      WenyouEditorFormatPolicy.applyAlignment(
        controller,
        WenyouTextAlignment.center,
      );
    case _Format.right:
      WenyouEditorFormatPolicy.applyAlignment(
        controller,
        WenyouTextAlignment.right,
      );
  }
}

void _expectBlock(
  QuillController controller,
  _Format format, {
  required bool empty,
}) {
  final style = controller.getSelectionStyle().attributes;
  switch (format) {
    case _Format.h2 || _Format.h3:
      expect(style['header']?.value, format == _Format.h2 ? 2 : 3);
    case _Format.bullet || _Format.ordered:
      expect(
        style['list']?.value,
        format == _Format.bullet ? 'bullet' : 'ordered',
      );
    case _Format.quote:
      expect(style['blockquote']?.value, isTrue);
    case _Format.center || _Format.right:
      expect(style['align']?.value, empty ? isNull : format.name);
    case _Format.body:
      expect(style['header'], isNull);
      expect(style['list'], isNull);
      expect(style['blockquote'], isNull);
  }
}
