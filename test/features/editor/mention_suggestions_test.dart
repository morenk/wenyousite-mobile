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
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

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

    expect(find.text('问题编号：mention-request-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mention-retry')));
    await tester.pump();

    expect(find.byKey(const Key('mention-results')), findsOneWidget);
    expect(repository.queries, [('thread-1', '温'), ('thread-1', '温')]);
  });

  for (final width in const [320.0, 360.0, 400.0]) {
    testWidgets('$width dp 提及候选浮在键盘上方且不改变正文画布', (tester) async {
      final semantics = tester.ensureSemantics();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 640);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      final repository = _FakeRepository(
        result: const MentionCandidatesResult(
          users: [
            MentionCandidate(
              id: 'user-alice',
              username: 'Alice',
              relation: MentionCandidateRelation.following,
            ),
            MentionCandidate(
              id: 'user-bob',
              username: 'Bob',
              relation: MentionCandidateRelation.player,
            ),
            MentionCandidate(
              id: 'user-carol',
              username: 'Carol',
              relation: MentionCandidateRelation.following,
            ),
          ],
          canMentionAllPlayers: true,
        ),
      );
      final controller = _controller('正文');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      await _pumpPanel(
        tester,
        repository: repository,
        controller: controller,
        focusNode: focusNode,
        threadId: 'thread-1',
        withEditorCanvas: true,
      );
      focusNode.requestFocus();
      await tester.pump();
      final canvas = find.byKey(const Key('mention-test-canvas'));
      final canvasSize = tester.getSize(canvas);
      controller.replaceText(
        2,
        0,
        ' @',
        const TextSelection.collapsed(offset: 4),
      );
      await tester.pump(const Duration(milliseconds: 2));

      final panel = find.byKey(const Key('mention-floating-panel'));
      expect(panel, findsOneWidget);
      expect(tester.getSize(canvas), canvasSize);
      expect(tester.getSize(panel).height, lessThanOrEqualTo(200));
      expect(
        tester.getBottomRight(panel).dy,
        lessThanOrEqualTo(640 - 280 - 48 - 16 + 0.1),
      );
      expect(find.bySemanticsLabel(RegExp('提及候选')), findsOneWidget);
      expect(focusNode.hasFocus, isTrue);
      expect(controller.selection.baseOffset, 4);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('mention-dismiss')));
      await tester.pump();
      expect(panel, findsNothing);
      expect(focusNode.hasFocus, isTrue);
      expect(tester.getSize(canvas), canvasSize);
      semantics.dispose();
    });
  }

  testWidgets('360dp 键盘写作的提及候选保持轻量浮层视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    final repository = _FakeRepository(
      result: const MentionCandidatesResult(
        users: [
          MentionCandidate(
            id: 'user-alice',
            username: 'Alice',
            relation: MentionCandidateRelation.following,
          ),
          MentionCandidate(
            id: 'user-bob',
            username: 'Bob',
            relation: MentionCandidateRelation.player,
          ),
        ],
        canMentionAllPlayers: true,
      ),
    );
    final controller = _controller('接下来交给 @');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await _pumpPanel(
      tester,
      repository: repository,
      controller: controller,
      focusNode: focusNode,
      threadId: 'thread-1',
      withEditorCanvas: true,
    );
    focusNode.requestFocus();
    await tester.pump(const Duration(milliseconds: 2));
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byKey(const Key('mention-floating-panel')),
      matchesGoldenFile('goldens/mention_suggestions_floating_360.png'),
    );
  });

  testWidgets('320dp 大字号提及候选保持可滚动且无布局溢出', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    final repository = _FakeRepository(
      result: const MentionCandidatesResult(
        users: [
          MentionCandidate(
            id: 'user-alice',
            username: '很长的关注用户名',
            relation: MentionCandidateRelation.following,
          ),
          MentionCandidate(
            id: 'user-bob',
            username: '很长的玩家用户名',
            relation: MentionCandidateRelation.player,
          ),
          MentionCandidate(
            id: 'user-carol',
            username: '另一位玩家',
            relation: MentionCandidateRelation.player,
          ),
        ],
        canMentionAllPlayers: true,
      ),
    );
    final controller = _controller('@');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await _pumpPanel(
      tester,
      repository: repository,
      controller: controller,
      focusNode: focusNode,
      threadId: 'thread-1',
      textScaler: const TextScaler.linear(2),
    );
    await tester.pump(const Duration(milliseconds: 2));

    expect(find.byKey(const Key('mention-floating-panel')), findsOneWidget);
    expect(find.byKey(const Key('mention-results')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('mention-floating-panel'))).height,
      lessThanOrEqualTo(200),
    );
    expect(tester.takeException(), isNull);
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
  bool withEditorCanvas = false,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mentionCandidateRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData.fromView(
            tester.view,
          ).copyWith(textScaler: textScaler),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                if (withEditorCanvas)
                  Positioned.fill(
                    child: SizedBox(
                      key: const Key('mention-test-canvas'),
                      child: QuillEditor(
                        controller: controller,
                        focusNode: focusNode,
                        scrollController: ScrollController(),
                        config: const QuillEditorConfig(
                          expands: true,
                          scrollable: true,
                        ),
                      ),
                    ),
                  ),
                MentionSuggestions(
                  controller: controller,
                  focusNode: focusNode,
                  threadId: threadId,
                  enabled: true,
                  debounce: Duration.zero,
                ),
              ],
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
