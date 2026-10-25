import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_write_guard.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/markdown-text-font-v2-fixtures.json',
            ).readAsStringSync(),
          )
          as Map;
  for (final row in fixture['validCases'] as List) {
    test('v2 正式保源 ${row['id']}', () {
      final decoded = MarkdownDeltaCodec.decode(row['source'] as String).delta;
      expect(decoded.operations.every((op) => op.data is String), isTrue);
      expect(
        decoded.operations.where(
          (op) =>
              op.attributes?['font'] == 'tfv_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        ),
        isNotEmpty,
      );
      final saved = MarkdownDeltaCodec.encode(decoded);
      expect(saved, row['canonical']);
      expect(
        MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(saved).delta),
        saved,
      );
    });
  }
  for (final source in fixture['invalidSources'] as List) {
    test('不将非法 v2 span 冒认为合法字体：$source', () {
      final delta = MarkdownDeltaCodec.decode(source as String).delta;
      expect(
        delta.operations.where((op) => op.attributes?['font'] != null),
        isEmpty,
      );
    });
  }
  test('未知合法 ID 无目录仍保留文字、颜色、粗体和段落边界', () {
    const id = 'tfv_1234567890abcdef1234567890abcdef';
    const source =
        '<span data-wenyou-font-v2="$id" data-wenyou-color-v1="#D14343">**新字**</span>\n\n后段';
    final delta = MarkdownDeltaCodec.decode(source).delta;
    final text = delta.operations
        .where((op) => op.data is String)
        .map((op) => op.data)
        .join();
    expect(text, contains('新字'));
    expect(text, contains('后段'));
    final op = delta.operations.firstWhere(
      (op) => op.attributes?['font'] == id,
    );
    expect(op.data, '新字');
    expect(op.attributes?['bold'], true);
    expect(op.attributes?['color'], '#D14343');
    expect(MarkdownDeltaCodec.encode(delta), source);
    expect(
      () => requireTextFontWriteSupport(source, supported: true),
      throwsA(isA<ApiFailure>()),
    );
    expect(
      () => requireTextFontWriteSupport(
        source,
        supported: true,
        v2Supported: true,
      ),
      returnsNormally,
    );
  });
}
