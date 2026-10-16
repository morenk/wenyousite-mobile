import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_link_identity.dart';
import 'package:wenyousite_mobile/features/editor/presentation/literal_text_quill_controller.dart';

import '../../support/inline_combination_assertions.dart';

const _url = 'https://example.invalid/audio.mp3';
const _other = 'https://example.invalid/other.mp3';

void main() {
  for (final offset in [0, 1, 2]) {
    test('原链接首中尾续写保持一个来源且一次撤销重做 $offset', () {
      final controller = _controller('[**甲乙**]($_url)');
      addTearDown(controller.dispose);
      _type(controller, offset, 0, '新', bold: true);
      final expected = '甲乙'.replaceRange(offset, offset, '新');
      expect(_links(controller).map((link) => link.textContent), [expected]);
      expect(inlineReadingUnits(_nodes(controller)), [
        for (final text in expected.split(''))
          {
            'text': text,
            'marks': {'bold': true, 'link': _url},
          },
      ]);
      _undoRedo(controller, '甲乙\n', '$expected\n');
      expect(_links(controller), hasLength(1));
    });
  }

  test('同一链接跨 marks 的选区替换仍保留原来源', () {
    final controller = _controller('[甲**乙丙**丁]($_url)');
    addTearDown(controller.dispose);
    _type(controller, 1, 2, '新', bold: true);
    expect(_links(controller).map((link) => link.textContent), ['甲新丁']);
    _undoRedo(controller, '甲乙丙丁\n', '甲新丁\n');
    expect(_links(controller), hasLength(1));
  });

  for (final rightUrl in [_url, _other]) {
    test('两个原链接交界续写不覆盖来源 ${rightUrl == _url}', () {
      final controller = _controller('[甲]($_url)[乙]($rightUrl)');
      addTearDown(controller.dispose);
      _type(controller, 1, 0, '新');
      final links = _links(controller);
      expect(
        links.map((link) => link.textContent),
        rightUrl == _url ? ['甲', '新', '乙'] : ['甲新', '乙'],
      );
      expect(links.last.attributes['href'], rightUrl);
      _undoRedo(controller, '甲乙\n', '甲新乙\n');
    });
  }

  test('跨两个同 URL 原链接的替换不继承任一来源', () {
    final controller = _controller('[甲乙]($_url)[丙丁]($_url)');
    addTearDown(controller.dispose);
    _type(controller, 1, 2, '新');
    expect(_links(controller).map((link) => link.textContent), ['甲', '新', '丁']);
    _undoRedo(controller, '甲乙丙丁\n', '甲新丁\n');
  });

  test('显式改 URL 的输入不冒用相邻链接来源', () {
    final controller = _controller('[甲乙]($_url)');
    addTearDown(controller.dispose);
    _type(controller, 1, 0, '新', url: _other);
    final links = _links(controller);
    expect(links.map((link) => link.attributes['href']), [_url, _other, _url]);
    final inserted = controller.document.toDelta().operations.firstWhere(
      (operation) => operation.data == '新',
    );
    expect(inserted.attributes?[markdownLinkIdentityKey], isNull);
  });

  for (final pasteIdentity in [null, 'external']) {
    test('结构化粘贴保留外来来源边界 $pasteIdentity', () {
      final controller = _controller('[甲]($_url)');
      addTearDown(controller.dispose);
      controller.replaceText(
        1,
        0,
        Delta()..insert('新', {
          'link': _url,
          markdownLinkIdentityKey: ?pasteIdentity,
        }),
        const TextSelection.collapsed(offset: 2),
      );
      expect(_links(controller).map((link) => link.textContent), ['甲', '新']);
      _undoRedo(controller, '甲\n', '甲新\n');
    });
  }

  for (final identities in [(null, 'known'), ('known', null), (null, null)]) {
    test('外来 Delta 续写不猜测 null 与已知来源 $identities', () {
      final controller = LiteralTextQuillController(
        document: Document.fromDelta(
          Delta()
            ..insert('甲', {
              'link': _url,
              markdownLinkIdentityKey: ?identities.$1,
            })
            ..insert('乙', {
              'link': _url,
              markdownLinkIdentityKey: ?identities.$2,
            })
            ..insert('\n'),
        ),
        selection: const TextSelection.collapsed(offset: 1),
        config: const QuillControllerConfig(),
      );
      addTearDown(controller.dispose);
      _type(controller, 1, 0, '新');
      expect(
        _links(controller).map((link) => link.textContent),
        identities.$1 == identities.$2
            ? ['甲新乙']
            : identities.$1 == null
            ? ['甲新', '乙']
            : ['甲', '新乙'],
      );
    });
  }
}

LiteralTextQuillController _controller(String markdown) =>
    LiteralTextQuillController(
      document: Document.fromDelta(MarkdownDeltaCodec.decode(markdown).delta),
      selection: const TextSelection.collapsed(offset: 0),
      config: const QuillControllerConfig(),
    );

void _type(
  LiteralTextQuillController controller,
  int offset,
  int length,
  String text, {
  String url = _url,
  bool bold = false,
}) {
  controller.updateSelection(
    TextSelection(baseOffset: offset, extentOffset: offset + length),
    ChangeSource.local,
  );
  controller.toggledStyle = Style.attr({
    'link': Attribute.fromKeyValue('link', url)!,
    'bold': Attribute.fromKeyValue('bold', bold ? true : null)!,
  });
  controller.replaceText(
    offset,
    length,
    text,
    TextSelection.collapsed(offset: offset + text.length),
  );
}

void _undoRedo(
  LiteralTextQuillController controller,
  String before,
  String after,
) {
  expect(controller.document.history.stack.undo, hasLength(1));
  final selection = controller.selection;
  controller.undo();
  expect(controller.document.toPlainText(), before);
  expect(controller.document.history.stack.undo, isEmpty);
  controller.redo();
  expect(controller.document.toPlainText(), after);
  expect(controller.selection, selection);
}

List<md.Node> _nodes(LiteralTextQuillController controller) {
  final markdown = MarkdownDeltaCodec.encode(controller.document.toDelta());
  return md.Document(
    extensionSet: md.ExtensionSet.gitHubFlavored,
    encodeHtml: false,
  ).parseLines(markdown.split('\n'));
}

List<md.Element> _links(LiteralTextQuillController controller) {
  final links = <md.Element>[];
  void visit(md.Node node) {
    if (node is! md.Element) return;
    if (node.tag == 'a') links.add(node);
    for (final child in node.children ?? <md.Node>[]) {
      visit(child);
    }
  }

  _nodes(controller).forEach(visit);
  return links;
}
