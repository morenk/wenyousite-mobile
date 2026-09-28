import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_text.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_sections.dart';

import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_test_support.dart';

final _created = DateTime(2024, 1, 1, 10);
final _edited = DateTime(2025, 2, 3, 11);
final _reference = DateTime(2026, 9, 29, 12);
const _threadAuthor = ThreadAuthorModel(id: 'author', username: '作者', level: 2);

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';
    testWidgets('主题楼层和内嵌回复只显示对应时间 $mode 320dp', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_threadCardApp(dark: dark));
      await tester.pumpAndSettle();

      expect(find.text('编辑于2025-02-03'), findsNWidgets(2));
      expect(find.text('2024-01-01'), findsOneWidget);
      expect(find.text('回复 @楼主'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('编辑时间：2025-02-03')), findsWidgets);
      expect(find.bySemanticsLabel(RegExp('发布时间：2025-02-03')), findsNothing);
      expect(tester.takeException(), isNull);
      semantics.dispose();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/thread_edited_time_${mode}_320.png'),
      );
    });

    testWidgets('独立讨论保留编号和回复对象、编辑语义 $mode 320dp', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final semantics = tester.ensureSemantics();
      final repository = PostRepliesPageTestFakePostRepository(
        onFetchPost: (_) async => _post(root: true, editedAt: _edited),
        initialReplies: [
          _post(editedAt: _edited),
          _post(id: 'old-reply'),
        ],
      );
      final container = await postRepliesPageTestPostContainer(repository);
      addTearDown(container.dispose);
      await tester.pumpWidget(_postApp(container, dark: dark));
      await postRepliesPageTestPumpUi(tester);
      await tester.pumpAndSettle();

      expect(find.text('#7 · 编辑于2025-02-03'), findsOneWidget);
      expect(find.text('回复 @楼主 · 编辑于2025-02-03'), findsOneWidget);
      expect(find.text('回复 @楼主 · 2024-01-01'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('楼层 7，编辑时间：2025-02-03')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('回复 楼主，编辑时间：2025-02-03')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/post_edited_time_${mode}_320.png'),
      );
    });
  }

  testWidgets('历史楼层即使版本增加仍沿用发布时间', (tester) async {
    await tester.pumpWidget(_threadCardApp(dark: false, edited: false));
    await tester.pumpAndSettle();
    expect(find.textContaining('编辑于'), findsNothing);
    final times = tester.widgetList<WenyouTimeText>(
      find.byType(WenyouTimeText),
    );
    expect(times, hasLength(3));
    expect(times.every((time) => time.value == _created), isTrue);
    expect(times.every((time) => time.semanticsPrefix == '发布时间：'), isTrue);
  });

  final cases = <Duration, String>{
    const Duration(seconds: 59): '刚刚',
    const Duration(minutes: 1): '1 分钟前',
    const Duration(hours: 1): '1 小时前',
    const Duration(days: 1): '1 天前',
    const Duration(seconds: 259199): '2 天前',
    const Duration(days: 3): '09-26',
    const Duration(minutes: -1): '09-29',
  };
  for (final entry in cases.entries) {
    testWidgets('独立讨论编辑时间继续使用共享时间边界 ${entry.key}', (tester) async {
      final repository = PostRepliesPageTestFakePostRepository(
        onFetchPost: (_) async =>
            _post(root: true, editedAt: _reference.subtract(entry.key).toUtc()),
        initialReplies: [],
      );
      final container = await postRepliesPageTestPostContainer(repository);
      addTearDown(container.dispose);
      await tester.pumpWidget(_postApp(container, dark: false));
      await postRepliesPageTestPumpUi(tester);
      expect(find.text('#7 · 编辑于${entry.value}'), findsOneWidget);
      expect(find.textContaining('2024-01-01'), findsNothing);
    });
  }
}

Widget _postApp(ProviderContainer container, {required bool dark}) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: PostRepliesPage(
          threadId: 'thread',
          rootPostId: 'root',
          timeReference: _reference,
        ),
      ),
    );

Widget _threadCardApp({required bool dark, bool edited = true}) =>
    ProviderScope(
      overrides: [stickersEnabledProvider.overrideWithValue(false)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ThreadFloorCard(
              threadId: 'thread',
              floor: ThreadFloorModel(
                id: 'floor',
                floorNumber: 7,
                author: _threadAuthor,
                body: const ThreadBodyModel(markdown: '这是编辑后的楼层正文。'),
                createdAt: _created,
                editedAt: edited ? _edited : null,
                version: 9,
                isDeleted: false,
                replyCount: 2,
                replies: [
                  for (final changed in [true, false])
                    ThreadReplyModel(
                      id: changed ? 'reply' : 'old-reply',
                      author: _threadAuthor,
                      body: ThreadBodyModel(
                        markdown: changed ? '已编辑的回复。' : '保留发布时间的历史回复。',
                      ),
                      createdAt: _created,
                      editedAt: changed && edited ? _edited : null,
                      isDeleted: false,
                      replyToUsername: changed ? '楼主' : null,
                    ),
                ],
              ),
              canEdit: false,
              canDelete: false,
              canPin: false,
              pending: false,
              onReply: () {},
              onReplyToReply: (_) {},
              onDiscussion: () {},
              onEdit: () {},
              onDelete: () {},
              onTogglePin: () {},
            ),
          ),
        ),
      ),
    );

PostItem _post({String id = 'reply', bool root = false, DateTime? editedAt}) =>
    PostItem(
      id: root ? 'root' : id,
      threadId: 'thread',
      subthreadId: 'subthread',
      author: const PostAuthor(id: 'author', username: '作者', level: 2),
      content: root ? '这是编辑后的楼层正文。' : '这里是楼中楼回复。',
      version: 9,
      createdAt: _created,
      updatedAt: _reference,
      editedAt: editedAt,
      isBody: false,
      isDeleted: false,
      floorNumber: root ? 7 : null,
      parentPostId: root ? null : 'root',
      replyToPostId: root ? null : 'root',
      replyToAuthor: root
          ? null
          : const PostAuthor(id: 'owner', username: '楼主', level: 3),
      replyCount: root ? 2 : 0,
    );
