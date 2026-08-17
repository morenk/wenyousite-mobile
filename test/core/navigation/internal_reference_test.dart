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
}
