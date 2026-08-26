import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/internal-reference-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;

  test('完整消费站内传送门 v1 识别与规范化黄金用例', () {
    final cases = fixture['cases']! as List<Object?>;
    for (final rawCase in cases) {
      final testCase = rawCase! as Map<String, Object?>;
      final reference = parseInternalReference(testCase['input']! as String);
      if (testCase['recognized']! as bool) {
        expect(reference, isNotNull, reason: testCase['id']! as String);
        expect(
          reference!.kind.name.toUpperCase(),
          testCase['kind'],
          reason: testCase['id']! as String,
        );
        expect(
          reference.location.toString(),
          testCase['canonical'],
          reason: testCase['id']! as String,
        );
      } else {
        expect(reference, isNull, reason: testCase['id']! as String);
      }
    }
  });

  test('完整消费纯文本渲染黄金用例且不激活普通 Markdown 和外链', () {
    final cases = fixture['renderingCases']! as List<Object?>;
    for (final rawCase in cases) {
      final testCase = rawCase! as Map<String, Object?>;
      final source = testCase['source']! as String;
      final segments = tokenizeInternalReferenceText(source);
      expect(
        formatInternalReferencePreview(source),
        testCase['visibleText'],
        reason: testCase['id']! as String,
      );
      expect(
        segments.whereType<InternalReferencePortal>().length,
        testCase['portalCount'],
        reason: testCase['id']! as String,
      );
    }
  });

  test('完整消费编辑器粘贴黄金用例', () {
    final cases = fixture['editorPasteCases']! as List<Object?>;
    for (final rawCase in cases) {
      final testCase = rawCase! as Map<String, Object?>;
      final paste = resolveInternalReferencePaste(
        clipboardText: testCase['clipboardText']! as String,
        selectedText: testCase['selectedText']! as String,
      );
      final handled = testCase['handled']! as bool;
      if (!handled) {
        expect(paste, isNull, reason: testCase['id']! as String);
        continue;
      }
      expect(paste, isNotNull, reason: testCase['id']! as String);
      expect(
        paste!.reference.kind.name.toUpperCase(),
        testCase['kind'],
        reason: testCase['id']! as String,
      );
      expect(paste.reference.location.toString(), testCase['canonical']);
      expect(paste.label, testCase['label']);
      expect(paste.serialized, testCase['serialized']);
    }
  });

  test('历史 URL 自标签只在显示时归一为传送门', () {
    final reference = parseInternalReference('/join/AbCdEfGh_123-XYZ')!;

    expect(
      resolveInternalReferenceLabel(
        label: 'https://wenyou.site/join/AbCdEfGh_123-XYZ',
        reference: reference,
      ),
      internalReferenceDefaultLabel,
    );
    expect(
      resolveInternalReferenceLabel(label: '私密团入口', reference: reference),
      '私密团入口',
    );
    expect(
      formatInternalReferencePreview(
        '查看 [https://www.wenyou.site/join/AbCdEfGh_123-XYZ]'
        '(/join/AbCdEfGh_123-XYZ)',
      ),
      '查看 传送门',
    );
  });

  test('选区恰好是同一站内坐标时不会继续充当传送门名称', () {
    final paste = resolveInternalReferencePaste(
      clipboardText: 'https://wenyou.site/join/AbCdEfGh_123-XYZ',
      selectedText: '/join/AbCdEfGh_123-XYZ',
    );

    expect(paste, isNotNull);
    expect(paste!.label, internalReferenceDefaultLabel);
    expect(paste.serialized, '[传送门](/join/AbCdEfGh_123-XYZ)');
  });
}
