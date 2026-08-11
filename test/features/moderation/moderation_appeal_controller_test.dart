import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moderation/application/moderation_appeal_controller.dart';
import 'package:wenyousite_mobile/features/moderation/data/moderation_appeal_repository.dart';
import 'package:wenyousite_mobile/features/moderation/domain/moderation_appeal_models.dart';

void main() {
  test('游客验证后只用申诉专用凭据读取与提交', () async {
    final repository = _FakeRepository();
    final controller = ModerationAppealController(
      repository,
      authenticated: false,
    );
    addTearDown(controller.dispose);

    expect(controller.state.phase, ModerationAppealPhase.credential);
    expect(
      await controller.issueCredential(
        account: 'tester',
        password: 'password123',
      ),
      isTrue,
    );
    expect(controller.state.phase, ModerationAppealPhase.ready);
    expect(repository.fetchTokens, ['appeal-token']);

    expect(
      await controller.submit(
        decisionId: 'decision-1',
        statement: '这是需要重新复核的完整事实说明。',
      ),
      isTrue,
    );
    expect(repository.submitTokens, ['appeal-token']);
    expect(repository.statements, ['这是需要重新复核的完整事实说明。']);
  });

  test('普通登录直接读取，申诉 token 失效只清专用凭据并返回验证页', () async {
    final normalRepository = _FakeRepository();
    final normalController = ModerationAppealController(
      normalRepository,
      authenticated: true,
    );
    addTearDown(normalController.dispose);
    await _flush();
    expect(normalController.state.phase, ModerationAppealPhase.ready);
    expect(normalRepository.fetchTokens, [null]);

    final restrictedRepository = _FakeRepository(failSubmitWithExpired: true);
    final restrictedController = ModerationAppealController(
      restrictedRepository,
      authenticated: false,
    );
    addTearDown(restrictedController.dispose);
    await restrictedController.issueCredential(
      account: 'tester',
      password: 'password123',
    );
    expect(
      await restrictedController.submit(
        decisionId: 'decision-1',
        statement: '这是需要重新复核的完整事实说明。',
      ),
      isFalse,
    );
    expect(restrictedController.state.phase, ModerationAppealPhase.credential);
    expect(restrictedController.state.failure?.businessCode, 40120);
  });

  test('提交已落库后即使权威重读失败也关闭表单，避免重复申诉', () async {
    final repository = _FakeRepository(failSecondFetch: true);
    final controller = ModerationAppealController(
      repository,
      authenticated: false,
    );
    addTearDown(controller.dispose);
    await controller.issueCredential(
      account: 'tester',
      password: 'password123',
    );

    expect(
      await controller.submit(
        decisionId: 'decision-1',
        statement: '这是需要重新复核的完整事实说明。',
      ),
      isTrue,
    );
    expect(controller.state.phase, ModerationAppealPhase.failed);
    expect(controller.state.decisions, isNotEmpty);
  });

  test('重复待处理申诉冲突按服务端事实重读并视为已提交', () async {
    final repository = _FakeRepository(conflictSubmit: true);
    final controller = ModerationAppealController(
      repository,
      authenticated: false,
    );
    addTearDown(controller.dispose);
    await controller.issueCredential(
      account: 'tester',
      password: 'password123',
    );

    expect(
      await controller.submit(
        decisionId: 'decision-1',
        statement: '这是需要重新复核的完整事实说明。',
      ),
      isTrue,
    );
    expect(controller.state.phase, ModerationAppealPhase.ready);
    expect(repository.fetchTokens, ['appeal-token', 'appeal-token']);
  });
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

class _FakeRepository implements ModerationAppealRepository {
  _FakeRepository({
    this.failSubmitWithExpired = false,
    this.failSecondFetch = false,
    this.conflictSubmit = false,
  });

  final bool failSubmitWithExpired;
  final bool failSecondFetch;
  final bool conflictSubmit;
  final List<String?> fetchTokens = [];
  final List<String?> submitTokens = [];
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
    fetchTokens.add(appealToken);
    if (failSecondFetch && fetchTokens.length == 2) {
      throw const ApiFailure(userMessage: '读取申诉结果失败。');
    }
    return [_decision];
  }

  @override
  Future<void> submitAppeal({
    required String decisionId,
    required String statement,
    String? appealToken,
  }) async {
    submitTokens.add(appealToken);
    statements.add(statement);
    if (failSubmitWithExpired) {
      throw const ApiFailure(
        userMessage: '申诉凭据已过期，请重新验证账号密码。',
        businessCode: 40120,
      );
    }
    if (conflictSubmit) {
      throw const ApiFailure(userMessage: '该处罚已有待处理申诉。', businessCode: 40921);
    }
  }
}

final _decision = ModerationDecision(
  id: 'decision-1',
  targetType: 'USER',
  targetId: 'user-1',
  action: 'SUSPEND_USER',
  policyCode: 'HARASSMENT',
  publicExplanation: '多次骚扰其他用户。',
  active: true,
  createdAt: DateTime.utc(2026, 8, 12),
);
