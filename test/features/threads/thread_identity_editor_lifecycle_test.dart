import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_widgets.dart';

import '../posts/post_replies_page_test_support.dart';

class _Repository extends Mock implements ThreadIdentityRepository {}

const _identity = ThreadIdentityState(
  threadId: 'thread',
  userId: 'author-1',
  enabled: true,
  eligible: true,
  canEdit: true,
  accountName: '站内用户',
  identityId: 'rp',
  canDelete: true,
  nickname: '白鸦',
  avatarMediaId: 'custom-avatar',
  version: 1,
  display: RpIdentity(id: 'rp', nickname: '白鸦'),
);

void main() {
  setUpAll(() => registerFallbackValue(const ThreadIdentityUpdate()));

  Future<_Repository> pumpEditor(
    WidgetTester tester, {
    bool creating = false,
    ThreadIdentityEditorDraft? draft,
  }) async {
    final repo = _Repository();
    when(() => repo.find('thread', 'rp')).thenAnswer((_) async => _identity);
    when(() => repo.list('thread')).thenAnswer(
      (_) async => const ThreadIdentityCollection(
        account: ThreadIdentityState(
          threadId: 'thread',
          userId: 'author-1',
          enabled: true,
          eligible: true,
          canEdit: true,
          accountName: '站内用户',
        ),
        identities: [],
      ),
    );
    final container = await postRepliesPageTestPostContainer(
      PostRepliesPageTestFakePostRepository(),
      userId: 'author-1',
      identityRepository: repo,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: Text('主题列表')),
          initialRoute: '/topic',
          routes: {
            '/topic': (_) => Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showThreadIdentityEditor(
                    context,
                    'thread',
                    identityId: creating ? null : 'rp',
                    draft: draft,
                  ),
                  child: const Text('打开'),
                ),
              ),
            ),
          },
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    return repo;
  }

  testWidgets('同帧重复关闭只退出身份表单，保留底层主题页面', (tester) async {
    await pumpEditor(tester);
    final close = tester
        .widget<IconButton>(
          find.byWidgetPredicate(
            (widget) => widget is IconButton && widget.tooltip == '关闭设置帖内身份',
          ),
        )
        .onPressed!;
    close();
    close();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-identity-nickname')), findsNothing);
    expect(find.text('打开'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('未保存昵称的关闭和系统返回都先确认，继续编辑保留输入', (tester) async {
    final repo = await pumpEditor(tester);
    final input = find.byKey(const Key('thread-identity-nickname'));
    await tester.enterText(input, '未保存的名字');
    await tester.pump();
    await tester.tap(find.byTooltip('关闭设置帖内身份'));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsOneWidget);
    await tester.tap(find.text('继续编辑'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(input).controller!.text, '未保存的名字');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-identity-discard')));
    await tester.pumpAndSettle();
    expect(input, findsNothing);
    verifyNever(() => repo.updateRole(any(), any(), any()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('仅恢复头像也属于未保存修改，遮罩不会误关表单', (tester) async {
    await pumpEditor(tester);
    await tester.tap(find.byKey(const Key('thread-identity-clear-avatar')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-identity-nickname')), findsOneWidget);
    await tester.tap(find.byTooltip('关闭设置帖内身份'));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsOneWidget);
  });

  testWidgets('保存期间不允许关闭，成功后正常返回资料', (tester) async {
    final repo = await pumpEditor(tester);
    final pending = Completer<ThreadIdentityState>();
    when(
      () => repo.updateRole('thread', 'rp', any()),
    ).thenAnswer((_) => pending.future);
    await tester.enterText(
      find.byKey(const Key('thread-identity-nickname')),
      '夜渡',
    );
    await tester.ensureVisible(find.byKey(const Key('thread-identity-save')));
    await tester.tap(find.byKey(const Key('thread-identity-save')));
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) => widget is IconButton && widget.tooltip == '关闭设置帖内身份',
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byKey(const Key('thread-identity-nickname')), findsOneWidget);
    pending.complete(_identity);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-identity-nickname')), findsNothing);
    verify(() => repo.updateRole('thread', 'rp', any())).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('打开新增不占名额，空白不能保存，设置昵称后才创建', (tester) async {
    final repo = await pumpEditor(tester, creating: true);
    when(() => repo.create('thread', any())).thenAnswer((_) async => _identity);
    verifyNever(() => repo.create(any(), any()));
    await tester.ensureVisible(find.byKey(const Key('thread-identity-save')));
    await tester.tap(find.byKey(const Key('thread-identity-save')));
    await tester.pumpAndSettle();
    expect(find.text('请设置昵称或头像'), findsOneWidget);
    verifyNever(() => repo.create(any(), any()));
    await tester.enterText(
      find.byKey(const Key('thread-identity-nickname')),
      '新角色',
    );
    await tester.tap(find.byKey(const Key('thread-identity-save')));
    await tester.pumpAndSettle();
    final input =
        verify(() => repo.create('thread', captureAny())).captured.single
            as ThreadIdentityUpdate;
    expect(input.nickname, '新角色');
    expect(find.byKey(const Key('thread-identity-nickname')), findsNothing);
  });

  testWidgets('新建结果不明不重放，返回原菜单再打开仍保留输入', (tester) async {
    final draft = ThreadIdentityEditorDraft();
    final repo = await pumpEditor(tester, creating: true, draft: draft);
    when(
      () => repo.create('thread', any()),
    ).thenThrow(const ApiFailure(reason: FailureReason.timeout));
    await tester.enterText(
      find.byKey(const Key('thread-identity-nickname')),
      '同名角色',
    );
    await tester.ensureVisible(find.byKey(const Key('thread-identity-save')));
    await tester.tap(find.byKey(const Key('thread-identity-save')));
    await tester.pumpAndSettle();
    verify(() => repo.create('thread', any())).called(1);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('thread-identity-nickname')))
          .controller!
          .text,
      '同名角色',
    );
    await tester.ensureVisible(find.text('返回身份列表'));
    await tester.tap(find.text('返回身份列表'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('thread-identity-nickname')))
          .controller!
          .text,
      '同名角色',
    );
    await tester.ensureVisible(find.byKey(const Key('thread-identity-save')));
    final save = tester
        .widget<FilledButton>(find.byKey(const Key('thread-identity-save')))
        .onPressed!;
    save();
    save();
    await tester.pumpAndSettle();
    expect(find.text('再次新建身份？'), findsOneWidget);
    verifyNever(() => repo.create('thread', any()));
    await tester.tap(find.text('返回'));
    await tester.pumpAndSettle();
  });

  testWidgets('关闭主题RP先说明影响，取消不写入，确认才关闭', (tester) async {
    final repo = _Repository();
    when(
      () => repo.setEnabled('thread', enabled: false),
    ).thenAnswer((_) async {});
    final container = await postRepliesPageTestPostContainer(
      PostRepliesPageTestFakePostRepository(),
      userId: 'author-1',
      identityRepository: repo,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ThreadIdentitySettings(
              threadId: 'thread',
              initialEnabled: true,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('关闭帖内身份？'), findsOneWidget);
    await tester.tap(find.text('保持开启'));
    await tester.pumpAndSettle();
    verifyNever(() => repo.setEnabled('thread', enabled: false));
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-identity-disable-confirm')));
    await tester.pumpAndSettle();
    verify(() => repo.setEnabled('thread', enabled: false)).called(1);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });
}
