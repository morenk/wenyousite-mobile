import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_profile.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_widgets.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_post_author_line.dart';

void main() {
  for (final hasRp in [false, true]) {
    testWidgets('${hasRp ? 'RP' : '站内'}发言按该条身份导航，目标始终为真实账号', (tester) async {
      var identityReads = 0;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: ThreadIdentityReadingScope(
                threadId: 'thread',
                available: true,
                ownerId: 'account-1',
                child: ThreadPostAuthorLine(
                  avatarKey: const Key('author-avatar'),
                  author: ThreadAuthorModel(
                    id: 'account-1',
                    username: '站内用户',
                    level: 1,
                    rpIdentity: hasRp
                        ? const RpIdentity(id: 'rp-1', nickname: '旧角色')
                        : null,
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
            appCapabilitiesProvider.overrideWithValue(
              const AppCapabilities(rpIdentityProfileSupported: true),
            ),
            identityProfilePreviewBuilderProvider.overrideWithValue(
              ({required threadId, required postId, required onOpenPost}) =>
                  Text('当前资料 $postId'),
            ),
            rpIdentityCardProvider((
              threadId: 'thread',
              userId: 'account-1',
              identityId: 'rp-1',
            )).overrideWith((ref) async {
              identityReads++;
              return const ThreadIdentityState(
                threadId: 'thread',
                userId: 'account-1',
                enabled: true,
                eligible: true,
                canEdit: false,
                accountName: '站内用户',
                display: RpIdentity(id: 'rp-1', nickname: '新角色'),
                profilePostId: 'current-profile',
                profilePostStatus: IdentityProfilePostStatus.available,
              );
            }),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('author-avatar')));
      await tester.pumpAndSettle();
      if (hasRp) {
        expect(find.text('帖内身份'), findsOneWidget);
        expect(find.text('旧角色'), findsWidgets);
        expect(find.text('新角色'), findsNothing);
        expect(find.text('当前资料 current-profile'), findsOneWidget);
        expect(identityReads, 1);
        await tester.tap(find.byKey(const Key('thread-identity-open-account')));
        await tester.pumpAndSettle();
      } else {
        expect(find.text('帖内身份'), findsNothing);
        expect(identityReads, 0);
      }
      expect(find.text('主页 account-1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
