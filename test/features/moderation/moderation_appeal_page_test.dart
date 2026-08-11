import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/moderation/data/moderation_appeal_repository.dart';
import 'package:wenyousite_mobile/features/moderation/domain/moderation_appeal_models.dart';
import 'package:wenyousite_mobile/features/moderation/presentation/moderation_appeal_page.dart';

void main() {
  testWidgets('360dp 受限账号验证、查看决定与提交一次申诉形成闭环', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _PageRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          moderationAppealRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ModerationAppealPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('验证受限账号'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('appeal-account')), 'tester');
    await tester.enterText(
      find.byKey(const Key('appeal-password')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('appeal-credential-submit')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('暂停账号'), findsOneWidget);
    expect(find.text('多次骚扰其他用户。'), findsOneWidget);
    expect(find.byKey(const Key('appeal-credential-expiry')), findsOneWidget);
    await tester.tap(find.byKey(const Key('appeal-open-decision-1')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('appeal-statement')), '太短');
    await tester.tap(find.byKey(const Key('appeal-submit')));
    await tester.pump();
    expect(find.text('请至少写 10 个字'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('appeal-statement')),
      '这是需要重新复核的完整事实说明。',
    );
    await tester.tap(find.byKey(const Key('appeal-submit')));
    await tester.pumpAndSettle();

    expect(repository.statements, ['这是需要重新复核的完整事实说明。']);
    expect(find.text('申诉已提交。'), findsOneWidget);
    expect(find.text('已提交申诉'), findsOneWidget);
    expect(find.text('待复核'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _PageRepository implements ModerationAppealRepository {
  final List<String> statements = [];

  @override
  Future<AppealCredential> issueCredential({
    required String account,
    required String password,
  }) async {
    return AppealCredential(
      token: 'appeal-token',
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 15)),
    );
  }

  @override
  Future<List<ModerationDecision>> fetchMyDecisions({
    String? appealToken,
  }) async {
    return [_decision(appealed: statements.isNotEmpty)];
  }

  @override
  Future<void> submitAppeal({
    required String decisionId,
    required String statement,
    String? appealToken,
  }) async {
    statements.add(statement);
  }
}

ModerationDecision _decision({required bool appealed}) {
  return ModerationDecision(
    id: 'decision-1',
    targetType: 'USER',
    targetId: 'user-1',
    action: 'SUSPEND_USER',
    policyCode: 'HARASSMENT',
    publicExplanation: '多次骚扰其他用户。',
    active: true,
    createdAt: DateTime.utc(2026, 8, 12),
    appeal: appealed
        ? ModerationAppealSummary(
            id: 'appeal-1',
            statement: statementsPlaceholder,
            status: ModerationAppealStatus.pending,
            createdAt: DateTime.utc(2026, 8, 12, 12),
          )
        : null,
  );
}

const statementsPlaceholder = '这是需要重新复核的完整事实说明。';
