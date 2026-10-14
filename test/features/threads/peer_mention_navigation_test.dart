import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_widgets.dart';

void main() {
  const roleA = 'caaaaaaaaaaaaaaaaaaaaaaaa';
  const roleB = 'cbbbbbbbbbbbbbbbbbbbbbbbb';
  const hrefA = '/users/account?rpIdentityId=$roleA';
  const hrefB = '/users/account?rpIdentityId=$roleB';
  const hrefAccount = '/users/account?identityMode=ACCOUNT';

  testWidgets('同账号同名三个提及保留各自目标，账号直达主页，角色B只读取B', (tester) async {
    final reads = <String>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: ThreadIdentityReadingScope(
              threadId: 'thread',
              available: true,
              child: Builder(
                builder: (context) => WenyouMarkdown(
                  data: '[@同名]($hrefA) [@同名]($hrefB) [@同名]($hrefAccount)',
                  mentionLabels: const {
                    '$hrefA\u0000同名': '角色甲',
                    '$hrefB\u0000同名': '角色乙',
                    '$hrefAccount\u0000同名': '站内账号',
                  },
                  onInternalLink: (uri) => openThreadReadingLink(context, uri),
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/users/:id',
          builder: (_, state) =>
              Scaffold(body: Text('主页 ${state.pathParameters['id']}')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          for (final id in [roleA, roleB])
            rpIdentityCardProvider((
              threadId: 'thread',
              userId: 'account',
              identityId: id,
            )).overrideWith((ref) async {
              reads.add(id);
              return ThreadIdentityState(
                threadId: 'thread',
                userId: 'account',
                enabled: true,
                eligible: true,
                canEdit: false,
                accountName: '站内账号',
                display: RpIdentity(id: id, nickname: '当前角色乙'),
              );
            }),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    expect(find.text('@角色甲'), findsOneWidget);
    expect(find.text('@角色乙'), findsOneWidget);
    await tester.tap(find.text('@站内账号'));
    await tester.pumpAndSettle();
    expect(find.text('主页 account'), findsOneWidget);
    expect(reads, isEmpty);
    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('@角色乙'));
    await tester.pumpAndSettle();
    expect(reads, [roleB]);
    expect(find.text('当前角色乙'), findsOneWidget);
    expect(find.text('帖内身份'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
