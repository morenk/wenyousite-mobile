import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_drafts.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/memory_pending_media_file_store.dart';

// 两份 Markdown 与第19楼实际反馈一致，标识符使用测试值。
// 负责人已确认同基线默认恢复未发布修改；此回归固定该行为，不新增选稿功能。
const _published =
    '### <span data-wenyou-color-v1="#D14343">杀！</span>\n'
    '## <span data-wenyou-color-v1="#D14343">杀！</span>';
const _localDraft = '<br />\n## <span data-wenyou-color-v1="#D14343">杀！</span>';
const PostComposerTarget _target = (
  kind: PostComposerKind.editPost,
  threadId: 'thread',
  subthreadId: 'subthread',
  postId: 'floor19',
  parentPostId: null,
  replyToPostId: null,
  version: 2,
  initialContent: _published,
  label: '编辑 #19 楼',
);

class _Repository extends Mock implements PostRepository {}

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final stored in [null, _published, _localDraft]) {
    testWidgets(
      '第19楼精确双标题：${stored == null
          ? '无草稿保留原文'
          : stored == _published
          ? '相同草稿保留两行'
          : '默认继承上次未发布修改'}',
      (tester) async {
        final store = MemoryPendingMediaFileStore();
        addTearDown(store.dispose);
        if (stored != null) {
          await store.write(
            accountId: 'owner',
            target: 'post:${postComposerDraftKey(_target)}',
            payload: {
              'version': 1,
              'baseline': jsonEncode(['floor19', 2, _published]),
              'markdown': stored,
              'images': <Object>[],
            },
          );
        }
        final repository = await _open(tester, store);
        final controller = tester
            .widget<QuillEditor>(find.byKey(const Key('post-composer-body')))
            .controller;
        if (stored == _localDraft) {
          expect(controller.document.toPlainText(), '\n杀！\n');
          expect(_headers(controller), [null, 2]);
          expect(_coloredText(controller), ['杀！']);
          expect(
            MarkdownDeltaCodec.encode(controller.document.toDelta()),
            _localDraft,
          );
          expect(_localDraft.length, 56);
        } else {
          expect(controller.document.toPlainText(), '杀！\n杀！\n');
          expect(_headers(controller), [3, 2]);
          expect(_coloredText(controller), ['杀！', '杀！']);
        }
        expect(find.byType(AlertDialog), findsNothing);
        expect(
          find.byKey(const Key('post-composer-draft-diverged')),
          findsNothing,
        );
        verify(() => repository.fetchPost('floor19')).called(1);
        verifyNever(
          () => repository.update(
            postId: any(named: 'postId'),
            content: any(named: 'content'),
            version: any(named: 'version'),
          ),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}

Future<_Repository> _open(
  WidgetTester tester,
  MemoryPendingMediaFileStore store,
) async {
  final repository = _Repository();
  when(() => repository.fetchPost('floor19')).thenAnswer(
    (_) async => PostItem(
      id: 'floor19',
      threadId: 'thread',
      subthreadId: 'subthread',
      author: const PostAuthor(id: 'owner', username: '作者', level: 1),
      content: _published,
      version: 2,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      isBody: false,
      isDeleted: false,
    ),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionScopeProvider.overrideWithValue(
          const SessionScope(accountId: 'owner', generation: 1),
        ),
        pendingMediaFileStoreProvider.overrideWithValue(store),
        postRepositoryProvider.overrideWithValue(repository),
        stickersEnabledProvider.overrideWithValue(false),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => unawaited(
                showPostComposerSheet(context: context, target: _target),
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
  return repository;
}

List<int?> _headers(QuillController controller) => [
  for (final operation in controller.document.toDelta().operations)
    if (operation.data is String && (operation.data as String).contains('\n'))
      operation.attributes?['header'] as int?,
];

List<String> _coloredText(QuillController controller) => [
  for (final operation in controller.document.toDelta().operations)
    if (operation.attributes?['color'] == '#D14343') operation.data as String,
];
