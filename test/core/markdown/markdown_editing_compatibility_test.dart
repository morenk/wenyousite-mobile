import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editing_compatibility.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/rich-text-behavior-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  final profiles = fixture['profiles']! as Map<String, Object?>;
  for (final raw in fixture['compatibilityCases']! as List) {
    final item = raw as Map<String, Object?>;
    test('共享读建改能力 ${item['id']}', () {
      final profile = profiles[item['profile']] as Map<String, Object?>?;
      final features = (profile?['features'] as List?)?.cast<String>() ?? [];
      final actual = MarkdownEditingCompatibility.assess(
        item['markdown']! as String,
        knownProfile: profile != null,
        blockAlignment: features.contains('block-alignment'),
        imageAlignment: features.contains('image-alignment'),
        quoteEmptyRows: features.contains('quote-empty-row'),
        lossless: item['lossless']! as bool,
      );
      expect({
        'read': actual.read,
        'create': actual.create,
        'edit': actual.edit,
        'reason': actual.reason,
      }, item['expected']);
    });
  }

  for (final source in [
    '甲 [[widget:v9:future]]',
    '甲 <span>乙</span>',
    '[wenyousite-align-v9-center]: #\n甲',
    '[[dice:v1:invalid:1d20]]',
  ]) {
    testWidgets('未知和损坏原文只读，外部解锁不能绕过保护：$source', (tester) async {
      final emitted = <String>[];
      final session = RichEditorSession(
        initialMarkdown: source,
        onMarkdownChanged: emitted.add,
      );
      addTearDown(session.dispose);
      final original = session.controller.document.toDelta().toJson();
      session.readOnly = false;
      expect(session.controller.readOnly, isTrue);
      expect(session.canCloseProtectedSource, isTrue);
      expect(await session.flush(), isFalse);
      expect(emitted, isEmpty);
      expect(session.controller.document.toDelta().toJson(), original);
      session.insertBlockImage(
        url: 'https://cdn.example.com/delayed-upload.webp',
      );
      expect(
        session.controller.document.toDelta().toJson(),
        original,
        reason: '已在途图片回调不能改变只读原文',
      );
      expect(session.canCloseProtectedSource, isTrue);
      session.applyExternalMarkdown('正常正文');
      expect(session.isSourceProtected, isFalse);
      expect(session.controller.readOnly, isFalse);
      expect(await session.flush(), isTrue);
    });
  }

  testWidgets('写入能力缺失时保留对齐原文，不降级覆盖', (tester) async {
    const source = '[wenyousite-align-v1-center]: #\n甲';
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: source,
      blockAlignment: false,
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    expect(session.isSourceProtected, isTrue);
    expect(await session.flush(), isFalse);
    expect(emitted, isEmpty);
  });
}
