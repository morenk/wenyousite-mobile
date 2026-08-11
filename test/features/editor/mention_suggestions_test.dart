import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/editor/data/mention_candidate_repository.dart';
import 'package:wenyousite_mobile/features/editor/domain/mention_models.dart';
import 'package:wenyousite_mobile/features/editor/presentation/mention_suggestions.dart';

void main() {
  testWidgets('输入 @ 后查询主题候选并插入规范用户节点', (tester) async {
    final repository = _FakeRepository(
      result: const MentionCandidatesResult(
        users: [
          MentionCandidate(
            id: 'user-alice',
            username: 'Alice',
            relation: MentionCandidateRelation.following,
          ),
        ],
        canMentionAllPlayers: true,
      ),
    );
    final controller = _controller('你好 @');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await _pumpPanel(
      tester,
      repository: repository,
      controller: controller,
      focusNode: focusNode,
      threadId: 'thread-1',
    );
    await tester.pump(const Duration(milliseconds: 2));

    expect(find.byKey(const Key('mention-all-players')), findsOneWidget);
    expect(find.byKey(const Key('mention-user-user-alice')), findsOneWidget);
    expect(repository.queries, [('thread-1', '')]);

    await tester.tap(find.byKey(const Key('mention-user-user-alice')));
    await tester.pump();

    expect(find.byKey(const Key('mention-suggestions')), findsNothing);
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      '你好 [@Alice](/users/user-alice) ',
    );
    expect(controller.selection.baseOffset, 5);
  });

  testWidgets('只有服务端授权时显示并插入全体玩家节点', (tester) async {
    final repository = _FakeRepository(
      result: const MentionCandidatesResult(
        users: [],
        canMentionAllPlayers: true,
      ),
    );
    final controller = _controller('@全');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    await _pumpPanel(
      tester,
      repository: repository,
      controller: controller,
      focusNode: focusNode,
      threadId: 'thread-1',
    );
    await tester.pump(const Duration(milliseconds: 2));

    await tester.tap(find.byKey(const Key('mention-all-players')));
    await tester.pump();

    expect(MarkdownDeltaCodec.encode(controller.document.toDelta()), '@全体玩家 ');
  });

  testWidgets('新主题没有服务端上下文时明确提示先保存且不请求候选', (tester) async {
    final repository = _FakeRepository();
    final controller = _controller('@');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await _pumpPanel(
      tester,
      repository: repository,
      controller: controller,
      focusNode: focusNode,
      threadId: null,
    );

    expect(find.byKey(const Key('mention-context-required')), findsOneWidget);
    expect(find.textContaining('先保存到云端草稿'), findsOneWidget);
    expect(repository.queries, isEmpty);
  });

  testWidgets('失败展示请求 ID 并可按同一查询重试', (tester) async {
    final repository = _FakeRepository(failOnce: true);
    final controller = _controller('@温');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await _pumpPanel(
      tester,
      repository: repository,
      controller: controller,
      focusNode: focusNode,
      threadId: 'thread-1',
    );
    await tester.pump(const Duration(milliseconds: 2));

    expect(find.text('请求 ID：mention-request-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mention-retry')));
    await tester.pump();

    expect(find.byKey(const Key('mention-results')), findsOneWidget);
    expect(repository.queries, [('thread-1', '温'), ('thread-1', '温')]);
  });
}

QuillController _controller(String text) {
  final document = Document.fromDelta(MarkdownDeltaCodec.decode(text).delta);
  return QuillController(
    document: document,
    selection: TextSelection.collapsed(offset: text.length),
  );
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  required _FakeRepository repository,
  required QuillController controller,
  required FocusNode focusNode,
  required String? threadId,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mentionCandidateRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: MentionSuggestions(
              controller: controller,
              focusNode: focusNode,
              threadId: threadId,
              enabled: true,
              debounce: Duration.zero,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

class _FakeRepository implements MentionCandidateRepository {
  _FakeRepository({
    this.result = const MentionCandidatesResult(
      users: [
        MentionCandidate(
          id: 'user-default',
          username: '温油用户',
          relation: MentionCandidateRelation.player,
        ),
      ],
      canMentionAllPlayers: false,
    ),
    this.failOnce = false,
  });

  final MentionCandidatesResult result;
  final bool failOnce;
  final List<(String, String)> queries = [];
  int _attempts = 0;

  @override
  Future<MentionCandidatesResult> findCandidates({
    required String threadId,
    required String query,
  }) async {
    queries.add((threadId, query));
    _attempts += 1;
    if (failOnce && _attempts == 1) {
      throw const ApiFailure(
        userMessage: '候选加载失败。',
        requestId: 'mention-request-id',
      );
    }
    return result;
  }
}
