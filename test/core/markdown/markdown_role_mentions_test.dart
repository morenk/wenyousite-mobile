import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_clipboard_text.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_mention_target.dart';

void main() {
  final fixtures =
      jsonDecode(
            File(
              'contracts/markdown-v6-role-mentions-fixtures.json',
            ).readAsStringSync(),
          )
          as Map;
  for (final row in fixtures['cases'] as List) {
    test('角色提及固定语料 ${row['id']} 保留目标与原标签', () {
      final source = row['source'] as String;
      final delta = MarkdownDeltaCodec.decode(source).delta;
      final targets = <Map<String, Object?>>[];
      for (final operation in delta.operations) {
        if (operation.data case final Map data) {
          if (data[MarkdownDeltaCodec.mentionEmbed] case final Map payload) {
            final target = MarkdownMentionTarget.fromPayload(payload)!;
            targets.add({
              'userId': target.userId,
              'label': (payload['label'] as String).substring(1),
              'targetIdentityId': target.identityId,
              'mode': target.isLegacy
                  ? 'LEGACY'
                  : target.isAccount
                  ? 'ACCOUNT'
                  : 'RP',
            });
          }
        }
      }
      expect(targets, row['expected']);
      expect(MarkdownDeltaCodec.encode(delta), source);
    });
  }

  for (final source in fixtures['invalidSources'] as List) {
    test('非法目标不转换成账号或其他角色：$source', () {
      final match = MarkdownMentionTarget.nodeAtStart.firstMatch(
        source as String,
      );
      expect(
        match == null ? null : MarkdownMentionTarget.parse(match[2]!),
        isNull,
      );
      expect(
        MarkdownDeltaCodec.decode(source).delta.operations.where(
          (op) =>
              op.data is Map &&
              (op.data as Map).containsKey(MarkdownDeltaCodec.mentionEmbed),
        ),
        isEmpty,
      );
    });
  }

  test('同账号同名三个目标独立投影，显示文字不改写原源', () {
    final rows = (fixtures['cases'] as List).take(3).toList();
    final source = rows.map((row) => row['source']).join(' ');
    final labels = <String, String>{};
    for (var i = 0; i < rows.length; i++) {
      final href = MarkdownMentionTarget.nodeAtStart.firstMatch(
        rows[i]['source'] as String,
      )![2]!;
      labels[MarkdownMentionTarget.parse(href)!.projectionKey('同名')] = [
        '角色甲',
        '角色乙',
        '站内用户',
      ][i];
    }
    expect(
      MarkdownContent.toPlainTextPreview(source, mentionLabels: labels),
      '@角色甲 @角色乙 @站内用户',
    );
    expect(
      MarkdownClipboardText.project(source, mentionLabels: labels),
      '@角色甲 @角色乙 @站内用户',
    );
    expect(
      MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(source).delta),
      source,
    );
  });

  test('昵称中的反引号与格式标点作为原子标签保留', () {
    for (final label in ['`白鸦`', '白**鸦', '白_鸦', '白\\鸦']) {
      final source =
          '[@$label](/users/user-1?rpIdentityId=c00000000000000000000000a)';
      final delta = MarkdownDeltaCodec.decode(source).delta;
      expect(delta.operations.first.data, isA<Map>());
      expect(MarkdownContent.toPlainTextPreview(source), '@$label');
      expect(MarkdownDeltaCodec.encode(delta), source);
    }
  });

  test('摘要代码和转义节点不使用提及显示投影', () {
    const href = '/users/user-1?rpIdentityId=c00000000000000000000000a';
    const node = '[@旧角色]($href)';
    const labels = {'$href\u0000旧角色': '站内用户'};
    expect(
      MarkdownContent.toPlainTextPreview(
        '$node `$node`',
        mentionLabels: labels,
      ),
      '@站内用户 @旧角色',
    );
    expect(
      MarkdownContent.toPlainTextPreview('\\$node', mentionLabels: labels),
      isNot(contains('站内用户')),
    );
  });

  test('图片alt中的角色式文字不参与提及投影', () {
    const href = '/users/user-1?rpIdentityId=c00000000000000000000000a';
    expect(
      MarkdownContent.toPlainTextPreview(
        '![@旧角色]($href)',
        mentionLabels: const {'$href\u0000旧角色': '站内用户'},
      ),
      '[图片]',
    );
  });

  test('合法24个emoji昵称可解析且保源', () {
    final label = '😀' * 24;
    final source =
        '[@$label](/users/user-1?rpIdentityId=c00000000000000000000000a)';
    final decoded = MarkdownDeltaCodec.decode(source);
    expect(decoded.delta.operations.first.data, isA<Map>());
    expect(MarkdownDeltaCodec.encode(decoded.delta), source);
  });
}
