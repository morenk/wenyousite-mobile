import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';

void main() {
  const firstDiceId = '550e8400-e29b-41d4-a716-446655440000';
  const secondDiceId = '7c9e6679-7425-40de-944b-e07fc1f90ae7';

  test('复制多个骰子会全部生成新身份，其他协议节点不变', () {
    final store = WenyouEditorClipboardStore();
    final source = _protocolDelta(
      firstDiceId: firstDiceId,
      secondDiceId: secondDiceId,
    );
    final fallback = store.capture(
      delta: source,
      plainTextFallback: '备用文本',
      operation: WenyouEditorClipboardOperation.copy,
    );

    final resolution = store.resolve(fallback);

    expect(resolution.usePlainText, isFalse);
    final json = resolution.delta!.toJson();
    final ids = _diceIds(json);
    expect(ids, hasLength(2));
    expect(ids, isNot(contains(firstDiceId)));
    expect(ids, isNot(contains(secondDiceId)));
    expect(ids.toSet(), hasLength(2));
    expect(
      _payload(json, MarkdownDeltaCodec.mentionEmbed),
      _payload(source.toJson(), MarkdownDeltaCodec.mentionEmbed),
    );
    expect(
      _payload(json, MarkdownDeltaCodec.stickerEmbed),
      _payload(source.toJson(), MarkdownDeltaCodec.stickerEmbed),
    );
  });

  test('剪切多个骰子首次保留身份，重复粘贴时全部更新', () {
    var now = DateTime(2026, 8, 23, 12);
    final store = WenyouEditorClipboardStore(now: () => now);
    final source = _protocolDelta(
      firstDiceId: firstDiceId,
      secondDiceId: secondDiceId,
    );
    final fallback = store.capture(
      delta: source,
      plainTextFallback: '备用文本',
      operation: WenyouEditorClipboardOperation.cut,
    );

    final firstPaste = store.resolve(fallback).delta!;
    expect(_diceIds(firstPaste.toJson()), [firstDiceId, secondDiceId]);

    now = now.add(const Duration(seconds: 1));
    final secondPaste = store.resolve(fallback).delta!;
    final regenerated = _diceIds(secondPaste.toJson());
    expect(regenerated, hasLength(2));
    expect(regenerated, isNot(contains(firstDiceId)));
    expect(regenerated, isNot(contains(secondDiceId)));
    expect(regenerated.toSet(), hasLength(2));
  });

  test('内部剪贴板超时时只返回系统剪贴板纯文本', () {
    var now = DateTime(2026, 8, 23, 12);
    final store = WenyouEditorClipboardStore(now: () => now);
    final source = _protocolDelta(
      firstDiceId: firstDiceId,
      secondDiceId: secondDiceId,
    );
    final fallback = store.capture(
      delta: source,
      plainTextFallback: '备用文本',
      operation: WenyouEditorClipboardOperation.copy,
    );
    now = now.add(const Duration(minutes: 10, milliseconds: 1));

    final expired = store.resolve(fallback);

    expect(expired.delta, isNull);
    expect(expired.usePlainText, isTrue);
    final cleared = store.resolve(fallback);
    expect(cleared.delta, isNull);
    expect(cleared.usePlainText, isFalse);
  });

  test('系统剪贴板内容不匹配时不复用旧的结构化载荷', () {
    final store = WenyouEditorClipboardStore();
    final fallback = store.capture(
      delta: _protocolDelta(
        firstDiceId: firstDiceId,
        secondDiceId: secondDiceId,
      ),
      plainTextFallback: '备用文本',
      operation: WenyouEditorClipboardOperation.copy,
    );

    final mismatch = store.resolve('用户在其他应用复制的内容');
    expect(mismatch.delta, isNull);
    expect(mismatch.usePlainText, isFalse);

    final cleared = store.resolve(fallback);
    expect(cleared.delta, isNull);
    expect(cleared.usePlainText, isFalse);
  });

  test('非法结构化载荷在粘贴时降级为纯文本', () {
    final store = WenyouEditorClipboardStore();
    final invalid = Delta()
      ..insert({
        'unknown_embed': {'version': 1, 'raw': '不可编码'},
      });
    const fallback = '可安全粘贴的文本';
    final captured = store.capture(
      delta: invalid,
      plainTextFallback: fallback,
      operation: WenyouEditorClipboardOperation.copy,
    );

    expect(captured, fallback);
    final resolution = store.resolve(fallback);
    expect(resolution.delta, isNull);
    expect(resolution.usePlainText, isTrue);
  });
}

Delta _protocolDelta({
  required String firstDiceId,
  required String secondDiceId,
}) => Delta()
  ..insert({
    MarkdownDeltaCodec.diceEmbed: {
      'version': 1,
      'nodeId': firstDiceId,
      'notation': '2d6+1',
    },
  })
  ..insert(' ')
  ..insert({
    MarkdownDeltaCodec.mentionEmbed: {
      'version': 1,
      'kind': 'user',
      'userId': 'user-zhang',
      'label': '@张三',
    },
  })
  ..insert(' ')
  ..insert({
    MarkdownDeltaCodec.diceEmbed: {
      'version': 1,
      'nodeId': secondDiceId,
      'notation': '1d20',
    },
  })
  ..insert(' ')
  ..insert({
    MarkdownDeltaCodec.stickerEmbed: {
      'version': 1,
      'assetId': 'cm1234567890123456789012',
      'url': 'https://cdn.example.com/stickers/a.webp',
      'alt': '表情',
    },
  });

List<String> _diceIds(List<Map<String, dynamic>> json) => json
    .map((operation) => operation['insert'])
    .whereType<Map>()
    .map((insert) => insert[MarkdownDeltaCodec.diceEmbed])
    .whereType<Map>()
    .map((payload) => payload['nodeId'])
    .whereType<String>()
    .toList(growable: false);

Map? _payload(List<Map<String, dynamic>> json, String embedType) => json
    .map((operation) => operation['insert'])
    .whereType<Map>()
    .map((insert) => insert[embedType])
    .whereType<Map>()
    .firstOrNull;
