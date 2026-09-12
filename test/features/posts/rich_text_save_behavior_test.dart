import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_targets.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/rich_text_behavior_projection.dart';
import '../../support/rich_text_behavior_report.dart';

class _Repository extends Mock implements PostRepository {}

void main() {
  setUpAll(loadDeterministicTestFonts);
  final report = RichTextBehaviorReport('save');
  final fixture =
      jsonDecode(
            File(
              'contracts/rich-text-behavior-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as BehaviorJson;
  for (final item in (fixture['cases']! as List).cast<BehaviorJson>()) {
    if (!(item['id']! as String).startsWith('rtb-save-')) continue;
    testWidgets('真实帖子保存流程 ${item['id']}', (tester) async {
      final initial = item['initial']! as BehaviorJson;
      var remote = _post(initial['canonical']! as String, 1);
      final repository = _Repository();
      String? outcome;
      final requests = <({String content, int version})>[];
      var fetches = 0;
      when(() => repository.fetchPost('post')).thenAnswer((_) async {
        fetches++;
        return remote;
      });
      when(
        () => repository.update(
          postId: 'post',
          content: any(named: 'content'),
          version: any(named: 'version'),
        ),
      ).thenAnswer((invocation) async {
        final content = invocation.namedArguments[#content]! as String;
        final version = invocation.namedArguments[#version]! as int;
        requests.add((content: content, version: version));
        if (outcome != null) {
          if (outcome == 'conflict') remote = _post(remote.content, 2);
          throw ApiFailure(
            userMessage: '操作失败',
            source: outcome == 'network-error'
                ? FailureSource.network
                : FailureSource.service,
            httpStatus: outcome == 'conflict'
                ? 409
                : outcome == 'unsupported'
                ? 400
                : null,
            businessCode: outcome == 'conflict'
                ? 40002
                : outcome == 'unsupported'
                ? 40009
                : null,
          );
        }
        remote = _post(content, version + 1);
        return remote;
      });
      PostItem? saved;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            postRepositoryProvider.overrideWithValue(repository),
            stickersEnabledProvider.overrideWithValue(false),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => unawaited(
                    showPostComposerSheet(
                      context: context,
                      target: postEditTarget(remote, '编辑正文'),
                    ).then((result) => saved = result),
                  ),
                  child: const Text('打开'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      final controller = tester
          .widget<QuillEditor>(find.byType(QuillEditor))
          .controller;
      controller.updateSelection(
        RichTextBehaviorProjection(
          controller.document.toDelta(),
        ).decodeSelection(initial['selection']! as BehaviorJson),
        ChangeSource.local,
      );
      expect(
        RichTextBehaviorProjection(controller.document.toDelta()).summary,
        initial['summary'],
      );
      report.state(item['id'] as String, 'initial', _capture(controller));
      const fault = Attribute<String>(
        'wenyou_test_encoding_failure',
        AttributeScope.inline,
        'synthetic',
      );
      var encodingFault = false;
      for (final step in (item['steps']! as List).cast<BehaviorJson>()) {
        final operation = step['operation']! as BehaviorJson;
        final expected = step['expected']! as BehaviorJson;
        final beforeRequests = requests.length;
        if (operation['type'] == 'insertText') {
          final text = operation['text']! as String;
          final position = controller.selection.start;
          controller.replaceText(
            position,
            0,
            text,
            TextSelection.collapsed(offset: position + text.length),
          );
          await tester.pump();
        } else {
          if (operation['type'] == 'save') {
            outcome = operation['outcome']! as String;
            if (outcome == 'encode-error') {
              encodingFault = true;
              controller.document.format(0, 1, fault);
              expect(
                () => MarkdownDeltaCodec.encode(controller.document.toDelta()),
                throwsA(isA<MarkdownCodecException>()),
              );
            }
          } else if (operation['type'] == 'recover') {
            outcome = null;
            if (encodingFault) {
              controller.document.format(0, 1, Attribute.clone(fault, null));
              await tester.pump(const Duration(milliseconds: 150));
              encodingFault = false;
            }
          } else {
            fail('未知保存操作 ${operation['type']}');
          }
          final beforeSubmit = _capture(controller);
          if (operation['resolution'] == 'explicit-retry-after-reload') {
            expect(fetches, 2, reason: '冲突后已先读取最新版，尚未自动覆盖');
            await tester.tap(
              find.byKey(const Key('post-composer-retry-conflict')),
            );
            await tester.pumpAndSettle();
            expect(requests.length, beforeRequests);
            await tester.tap(find.text('仍然覆盖'));
          } else {
            await tester.tap(find.byTooltip('保存修改'));
          }
          await tester.pumpAndSettle();
          final save = expected['save']! as BehaviorJson;
          final actualSave = <String, Object?>{
            'requestMarkdown': requests.length == beforeRequests
                ? null
                : requests.last.content,
            'persistedMarkdown': remote.content,
            'dirty':
                jsonEncode(beforeSubmit['summary']) !=
                jsonEncode(
                  RichTextBehaviorProjection(
                    MarkdownDeltaCodec.decode(remote.content).delta,
                  ).summary,
                ),
          };
          expect(actualSave, save);
          report.state(item['id'] as String, step['id'] as String, {
            ...beforeSubmit,
            'save': actualSave,
          });
          expect(
            requests.length == beforeRequests ? null : requests.last.content,
            save['requestMarkdown'],
            reason: '${item['id']}/${step['id']}/request',
          );
          expect(remote.content, save['persistedMarkdown']);
          if (operation['resolution'] == 'explicit-retry-after-reload') {
            expect(requests.last.version, 2);
          }
          if (operation['type'] == 'recover') {
            expect(saved?.content, expected['canonical']);
            expect(find.byType(QuillEditor), findsNothing);
            expect(saved?.content != remote.content, save['dirty']);
            continue;
          }
          expect(find.byType(QuillEditor), findsOneWidget);
          expect(saved, isNull);
          expect(
            jsonEncode(
                  RichTextBehaviorProjection(
                    controller.document.toDelta(),
                  ).summary,
                ) !=
                jsonEncode(
                  RichTextBehaviorProjection(
                    MarkdownDeltaCodec.decode(remote.content).delta,
                  ).summary,
                ),
            save['dirty'],
          );
        }
        final projection = RichTextBehaviorProjection(
          controller.document.toDelta(),
        );
        if (operation['type'] == 'insertText') {
          report.state(
            item['id'] as String,
            step['id'] as String,
            _capture(controller),
          );
        }
        expect(projection.summary, expected['summary']);
        expect(
          projection.encodeSelection(controller.selection),
          expected['selection'],
        );
        if (!encodingFault) {
          expect(
            MarkdownDeltaCodec.encode(controller.document.toDelta()),
            expected['canonical'],
          );
        } else {
          expect(expected['canonical'], isNull);
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}

BehaviorJson _capture(QuillController controller) {
  final projection = RichTextBehaviorProjection(controller.document.toDelta());
  String? canonical;
  try {
    canonical = MarkdownDeltaCodec.encode(controller.document.toDelta());
  } on MarkdownCodecException {
    // 故障回执明确表达当前编码失败，不能代用上一份有效正文。
    canonical = null;
  }
  return {
    'canonical': canonical,
    'summary': projection.summary,
    'selection': projection.encodeSelection(controller.selection),
  };
}

PostItem _post(String content, int version) => PostItem(
  id: 'post',
  threadId: 'thread',
  subthreadId: 'subthread',
  author: const PostAuthor(id: 'author', username: '测试', level: 1),
  content: content,
  version: version,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  isBody: false,
  isDeleted: false,
);
