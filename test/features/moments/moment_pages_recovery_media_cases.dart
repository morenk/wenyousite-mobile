import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_playback_image.dart';
import '../../support/moment_test_draft_store.dart';
import 'moment_pages_test_support.dart';

void registerMomentPagesRecoveryMediaCases() {
  testWidgets('动态评论上传中系统返回会取消任务并忽略迟到图片', (tester) async {
    final gateway = MomentPagesTestLateCompletingUploadGateway();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(MomentPagesTestMemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(
          MomentPagesTestFakeSessionRemote(),
        ),
        momentRepositoryProvider.overrideWithValue(
          MomentPagesTestPageRepository(),
        ),
        editorImagePickerPortProvider.overrideWithValue(
          MomentPagesTestFakeImagePicker(),
        ),
        mediaUploadGatewayPortProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(momentPagesTestTokensFor('user-1'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-comment-dock')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-comment-image')));
    await tester.pump();
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);

    expect(find.textContaining('正在上传'), findsOneWidget);
    expect(gateway.input?.purpose, MediaUploadPurpose.momentComment);
    await tester.binding.handlePopRoute();
    expect(gateway.operation.cancelled, isTrue);
    gateway.operation.complete(
      const UploadedEditorImage(
        mediaId: 'late-moment-image',
        url: 'https://cdn.example.com/late-moment.png',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('moment-comment-input')), findsNothing);
    expect(find.byKey(const ValueKey('late-moment-image')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('动态详情多图使用固定舞台横滑并从当前图片进入原图', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();
    final repository = MomentPagesTestPageRepository(
      detail: momentPagesTestDetailWithImages(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [momentRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final gallery = find.byKey(const Key('moment-detail-gallery'));
    final carousel = find.byKey(const Key('moment-detail-carousel'));
    expect(gallery, findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('动态图片轮播，共 3 张，左右滑动切换')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: gallery, matching: find.byType(GridView)),
      findsNothing,
    );
    expect(
      find.descendant(of: gallery, matching: find.byType(PageView)),
      findsOneWidget,
    );
    expect(find.text('1 / 3'), findsOneWidget);
    final firstImage = tester.widget<MomentPlaybackImage>(
      find.byKey(const Key('moment-content-image-0')),
    );
    expect(firstImage.previewUrls.first, 'https://cdn.example.com/1-md.webp');
    expect(firstImage.fit, BoxFit.contain);
    expect(
      tester.getBottomRight(find.text('今日微光')).dy,
      lessThan(tester.getTopLeft(gallery).dy),
    );
    expect(
      tester.getTopLeft(find.text('动态正文是纯文本')).dy,
      greaterThan(tester.getBottomRight(gallery).dy),
    );
    final initialStageSize = tester.getSize(gallery);
    expect(initialStageSize.width, 336);
    expect(initialStageSize.aspectRatio, closeTo(1, 0.01));

    await tester.drag(carousel, const Offset(-320, 0));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('2 / 3'), findsOneWidget);
    expect(tester.getSize(gallery), initialStageSize);
    final secondImage = tester.widget<MomentPlaybackImage>(
      find.byKey(const Key('moment-content-image-1')),
    );
    expect(secondImage.previewUrls.first, 'https://cdn.example.com/2-md.webp');
    expect(secondImage.fit, BoxFit.contain);

    await tester.tap(find.byKey(const Key('moment-detail-image')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('moment-gallery-close')), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('纯文字动态可完成发布且保留稳定详情目标', (tester) async {
    final repository = MomentPagesTestPageRepository();
    final draftStore = MemoryMomentDraftStore();
    final router = GoRouter(
      initialLocation: '/compose/moment',
      routes: [
        GoRoute(
          path: '/compose/moment',
          builder: (_, _) => const MomentComposePage(),
        ),
        GoRoute(
          path: '/moments/:momentId',
          name: 'moment-detail',
          builder: (_, state) =>
              Scaffold(body: Text('动态=${state.pathParameters['momentId']}')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(repository),
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'user-1',
          ),
          momentDraftStoreProvider.overrideWithValue(draftStore),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('moment-compose-title')),
      '新的动态',
    );
    momentPagesTestReplaceAtomicEditor(
      tester,
      const Key('moment-compose-content'),
      '纯文字也可以发布',
    );
    await tester.ensureVisible(find.byKey(const Key('moment-compose-submit')));
    await tester.tap(find.byKey(const Key('moment-compose-submit')));
    await tester.pumpAndSettle();

    expect(repository.createdInputs.single.mediaIds, isEmpty);
    expect(repository.createdInputs.single.title, '新的动态');
    expect(draftStore.draft, isNull);
    expect(find.text('动态=moment-1'), findsOneWidget);
  });

  testWidgets('动态邀请链接发布前成为可混排原子且保存规范正文', (tester) async {
    const url = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
    final repository = MomentPagesTestPageRepository();
    final router = GoRouter(
      initialLocation: '/compose/moment',
      routes: [
        GoRoute(
          path: '/compose/moment',
          builder: (_, _) => const MomentComposePage(),
        ),
        GoRoute(
          path: '/moments/:momentId',
          name: 'moment-detail',
          builder: (_, state) =>
              Scaffold(body: Text('动态=${state.pathParameters['momentId']}')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(repository),
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'user-1',
          ),
          momentDraftStoreProvider.overrideWithValue(MemoryMomentDraftStore()),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('moment-compose-title')),
      '私密入口',
    );
    momentPagesTestReplaceAtomicEditor(
      tester,
      const Key('moment-compose-content'),
      url,
    );
    await tester.pump();

    expect(
      find.byKey(const Key('atomic-editor-internal-reference')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('站内传送门：传送门'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('moment-compose-submit')));
    await tester.tap(find.byKey(const Key('moment-compose-submit')));
    await tester.pumpAndSettle();

    expect(
      repository.createdInputs.single.content,
      '[传送门](/join/AbCdEfGh_123-XYZ)',
    );
    expect(find.text('动态=moment-1'), findsOneWidget);
  });

  testWidgets('动态草稿恢复文字与图片顺序并在离开前确认', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final draftStore = MemoryMomentDraftStore()
      ..draft = MomentLocalDraft(
        title: '未完成的标题',
        content: '未完成的正文',
        images: const [
          UploadedEditorImage(
            mediaId: 'media-2',
            url: 'https://cdn.example.com/2.webp',
          ),
          UploadedEditorImage(
            mediaId: 'media-1',
            url: 'https://cdn.example.com/1.webp',
          ),
        ],
        coverMediaId: 'media-2',
        updatedAt: DateTime.utc(2026, 8, 11, 8),
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(
            MomentPagesTestPageRepository(),
          ),
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'user-1',
          ),
          momentDraftStoreProvider.overrideWithValue(draftStore),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('已恢复上次的草稿'), findsOneWidget);
    expect(find.text('重新开始'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('moment-compose-title')))
          .controller!
          .text,
      '未完成的标题',
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('media-2'))).dx,
      lessThan(tester.getTopLeft(find.byKey(const ValueKey('media-1'))).dx),
    );
    final publish = find.byKey(const Key('moment-compose-submit'));
    expect(publish, findsOneWidget);
    expect(tester.getBottomRight(publish).dy, lessThanOrEqualTo(752));

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('已恢复上次的草稿'), findsNothing);
    expect(find.text('重新开始'), findsNothing);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('moment-compose-title')))
          .controller!
          .text,
      '未完成的标题',
    );

    await tester.enterText(
      find.byKey(const Key('moment-compose-title')),
      '自动保存后的标题',
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(draftStore.draft?.title, '自动保存后的标题');
    expect(draftStore.draft?.images.map((image) => image.mediaId), [
      'media-2',
      'media-1',
    ]);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('要保存这次编辑吗？'), findsOneWidget);
    expect(find.text('保存草稿并退出'), findsOneWidget);
    expect(find.text('不保存'), findsOneWidget);
    expect(find.byKey(const Key('moment-leave-save')), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('要保存这次编辑吗？'), findsNothing);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('moment-compose-title')))
          .controller!
          .text,
      '自动保存后的标题',
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-leave-save')));
    await tester.pumpAndSettle();
    expect(draftStore.draft?.title, '自动保存后的标题');
  });

  testWidgets('取消失败的图片批次会保留已经上传完成的图片', (tester) async {
    final gateway = MomentPagesTestFirstSuccessfulThenFailingUploadGateway();
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
          editorImagePickerPortProvider.overrideWithValue(
            MomentPagesTestFakeMultiImagePicker(),
          ),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('moment-compose-add-image')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);

    expect(
      find.byKey(const ValueKey('moment-local-thumbnail-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('moment-compose-upload-failure')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('moment-compose-cancel-upload')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('moment-image-1')), findsOneWidget);
    expect(
      find.byKey(const Key('moment-compose-upload-failure')),
      findsNothing,
    );
    expect(find.text('1/9'), findsOneWidget);
  });

  testWidgets('动态图片可点按选封面、长按排序并在移除封面后自动回退', (tester) async {
    final semantics = tester.ensureSemantics();
    final draftStore = MemoryMomentDraftStore()
      ..draft = MomentLocalDraft(
        title: '图片动态',
        content: '',
        images: const [
          UploadedEditorImage(
            mediaId: 'media-2',
            url: 'https://cdn.example.com/2.webp',
          ),
          UploadedEditorImage(
            mediaId: 'media-1',
            url: 'https://cdn.example.com/1.webp',
          ),
        ],
        coverMediaId: 'media-2',
        updatedAt: DateTime.utc(2026, 8, 11, 8),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(
            MomentPagesTestPageRepository(),
          ),
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'user-1',
          ),
          momentDraftStoreProvider.overrideWithValue(draftStore),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('图片 2，点按设为封面')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('media-1')));
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('media-1')),
        matching: find.text('封面'),
      ),
      findsOneWidget,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('media-2'))),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(const Offset(180, 0));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('media-1'))).dx,
      lessThan(tester.getTopLeft(find.byKey(const ValueKey('media-2'))).dx),
    );

    await tester.tap(find.byTooltip('移除图片 1'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('media-1')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('media-2')),
        matching: find.text('封面'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('动态编辑冲突明确提供保留本机内容或使用最新内容', (tester) async {
    final repository = MomentPagesTestConflictPageRepository();
    final draftStore = MemoryMomentDraftStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(repository),
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'user-1',
          ),
          momentDraftStoreProvider.overrideWithValue(draftStore),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('moment-compose-title')),
      '保留在本机的标题',
    );
    await tester.tap(find.byKey(const Key('moment-compose-submit')));
    await tester.pumpAndSettle();

    expect(find.text('这条动态刚刚更新了。'), findsOneWidget);
    await tester.tap(find.byKey(const Key('moment-compose-resolve-conflict')));
    await tester.pumpAndSettle();
    expect(find.text('保留我的内容'), findsOneWidget);
    expect(find.text('使用最新内容'), findsOneWidget);

    await tester.tap(find.byKey(const Key('moment-conflict-use-latest')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('moment-compose-title')))
          .controller!
          .text,
      '服务端最新标题',
    );
    expect(draftStore.draft, isNull);
  });
}
