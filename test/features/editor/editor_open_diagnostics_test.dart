import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_sentry_sender.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

// 来自 cmulh9bx501937qm7tan1vyxs 的精确最小片段，保留换行和转义。
// 此用例覆盖漏报；尖括号误判及控制标记外露仍是待修复的原问题。
const originalFragment =
    '[wenyousite-align-v1-center]: #\n'
    r'*<\<Y/N \>\>*';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FailureDiagnostics previous;
  late FailureDiagnostics diagnostics;
  late _Sender sender;

  setUp(() {
    previous = FailureDiagnostics.instance;
    sender = _Sender();
    diagnostics = FailureDiagnostics(sender: sender);
    FailureDiagnostics.instance = diagnostics;
  });
  tearDown(() async {
    await diagnostics.settled;
    FailureDiagnostics.instance = previous;
    diagnostics.dispose();
  });

  RichEditorSession open(String source, {bool blockAlignment = true}) {
    final session = RichEditorSession(
      initialMarkdown: source,
      blockAlignment: blockAlignment,
      imageAlignment: true,
      onMarkdownChanged: (_) => fail('只读原文不得写回'),
    );
    addTearDown(session.dispose);
    return session;
  }

  test('原楼层打开即拦截时上报，并给出同一问题编号且保留原文', () async {
    final session = open(originalFragment);
    expect(session.isSourceProtected, isTrue);
    expect(session.controller.readOnly, isTrue);
    expect(session.codecFailure, '这段内容暂不支持编辑，原文已保留。');
    expect(session.diagnosticId, isNotNull);
    await diagnostics.settled;

    final record = sender.records.single;
    expect(record.id, session.diagnosticId);
    expect(record.operation.name, 'editorOpen');
    expect(record.stage, DiagnosticStage.decode);
    expect(
      record.fields['diagnosticCode'],
      'markdown.open_unsupported_markdown',
    );
    expect(DiagnosticRecord.fromJson(record.toJson())?.id, record.id);
    final event = diagnosticSentryEvent(record);
    expect(event.tags?['diagnosticCode'], 'markdown.open_unsupported_markdown');
    expect(event.fingerprint, contains('editorOpen'));
    expect(event.fingerprint, contains('markdown.open_unsupported_markdown'));
    for (final payload in [diagnostics.export(), jsonEncode(event.toJson())]) {
      expect(payload, isNot(contains('wenyousite-align')));
      expect(payload, isNot(contains('Y/N')));
      expect(payload, isNot(contains('cmulh9bx501937qm7tan1vyxs')));
    }
    expect(await session.flush(), isFalse);
    expect(session.localMarkdown, originalFragment);
    expect(session.canCloseProtectedSource, isTrue);
  });

  test('同会话重复加载和尝试保存被拦截原文复用记录，正常正文清除旧提示', () async {
    final session = open(originalFragment);
    final id = session.diagnosticId;
    session.applyExternalMarkdown(originalFragment);
    expect(await session.flush(), isFalse);
    session.applyExternalMarkdown(originalFragment);
    expect(session.diagnosticId, id);
    await diagnostics.settled;
    expect(sender.records, hasLength(1));

    session.applyExternalMarkdown('普通正文');
    expect(session.diagnosticId, isNull);
    expect(session.codecFailure, isNull);
    expect(session.controller.readOnly, isFalse);
    session.applyExternalMarkdown(originalFragment);
    expect(session.diagnosticId, id);
    await diagnostics.settled;
    expect(sender.records, hasLength(1));
  });

  test('另一份被拦截正文和新编辑会话分别产生记录', () async {
    final session = open(originalFragment);
    final firstId = session.diagnosticId;
    session.applyExternalMarkdown('$originalFragment\n\n另一份正文');
    expect(session.diagnosticId, isNot(firstId));
    final another = open(originalFragment);
    expect(another.diagnosticId, isNot(firstId));
    await diagnostics.settled;
    expect(sender.records, hasLength(3));
  });

  test('缺少编辑能力单独分组，正常内容和业务只读不生成错误', () async {
    final limited = open(
      '[wenyousite-align-v1-center]: #\n正文',
      blockAlignment: false,
    );
    expect(limited.isSourceProtected, isTrue);
    await diagnostics.settled;
    expect(
      sender.records.single.fields['diagnosticCode'],
      'markdown.open_missing_feature',
    );
    final normal = open('可读取正文');
    normal.readOnly = true;
    expect(normal.diagnosticId, isNull);
    expect(normal.codecFailure, isNull);
    await diagnostics.settled;
    expect(sender.records, hasLength(1));
  });

  test('关闭自动发送仍保留可复制的问题详情', () async {
    await diagnostics.setAutomaticSending(false);
    final session = open(originalFragment);
    await diagnostics.settled;
    expect(session.diagnosticId, isNotNull);
    expect(diagnostics.records.single.pending, isFalse);
    expect(sender.records, isEmpty);
    expect(
      diagnostics.export(id: session.diagnosticId),
      contains('editorOpen'),
    );
  });
}

class _Sender implements DiagnosticSender {
  final records = <DiagnosticRecord>[];
  @override
  bool get available => true;
  @override
  Future<bool> send(DiagnosticRecord record) async {
    records.add(record);
    return true;
  }

  @override
  void cancel() {}
}
