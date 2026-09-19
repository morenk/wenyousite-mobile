import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

const _keys = ['bold', 'italic', 'strike', 'code', 'link'];

String verifyInlineCombination(List<(String, Map<String, Object>)> segments) {
  final delta = Delta();
  final expected = <Object>[];
  for (final (text, marks) in segments) {
    delta.insert(text, {
      ...marks,
      MarkdownDeltaCodec.literalTextAttribute: true,
    });
    expected.addAll(
      text.runes.map(
        (rune) => {'text': String.fromCharCode(rune), 'marks': marks},
      ),
    );
  }
  delta.insert('\n');
  final encoded = MarkdownDeltaCodec.encode(delta);
  // 独立整段 CommonMark 阅读 AST 同时检查块级缩进与行内样式。
  final nodes = md.Document(
    extensionSet: md.ExtensionSet.gitHubFlavored,
    encodeHtml: false,
  ).parseLines(encoded.split('\n'));
  expect(inlineReadingUnits(nodes), expected, reason: encoded);
  final reopened = MarkdownDeltaCodec.decode(encoded).delta;
  final actual = <Object>[];
  for (final op in reopened.operations) {
    if (op.data is! String) continue;
    final text = (op.data as String).replaceAll('\n', '');
    final marks = <String, Object>{
      for (final key in _keys)
        if (op.attributes?[key] != null) key: op.attributes![key] as Object,
    };
    actual.addAll(
      text.runes.map(
        (rune) => {'text': String.fromCharCode(rune), 'marks': marks},
      ),
    );
  }
  expect(actual, expected, reason: encoded);
  expect(MarkdownDeltaCodec.encode(reopened), encoded);
  return encoded;
}

List<Object> inlineReadingUnits(
  List<md.Node> nodes, [
  Map<String, Object> marks = const {},
]) {
  final result = <Object>[];
  for (final node in nodes) {
    if (node is md.Text) {
      result.addAll(
        node.text.runes.map(
          (rune) => {'text': String.fromCharCode(rune), 'marks': marks},
        ),
      );
    } else if (node is md.Element) {
      final key = switch (node.tag) {
        'strong' => 'bold',
        'em' => 'italic',
        'del' => 'strike',
        'code' => 'code',
        'a' => 'link',
        _ => null,
      };
      result.addAll(
        inlineReadingUnits(node.children ?? [], {
          ...marks,
          ?key: key == 'link' ? node.attributes['href']! : true,
        }),
      );
    }
  }
  return result;
}
