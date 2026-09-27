import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/domain/domain_validation_exception.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_atomic_text_editor.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

void main() {
  test('动态标题、正文、评论按 Unicode 码点边界接收 emoji', () {
    final title = '😀' * 40;
    final body = '😀' * 1000;
    expect(
      MomentDraftInput(
        title: title,
        content: body,
        mediaIds: const [],
      ).normalized().content,
      body,
    );
    expect(
      () => MomentDraftInput(
        title: '$title😀',
        content: body,
        mediaIds: const [],
      ).normalized(),
      throwsA(isA<DomainValidationException>()),
    );
    expect(
      () => const MomentDraftInput(
        title: '😀',
        content: '',
        mediaIds: [],
      ).normalized(),
      throwsA(isA<DomainValidationException>()),
    );
    expect(
      MomentCommentInput(content: '😀' * 500).normalized().content,
      '😀' * 500,
    );
    expect(
      () => MomentCommentInput(content: '😀' * 501).normalized(),
      throwsA(isA<DomainValidationException>()),
    );
  });

  test('原子输入和私聊使用码点而非 UTF16 或字素簇', () {
    final controller = WenyouAtomicTextController(
      initialMarkdown: '😀' * 1000,
      maximumMarkdownLength: 1000,
    );
    addTearDown(controller.dispose);
    expect(controller.flush(), isTrue);
    expect(controller.documentLength, 2000); // 编辑偏移仍为 UTF16。
    expect(validateDirectMessagePayload(content: '😀' * 1000), isNull);
    expect(validateDirectMessagePayload(content: '😀' * 1001), isNotNull);
    controller.applyMarkdown('👩‍👩‍👧‍👧' * 143); // 1 个字素簇由 7 个码点组成。
    expect(controller.flush(), isFalse);
    expect(
      validateDirectMessagePayload(content: '👩‍👩‍👧‍👧' * 143),
      isNotNull,
    );
  });

  test('主题正文与举报说明遵循相同后端码点限制', () {
    expect(
      validateThreadDraft(
        title: '😀' * 100,
        body: '😀' * 10000,
        tags: const [],
      ),
      isNull,
    );
    expect(
      validateThreadDraft(title: '😀' * 101, body: '', tags: const []),
      isNotNull,
    );
    expect(
      validateThreadDraft(title: '标题', body: '😀' * 10001, tags: const []),
      isNotNull,
    );
    final input = ReportInput(
      target: const ReportTarget.moment('moment-id'),
      reason: ReportReason.other,
      details: '😀' * 1000,
    );
    expect(input.normalized().details, '😀' * 1000);
    expect(
      () => ReportInput(
        target: input.target,
        reason: input.reason,
        details: '😀' * 1001,
      ).normalized(),
      throwsA(isA<ReportInputValidationException>()),
    );
  });
}
