import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown_body.dart';

import 'rich_text_behavior_projection.dart';

/// 使用已挂载阅读组件实际数据和语法配置，独立于 Delta/Codec。
BehaviorJson projectReader(Iterable<WenyouMarkdownBody> bodies) => {
  'blocks': [
    for (final body in bodies)
      ..._blocks(
        md.Document(
          blockSyntaxes: body.blockSyntaxes,
          inlineSyntaxes: body.inlineSyntaxes,
          extensionSet: body.extensionSet ?? md.ExtensionSet.gitHubFlavored,
          encodeHtml: false,
        ).parse(body.data),
        switch (body.styleSheet?.textAlign) {
          WrapAlignment.center => 'center',
          WrapAlignment.end => 'right',
          _ => 'left',
        },
      ),
  ],
};

List<BehaviorJson> _blocks(List<md.Node> nodes, String alignment) {
  final result = <BehaviorJson>[];
  for (final node in nodes) {
    if (node is! md.Element) throw StateError('阅读块必须有结构');
    if (node.tag == 'blockquote') {
      result.add({
        'type': 'blockquote',
        'children': _blocks(node.children ?? [], alignment),
      });
      continue;
    }
    if (node.tag == 'wenyou-empty-paragraph') {
      result.add({
        'type': 'paragraph',
        'alignment': alignment,
        'children': <BehaviorJson>[],
      });
      continue;
    }
    if (node.tag != 'p' && !RegExp(r'^h[1-6]$').hasMatch(node.tag)) {
      throw StateError('尚未支持的阅读块 ${node.tag}');
    }
    var children = <BehaviorJson>[];
    void appendBlock() {
      result.add({
        'type': node.tag == 'p' ? 'paragraph' : 'heading',
        if (node.tag != 'p') 'level': int.parse(node.tag.substring(1)),
        'alignment': alignment,
        'children': children,
      });
    }

    for (final child in node.children ?? <md.Node>[]) {
      // 阅读布局把显式空段压成 br；文本内 LF 仍是同一段软换行。
      if (child is md.Element && child.tag == 'br') {
        appendBlock();
        children = [];
      } else {
        for (final inline in _inline(child, const {})) {
          if (inline['type'] == 'text' &&
              children.isNotEmpty &&
              children.last['type'] == 'text' &&
              mapEquals(
                children.last['marks'] as BehaviorJson,
                inline['marks'] as BehaviorJson,
              )) {
            children.last['text'] = '${children.last['text']}${inline['text']}';
          } else {
            children.add(inline);
          }
        }
      }
    }
    appendBlock();
  }
  return result;
}

Iterable<BehaviorJson> _inline(md.Node node, BehaviorJson marks) sync* {
  if (node is md.Text) {
    final rows = node.text.split('\n');
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) yield {'type': 'softBreak'};
      if (rows[i].isNotEmpty) {
        yield {'type': 'text', 'text': rows[i], 'marks': marks};
      }
    }
    return;
  }
  final element = node as md.Element;
  final attributes = element.attributes;
  switch (element.tag) {
    case 'wenyou-dice':
      yield {
        'type': 'dice',
        'nodeId': attributes['node-id'],
        'notation': element.textContent,
      };
    case 'wenyou-mention':
      final location = attributes['location'];
      yield {
        'type': location == null ? 'mentionAll' : 'mention',
        if (location != null) 'userId': location.substring('/users/'.length),
        'label': element.textContent,
      };
    case 'img':
      final title = attributes['title'];
      final sticker = title?.startsWith('wenyousite-sticker:v1:') == true;
      yield {
        'type': sticker ? 'sticker' : 'image',
        if (sticker)
          'assetId': title!.substring('wenyousite-sticker:v1:'.length),
        'url': attributes['src'],
        'alt': attributes['alt'] ?? '',
        if (!sticker) 'title': title ?? '',
      };
    default:
      final next = Map<String, Object?>.of(marks);
      final name = switch (element.tag) {
        'strong' => 'bold',
        'em' => 'italic',
        'del' => 'strike',
        'code' => 'code',
        'a' => 'link',
        _ => throw StateError('尚未支持的阅读行内节点 ${element.tag}'),
      };
      next[name] = name == 'link' ? attributes['href'] : true;
      for (final child in element.children ?? <md.Node>[]) {
        yield* _inline(child, next);
      }
  }
}
