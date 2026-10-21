import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_reader_paragraph_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_color.dart';

const textColorMarkKeys = ['bold', 'italic', 'strike', 'code', 'link', 'color'];
typedef ColorSegment = (String, Map<String, Object>);

Map<String, Object> textColorMarks(int mask, [String? color = '#D14343']) => {
  'color': ?color,
  for (var index = 0; index < 5; index++)
    if (mask & (1 << index) != 0)
      textColorMarkKeys[index]: index == 4 ? 'https://example.com/a' : true,
};

List<Object> colorExpectedUnits(List<ColorSegment> segments) => [
  for (final (text, marks) in segments)
    for (final rune in text.runes)
      {'text': String.fromCharCode(rune), 'marks': marks},
];

List<Object> colorDeltaUnits(Delta delta) => [
  for (final op in delta.operations)
    if (op.data is String)
      for (final rune in (op.data as String).replaceAll('\n', '').runes)
        {
          'text': String.fromCharCode(rune),
          'marks': {
            for (final key in textColorMarkKeys)
              if (op.attributes?[key] != null) key: op.attributes![key],
          },
        },
];

List<md.Node> colorReaderNodes(String source) => md.Document(
  blockSyntaxes: const [MarkdownReaderParagraphSyntax()],
  inlineSyntaxes: [MarkdownTextColorSyntax()],
  extensionSet: md.ExtensionSet.gitHubFlavored,
  encodeHtml: false,
).parseLines(source.split('\n'));

List<Object> colorReaderUnits(
  List<md.Node> nodes, [
  Map<String, Object> marks = const {},
]) => [
  for (final node in nodes)
    if (node is md.Text)
      for (final rune in node.text.runes)
        {'text': String.fromCharCode(rune), 'marks': marks}
    else if (node is md.Element)
      ...colorReaderUnits(node.children ?? [], {
        ...marks,
        if (node.tag == 'strong') 'bold': true,
        if (node.tag == 'em') 'italic': true,
        if (node.tag == 'del') 'strike': true,
        if (node.tag == 'code') 'code': true,
        if (node.tag == 'a') 'link': node.attributes['href']!,
        if (node.tag == MarkdownTextColor.tag)
          'color': node.attributes['color']!,
      }),
];

String verifyColorSegments(
  List<ColorSegment> segments, {
  List<ColorSegment>? expected,
}) {
  final delta = Delta();
  for (final (text, marks) in segments) {
    delta.insert(text, {
      ...marks,
      MarkdownDeltaCodec.literalTextAttribute: true,
    });
  }
  delta.insert('\n');
  final saved = MarkdownDeltaCodec.encode(delta);
  final units = colorExpectedUnits(expected ?? segments);
  final nodes = colorReaderNodes(saved);
  expect(nodes.single, isA<md.Element>());
  expect((nodes.single as md.Element).tag, 'p');
  expect(colorReaderUnits(nodes), units, reason: saved);
  final reopened = MarkdownDeltaCodec.decode(saved).delta;
  expect(colorDeltaUnits(reopened), units, reason: saved);
  expect(MarkdownDeltaCodec.encode(reopened), saved);
  return saved;
}
