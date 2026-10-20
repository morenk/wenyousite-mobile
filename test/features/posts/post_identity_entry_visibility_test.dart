import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_identity_composer_bar.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

import '../../support/thread_identity_fixtures.dart';
import 'post_replies_page_test_support.dart';

class _Identities extends Mock implements ThreadIdentityRepository {
  late ThreadIdentityState current;

  @override
  Future<ThreadIdentityCollection> list(String threadId) async =>
      identityTestCollection(current);
}

ThreadIdentityState _identity(bool enabled, bool eligible) =>
    ThreadIdentityState(
      threadId: 'thread',
      userId: 'author-1',
      enabled: enabled,
      eligible: eligible,
      canEdit: enabled && eligible,
      accountName: '站内账号',
    );

void main() {
  for (final kind in PostComposerKind.values) {
    for (final flags in [(false, true), (true, false), (true, true)]) {
      testWidgets('$kind 在 $flags 时按资格展示身份或原标题', (tester) async {
        final identities = _Identities()
          ..current = _identity(flags.$1, flags.$2);
        final container = await postRepliesPageTestPostContainer(
          PostRepliesPageTestFakePostRepository(),
          userId: 'author-1',
          identityRepository: identities,
        );
        addTearDown(container.dispose);
        final editing = kind == PostComposerKind.editPost;
        final target = (
          kind: kind,
          threadId: 'thread',
          subthreadId: 'subthread',
          postId: editing ? 'reply-own' : null,
          parentPostId: kind == PostComposerKind.createReply ? 'parent' : null,
          replyToPostId: null,
          version: editing ? 1 : null,
          initialContent: '',
          label: '当前编辑操作',
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showPostComposerSheet(
                      context: context,
                      target: target,
                      supportsRpIdentity: true,
                    ),
                    child: const Text('打开'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('打开'));
        await postRepliesPageTestPumpUi(tester);
        final visible = flags.$1 && flags.$2 && !editing;
        expect(
          find.byKey(const Key('post-composer-identity-mode')),
          visible ? findsOneWidget : findsNothing,
        );
        expect(find.text('当前编辑操作'), visible ? findsNothing : findsOneWidget);
        expect(find.text('站内账号'), visible ? findsOneWidget : findsNothing);
        expect(find.byKey(const Key('post-composer-expand')), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const Key('post-composer-header'))).height,
          60,
        );
        if (visible) {
          final selection = tester
              .widget<PostIdentityComposerBar>(
                find.byType(PostIdentityComposerBar),
              )
              .selection;
          identities.current = _identity(true, false);
          await selection.refresh();
          await postRepliesPageTestPumpUi(tester);
          expect(
            find.byKey(const Key('post-composer-identity-mode')),
            findsNothing,
          );
          expect(find.text('当前编辑操作'), findsOneWidget);
          identities.current = _identity(true, true);
          await selection.refresh();
          await postRepliesPageTestPumpUi(tester);
          expect(
            find.byKey(const Key('post-composer-identity-mode')),
            findsOneWidget,
          );
          expect(find.text('当前编辑操作'), findsNothing);
        }
        expect(tester.takeException(), isNull);
        await postRepliesPageTestDismissPostComposerFromOutside(tester);
      });
    }
  }
}
