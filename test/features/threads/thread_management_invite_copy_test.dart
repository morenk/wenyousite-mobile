import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';
import 'thread_management_test_support.dart';

void main() {
  final copied = <String>[];
  setUp(() {
    copied.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null),
  );

  testWidgets('主题设置直接显示复制邀请行且没有私密邀请抽屉入口', (tester) async {
    await pumpThreadManagementTestPage(
      tester,
      ThreadManagementTestRepository(
        initial: threadManagementTestBootstrap(
          visibility: ThreadManagementVisibility.private,
        ),
      ),
      invitationRepository: ThreadManagementTestInvitationRepository(),
    );
    expect(find.text('复制邀请链接'), findsOneWidget);
    expect(find.text('私密邀请'), findsNothing);
    expect(find.text('重置邀请链接'), findsNothing);
  });

  testWidgets('待保存标题只点击一次复制，同次等待保存后取链并复制', (tester) async {
    final completed = Completer<void>();
    final repository = _DelayedSave(completed.future);
    final invitation = ThreadManagementTestInvitationRepository();
    await pumpThreadManagementTestPage(
      tester,
      repository,
      invitationRepository: invitation,
    );
    await tester.enterText(
      find.byKey(const Key('thread-management-title')),
      '保存后才分享的标题',
    );
    final copy = find.byKey(const Key('thread-invite-link-copy'));
    await tester.ensureVisible(copy);
    await tester.tap(copy);
    await tester.pump();
    expect(repository.lastDraft?.title, '保存后才分享的标题');
    expect(invitation.ensureCalls, 0);
    expect(copied, isEmpty);
    completed.complete();
    await tester.pumpAndSettle();
    expect(repository.updateCalls, 1);
    expect(invitation.ensureCalls, 1);
    expect(copied, hasLength(1));
    expect(find.byKey(const Key('thread-invite-link-value')), findsNothing);
    expect(find.text('私密邀请'), findsNothing);
  });

  testWidgets('设置保存失败不取邀请链接', (tester) async {
    final repository = ThreadManagementTestRepository(
      initial: threadManagementTestBootstrap(
        visibility: ThreadManagementVisibility.private,
      ),
      updateFailure: const ApiFailure(userMessage: '保存失败'),
    );
    final invitation = ThreadManagementTestInvitationRepository();
    await pumpThreadManagementTestPage(
      tester,
      repository,
      invitationRepository: invitation,
    );
    await tester.enterText(
      find.byKey(const Key('thread-management-title')),
      '尚未保存',
    );
    await tester.tap(find.byKey(const Key('thread-invite-link-copy')));
    await tester.pumpAndSettle();
    expect(invitation.ensureCalls, 0);
    expect(copied, isEmpty);
    expect(find.text('未保存'), findsOneWidget);
  });

  testWidgets('保存后已不再有私密邀请权限则同次不取链', (tester) async {
    final completed = Completer<void>();
    final repository = _DelayedSave(completed.future, revoke: true);
    final invitation = ThreadManagementTestInvitationRepository();
    await pumpThreadManagementTestPage(
      tester,
      repository,
      invitationRepository: invitation,
    );
    await tester.enterText(
      find.byKey(const Key('thread-management-title')),
      '保存时权限变化',
    );
    await tester.tap(find.byKey(const Key('thread-invite-link-copy')));
    await tester.pump();
    completed.complete();
    await tester.pumpAndSettle();
    expect(invitation.ensureCalls, 0);
    expect(copied, isEmpty);
    expect(find.byKey(const Key('thread-invite-link-copy')), findsNothing);
  });

  for (final invalid in ['public', 'draft', 'collaborator']) {
    testWidgets('$invalid 没有复制邀请入口', (tester) async {
      await pumpThreadManagementTestPage(
        tester,
        ThreadManagementTestRepository(
          initial: threadManagementTestBootstrap(
            visibility: invalid == 'public'
                ? ThreadManagementVisibility.public
                : ThreadManagementVisibility.private,
            published: invalid != 'draft',
            isOwner: invalid != 'collaborator',
          ),
        ),
      );
      expect(find.byKey(const Key('thread-invite-link-copy')), findsNothing);
    });
  }
}

class _DelayedSave extends ThreadManagementTestRepository {
  _DelayedSave(this.completed, {this.revoke = false})
    : super(
        initial: threadManagementTestBootstrap(
          visibility: ThreadManagementVisibility.private,
        ),
      );
  final Future<void> completed;
  final bool revoke;
  @override
  Future<ThreadManagementSnapshot> update({
    required ThreadManagementSnapshot current,
    required ThreadManagementDraft draft,
  }) async {
    final updated = await super.update(current: current, draft: draft);
    await completed;
    return revoke
        ? threadManagementTestBootstrap(
            isOwner: false,
            title: updated.title,
            visibility: updated.visibility,
          ).thread
        : updated;
  }
}
