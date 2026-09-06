import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';
import '../../support/foundation_test_fonts.dart';
import '../../support/moment_test_draft_store.dart';
import 'moment_pages_test_support.dart';

void registerMomentPagesLayoutCases() {
  setUpAll(loadFoundationTestFonts);
  testWidgets('360dp 键盘态动态发布页保持主操作可见且语义明确', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(
            MomentPagesTestPageRepository(),
          ),
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'user-1',
          ),
          momentDraftStoreProvider.overrideWithValue(MemoryMomentDraftStore()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('标题（必填）')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('正文（选填）')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('moment-compose-submit'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('360dp 纯文字动态发布页保持 Foundation 视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(
            MomentPagesTestPageRepository(),
          ),
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'user-1',
          ),
          momentDraftStoreProvider.overrideWithValue(MemoryMomentDraftStore()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RepaintBoundary(
            key: Key('moment-compose-text-visual'),
            child: MomentComposePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('moment-compose-text-visual')),
      matchesGoldenFile('goldens/moment_compose_text_360.png'),
    );
  });

  testWidgets('360dp 多图动态编辑页保持 Foundation 视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(
            MomentPagesTestPageRepository(
              detail: momentPagesTestEditableDetailWithImages(),
            ),
          ),
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'user-1',
          ),
          momentDraftStoreProvider.overrideWithValue(MemoryMomentDraftStore()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RepaintBoundary(
            key: Key('moment-compose-images-visual'),
            child: MomentComposePage(momentId: 'moment-1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getBottomRight(find.byKey(const Key('moment-compose-submit'))).dy,
      lessThanOrEqualTo(760),
    );
    await expectLater(
      find.byKey(const Key('moment-compose-images-visual')),
      matchesGoldenFile('goldens/moment_compose_images_360.png'),
    );
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 动态信息流、详情与发布页无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = MomentPagesTestPageRepository();

      await tester.pumpWidget(momentPagesTestFeedApp(repository));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            momentRepositoryProvider.overrideWithValue(repository),
            momentComposerOwnerResolverProvider.overrideWithValue(
              () async => 'user-1',
            ),
            momentDraftStoreProvider.overrideWithValue(
              MemoryMomentDraftStore(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MomentDetailPage(momentId: 'moment-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            momentRepositoryProvider.overrideWithValue(repository),
            momentComposerOwnerResolverProvider.overrideWithValue(
              () async => 'user-1',
            ),
            momentDraftStoreProvider.overrideWithValue(
              MemoryMomentDraftStore(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MomentComposePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
