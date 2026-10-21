import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_semantics.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_atomic_text_editor.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/markdown-text-color-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final results = <Map<String, Object?>>[];
  test('普通 https 链接保持可编辑与颜色，既有 title/相对链接保源', () async {
    const source =
        '<span data-wenyou-color-v1="#123456">[网站](https://example.com)</span>';
    final session = RichEditorSession(
      initialMarkdown: source,
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    expect(session.isSourceProtected, isFalse);
    session.controller.formatText(0, 2, Attribute.bold);
    expect(await session.flush(), isTrue);
    final attributes = MarkdownDeltaCodec.decode(
      session.localMarkdown,
    ).delta.operations.first.attributes!;
    expect(attributes['link'], 'https://example.com');
    expect(attributes['color'], '#123456');
    expect(attributes['bold'], isTrue);
    for (final link in ['[网站](https://example.com "标题")', '[网站](/about)']) {
      for (final input in [
        link,
        '<span data-wenyou-color-v1="#123456">$link</span>',
      ]) {
        final protected = RichEditorSession(
          initialMarkdown: input,
          onMarkdownChanged: (_) {},
        );
        addTearDown(protected.dispose);
        if (protected.isSourceProtected) {
          expect(protected.canCloseProtectedSource, isTrue);
        } else {
          expect(await protected.flush(), isTrue);
        }
        expect(protected.localMarkdown, input);
      }
    }
  });
  test('动态与私信使用的原子文本编辑器不识别颜色格式', () {
    const source = '<span data-wenyou-color-v1="#123456">文字</span>';
    final controller = WenyouAtomicTextController(
      initialMarkdown: source,
      maximumMarkdownLength: 1000,
    );
    addTearDown(controller.dispose);
    expect(controller.quillController.document.toPlainText(), '$source\n');
    expect(
      controller.quillController.document.toDelta().operations.every(
        (op) => op.attributes?['color'] == null,
      ),
      isTrue,
    );
    controller.quillController.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 4),
      ChangeSource.local,
    );
  });
  for (final item in fixture['validCases'] as List) {
    test('真实编辑会话无操作保存并重开 ${item['id']}', () async {
      final source = item['source'] as String;
      final session = RichEditorSession(
        initialMarkdown: source,
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      final saved = session.localMarkdown;
      expect(
        MarkdownDeltaSemantics.equivalent(
          session.controller.document.toDelta(),
          MarkdownDeltaCodec.decode(saved).delta,
        ),
        isTrue,
      );
      final reopened = RichEditorSession(
        initialMarkdown: saved,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(await reopened.flush(), isTrue);
      expect(reopened.localMarkdown, saved);
      results.add({'id': item['id'], 'source': source, 'saved': saved});
    });
  }
  const importPath = String.fromEnvironment('TEXT_COLOR_IMPORT');
  if (importPath.isNotEmpty) {
    final imported = jsonDecode(File(importPath).readAsStringSync());
    final cases = imported is List ? imported : imported['cases'] as List;
    for (var index = 0; index < cases.length; index++) {
      final item = cases[index] as Map<String, dynamic>;
      test('Web 实际保存产物复读 $index', () async {
        final original = MarkdownDeltaCodec.decode(item['source'] as String);
        final session = RichEditorSession(
          initialMarkdown: item['saved'] as String,
          onMarkdownChanged: (_) {},
        );
        addTearDown(session.dispose);
        expect(
          MarkdownDeltaSemantics.equivalent(
            original.delta,
            session.controller.document.toDelta(),
          ),
          isTrue,
          reason: '跨运行时的可见文字、块与格式应保持',
        );
        expect(await session.flush(), isTrue, reason: session.codecFailure);
        expect(
          MarkdownDeltaSemantics.equivalent(
            original.delta,
            MarkdownDeltaCodec.decode(session.localMarkdown).delta,
          ),
          isTrue,
        );
      });
    }
  }
  tearDownAll(() {
    if (!const bool.fromEnvironment('TEXT_COLOR_EXPORT')) return;
    const sha = String.fromEnvironment('CANDIDATE_SHA');
    expect(sha, matches(r'^[0-9a-f]{40}$'));
    final output = File('build/mobile-text-color-roundtrip.json');
    output.parent.createSync(recursive: true);
    output.writeAsStringSync(
      jsonEncode({
        'version': 1,
        'producer': 'mobile',
        'producerCommit': sha,
        'cases': results,
      }),
    );
  });
}
