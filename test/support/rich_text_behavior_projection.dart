import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/quill_delta.dart';

typedef BehaviorJson = Map<String, Object?>;

/// 从实际 Delta 投影测试契约，不调用 Codec 或读取 fixture 预期。
class RichTextBehaviorProjection {
  RichTextBehaviorProjection(Delta delta) {
    final lines = <_Line>[];
    var line = _Line(0);
    var offset = 0;
    for (final operation in delta.operations) {
      final data = operation.data;
      if (data is! String) {
        line.children.add(_atom(data));
        offset++;
        continue;
      }
      final parts = data.split('\n');
      for (var index = 0; index < parts.length; index++) {
        final text = parts[index];
        if (text.isNotEmpty) {
          final marks = <String, Object?>{
            for (final name in ['bold', 'italic', 'strike', 'code', 'link'])
              if (operation.attributes?[name] != null &&
                  operation.attributes?[name] != false)
                name: operation.attributes![name],
          };
          _append(line.children, {
            'type': 'text',
            'text': text,
            'marks': marks,
          });
          offset += text.length;
        }
        if (index + 1 < parts.length) {
          line.attributes = Map<String, Object?>.from(
            operation.attributes ?? const {},
          );
          line.end = offset;
          lines.add(line);
          line = _Line(++offset);
        }
      }
    }
    if (line.children.isNotEmpty) {
      line.end = offset;
      lines.add(line);
    }
    _Line? previous;
    _Leaf? leaf;
    List<BehaviorJson>? quote;
    for (final current in lines) {
      if (current.attributes['wenyou_source_separator'] == true) {
        previous = null;
        leaf = null;
        quote = null;
        continue;
      }
      final isQuote = current.attributes['blockquote'] == true;
      if (!isQuote) quote = null;
      if (isQuote && quote == null) {
        quote = [];
        blocks.add({'type': 'blockquote', 'children': quote});
        previous = null;
        leaf = null;
      }
      final join =
          previous != null &&
          leaf != null &&
          previous.children.isNotEmpty &&
          current.children.isNotEmpty &&
          previous.attributes['blockquote'] ==
              current.attributes['blockquote'] &&
          previous.attributes['header'] == null &&
          current.attributes['header'] == null &&
          previous.attributes['wenyou_paragraph_separators'] == null &&
          previous.attributes['wenyou_quote_separators'] == null;
      if (join) {
        leaf.children.add({'type': 'softBreak'});
        for (final child in current.children) {
          _append(leaf.children, child);
        }
        leaf.end = current.end;
      } else {
        final target = quote ?? blocks;
        final path = isQuote
            ? [blocks.length - 1, target.length]
            : [target.length];
        final children = [...current.children];
        target.add({
          'type': current.attributes['header'] == null
              ? 'paragraph'
              : 'heading',
          if (current.attributes['header'] != null)
            'level': current.attributes['header'],
          'alignment': current.attributes['align'] ?? 'left',
          'children': children,
        });
        leaf = _Leaf(path, current.start, current.end, children);
        _leaves.add(leaf);
      }
      previous = current;
    }
  }

  final blocks = <BehaviorJson>[];
  final _leaves = <_Leaf>[];
  BehaviorJson get summary => {'blocks': blocks};

  TextSelection decodeSelection(BehaviorJson selection) => TextSelection(
    baseOffset: _offset(selection['anchor']! as BehaviorJson),
    extentOffset: _offset(selection['focus']! as BehaviorJson),
  );

  BehaviorJson encodeSelection(TextSelection selection) => {
    'anchor': _position(selection.baseOffset),
    'focus': _position(selection.extentOffset),
  };

  int _offset(BehaviorJson position) {
    final path = (position['path']! as List).cast<int>();
    final leaf = _leaves.singleWhere((leaf) => listEquals(leaf.path, path));
    final offset = position['offset']! as int;
    if (offset < 0 || leaf.start + offset > leaf.end) {
      throw StateError('测试选区超出指定块');
    }
    return leaf.start + offset;
  }

  BehaviorJson _position(int offset) {
    final leaf = _leaves.singleWhere(
      (leaf) => offset >= leaf.start && offset <= leaf.end,
    );
    return {'path': leaf.path, 'offset': offset - leaf.start};
  }

  static void _append(List<BehaviorJson> children, BehaviorJson child) {
    if (child['type'] == 'text' &&
        children.isNotEmpty &&
        children.last['type'] == 'text' &&
        mapEquals(
          children.last['marks']! as BehaviorJson,
          child['marks']! as BehaviorJson,
        )) {
      children.last['text'] = '${children.last['text']}${child['text']}';
    } else {
      children.add(Map.of(child));
    }
  }

  static BehaviorJson _atom(Object? data) {
    final atom = Map<String, Object?>.from(data! as Map);
    final payload = Map<String, Object?>.from(atom.values.single! as Map);
    return switch (atom.keys.single) {
      'wenyou_dice' => {
        'type': 'dice',
        'nodeId': payload['nodeId'],
        'notation': payload['notation'],
      },
      'wenyou_mention' => {
        'type': payload['kind'] == 'all_players' ? 'mentionAll' : 'mention',
        if (payload['kind'] != 'all_players') 'userId': payload['userId'],
        'label': payload['label'],
      },
      'wenyou_sticker' => {
        'type': 'sticker',
        'assetId': payload['assetId'],
        'url': payload['url'],
        'alt': payload['alt'] ?? '表情',
      },
      'wenyou_image' => {
        'type': 'image',
        'url': payload['url'],
        'alt': payload['alt'],
        'title': payload['title'],
      },
      _ => throw StateError('尚未支持的测试原子投影：${atom.keys.single}'),
    };
  }
}

class _Line {
  _Line(this.start);
  final int start;
  int end = 0;
  final children = <BehaviorJson>[];
  BehaviorJson attributes = {};
}

class _Leaf {
  _Leaf(this.path, this.start, this.end, this.children);
  final List<int> path;
  final int start;
  int end;
  final List<BehaviorJson> children;
}
