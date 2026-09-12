import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_composer_dock.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';
import '../../support/deterministic_test_fonts.dart';
import '../../support/moment_test_draft_store.dart';
import 'moment_pages_test_support.dart';

void registerMomentPagesComposeUploadCases() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('动态详情按来源返回且直接进入时回到动态列表', (tester) async {
    final router = GoRouter(
      initialLocation: '/moments/moment-1',
      routes: [
        GoRoute(
          path: '/moments',
          name: 'moments',
          builder: (_, _) => const Scaffold(
            body: Text('动态列表返回目标', key: Key('moment-back-target')),
          ),
        ),
        GoRoute(
          path: '/moments/:momentId',
          name: 'moment-detail',
          builder: (_, state) =>
              MomentDetailPage(momentId: state.pathParameters['momentId']!),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(
            MomentPagesTestPageRepository(),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('moment-detail-back')), findsOneWidget);
    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue);
    expect(find.byKey(const Key('moment-back-target')), findsOneWidget);

    unawaited(
      router.pushNamed(
        'moment-detail',
        pathParameters: const {'momentId': 'moment-1'},
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-detail-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-back-target')), findsOneWidget);
  });

  testWidgets('动态详情滚动时顶栏和评论入口保持固定', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(
            MomentPagesTestPageRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('动态').hitTestable(), findsOneWidget);
    await tester.drag(
      find.byKey(const PageStorageKey('moment-detail-scroll')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.text('动态').hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-dock')), findsOneWidget);

    await tester.drag(
      find.byKey(const PageStorageKey('moment-detail-scroll')),
      const Offset(0, 120),
    );
    await tester.pumpAndSettle();
    expect(find.text('动态').hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-dock')), findsOneWidget);
  });

  testWidgets('动态互动栏评论可唤起并聚焦发布输入且评论点击带入回复对象', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = MomentPagesTestPageRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(MomentPagesTestMemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(
          MomentPagesTestFakeSessionRemote(),
        ),
        momentRepositoryProvider.overrideWithValue(repository),
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

    final dock = find.byKey(const Key('moment-comment-dock'));
    expect(dock, findsOneWidget);
    expect(find.text('发表评论…'), findsOneWidget);
    expect(tester.getBottomRight(dock).dy, lessThanOrEqualTo(760));

    await tester.tap(find.byKey(const Key('moment-detail-comments')));
    await tester.pumpAndSettle();
    expect(find.byType(DraggableScrollableSheet), findsNothing);
    expect(find.byKey(const Key('moment-comment-dock')), findsNothing);
    expect(find.byKey(const Key('moment-comment-editor-dock')), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-input')), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-close')), findsNothing);
    expect(find.byType(QuillEditor), findsOneWidget);
    expect(
      tester
          .widget<QuillEditor>(find.byKey(const Key('moment-comment-input')))
          .focusNode
          .hasFocus,
      isTrue,
    );
    expect(find.text('0/500'), findsNothing);
    final editorDock = find.byKey(const Key('moment-comment-editor-dock'));
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pump();
    final opaqueSurface = find
        .descendant(
          of: find.byType(WenyouInlineComposerDock),
          matching: find.byType(Material),
        )
        .first;
    expect(tester.getSize(opaqueSurface).height, lessThan(180));
    expect(
      tester.getSize(find.byKey(const Key('moment-comment-input'))).width,
      closeTo(tester.getSize(editorDock).width, 0.01),
    );
    expect(
      tester.getBottomLeft(find.byKey(const Key('moment-comment-input'))).dy,
      lessThanOrEqualTo(
        tester.getTopLeft(find.byKey(const Key('moment-comment-image'))).dy,
      ),
    );
    final firstInsetFrameBottom = tester
        .getBottomRight(find.byKey(const Key('moment-comment-send')))
        .dy;
    expect(firstInsetFrameBottom, lessThanOrEqualTo(480));
    expect(
      find.descendant(of: editorDock, matching: find.byType(AnimatedPadding)),
      findsNothing,
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      tester.getBottomRight(find.byKey(const Key('moment-comment-send'))).dy,
      firstInsetFrameBottom,
    );
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pumpAndSettle();
    const inviteUrl = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
    momentPagesTestReplaceAtomicEditor(
      tester,
      const Key('moment-comment-input'),
      inviteUrl,
    );
    await tester.pump();
    expect(
      find.byKey(const Key('atomic-editor-internal-reference')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('站内传送门：传送门'), findsOneWidget);
    await tester.tap(find.byKey(const Key('moment-comment-send')));
    await tester.pumpAndSettle();

    expect(repository.commentInputs, hasLength(1));
    expect(
      repository.commentInputs.single.content,
      '[传送门](/join/AbCdEfGh_123-XYZ)',
    );
    expect(repository.commentInputs.single.replyToCommentId, isNull);
    expect(find.byKey(const Key('moment-comment-input')), findsNothing);

    final rootCommentText = find.text('主评论');
    await tester.ensureVisible(rootCommentText);
    await tester.tap(rootCommentText);
    await tester.pumpAndSettle();
    expect(find.text('回复 @温柔测试员'), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-input')), findsOneWidget);
    momentPagesTestReplaceAtomicEditor(
      tester,
      const Key('moment-comment-input'),
      '暂时不发送的草稿',
    );
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-comment-input')), findsNothing);
    expect(find.text('放弃这条评论？'), findsNothing);

    await tester.ensureVisible(rootCommentText);
    await tester.tap(rootCommentText);
    await tester.pumpAndSettle();
    expect(
      momentPagesTestAtomicEditorPlainText(
        tester,
        const Key('moment-comment-input'),
      ),
      '暂时不发送的草稿',
    );
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-comment-input')), findsNothing);
  });

  testWidgets('360dp 键盘态动态评论输入 dock 保持整行输入视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);
    final repository = MomentPagesTestPageRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(MomentPagesTestMemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(
          MomentPagesTestFakeSessionRemote(),
        ),
        momentRepositoryProvider.overrideWithValue(repository),
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
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pump();

    await expectLater(
      find.byKey(const Key('moment-comment-editor-dock')),
      matchesGoldenFile('goldens/moment_comment_composer_keyboard_360.png'),
    );
  });

  testWidgets('动态发布在单页展示图片区与正文且只保留底部主操作', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = MomentPagesTestPageRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(repository),
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

    final content = find.byKey(const Key('moment-compose-content'));
    final images = find.byKey(const Key('moment-compose-images'));
    final addImage = find.byKey(const Key('moment-compose-add-image'));
    final submit = find.byKey(const Key('moment-compose-submit'));
    expect(tester.getSize(content).height, greaterThan(300));
    expect(
      tester.getBottomRight(images).dy,
      lessThan(tester.getTopLeft(content).dy),
    );
    expect(tester.getSize(addImage).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(addImage).height, greaterThanOrEqualTo(48));
    expect(tester.getBottomRight(submit).dy, lessThanOrEqualTo(760));
    expect(find.text('纯文本，不解析 Markdown'), findsNothing);
    expect(find.text('封面仅影响信息流展示'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('动态发布上传失败后复用原图重试并只加入一次', (tester) async {
    final gateway = MomentPagesTestFailingThenSuccessfulUploadGateway();
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
            MomentPagesTestFakeImagePicker(),
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
    await tester.pump();
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    await tester.pumpAndSettle();

    expect(find.text('图片处理失败'), findsOneWidget);
    expect(find.textContaining('问题编号：moment-upload-one'), findsOneWidget);
    expect(
      find.byKey(const Key('moment-compose-retry-upload')),
      findsOneWidget,
    );
    expect(find.text('取消上传'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const Key('moment-compose-submit')),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const Key('moment-compose-retry-upload')));
    await tester.pumpAndSettle();

    expect(gateway.inputs, hasLength(2));
    expect(gateway.inputs[1], same(gateway.inputs[0]));
    expect(find.byKey(const ValueKey('moment-image')), findsOneWidget);
    expect(find.text('1/9'), findsOneWidget);
    expect(find.byKey(const Key('moment-compose-retry-upload')), findsNothing);
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const Key('moment-compose-submit')),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('动态发布多选图片后不经裁剪并按原顺序完成', (tester) async {
    final picker = MomentPagesTestFakeMultiImagePicker();
    final gateway = MomentPagesTestSuccessfulBatchUploadGateway();
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
          editorImagePickerPortProvider.overrideWithValue(picker),
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

    expect(picker.lastLimit, 9);
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);

    expect(gateway.inputs, hasLength(3));
    expect(
      gateway.inputs.map((input) => input.purpose),
      everyElement(MediaUploadPurpose.moment),
    );
    expect(gateway.inputs.map((input) => input.filename), [
      'moment-0.png',
      'moment-1.png',
      'moment-2.png',
    ]);
    for (var index = 1; index <= 3; index++) {
      expect(find.byKey(ValueKey('moment-image-$index')), findsOneWidget);
    }
    expect(find.text('3/9'), findsOneWidget);
  });

  testWidgets('动态多选立即展示本地缩略图且后台最多同时处理两张', (tester) async {
    final gateway = MomentPagesTestControlledBatchUploadGateway();
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
    await tester.pump();
    await tester.pump();

    expect(find.text('3/9'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('moment-local-thumbnail-0')),
      findsOneWidget,
    );
    expect(gateway.operations, hasLength(2));

    gateway.complete(0);
    await tester.pump();
    await tester.pump();
    expect(gateway.operations, hasLength(3));

    gateway.complete(1);
    gateway.complete(2);
    await tester.pumpAndSettle();
    expect(gateway.inputs.map((input) => input.filename), [
      'moment-0.png',
      'moment-1.png',
      'moment-2.png',
    ]);
    for (var index = 1; index <= 3; index++) {
      expect(find.byKey(ValueKey('moment-image-$index')), findsOneWidget);
    }
  });

  testWidgets('动态编辑新增图片同样不打开裁剪流程', (tester) async {
    final picker = MomentPagesTestFakeMultiImagePicker();
    final gateway = MomentPagesTestSuccessfulBatchUploadGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(
            MomentPagesTestPageRepository(
              detail: momentPagesTestEditableDetail(title: '原动态', version: 3),
            ),
          ),
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'user-1',
          ),
          momentDraftStoreProvider.overrideWithValue(MemoryMomentDraftStore()),
          editorImagePickerPortProvider.overrideWithValue(picker),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('moment-compose-add-image')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    expect(gateway.inputs, hasLength(3));
    expect(
      gateway.inputs.map((input) => input.purpose),
      everyElement(MediaUploadPurpose.moment),
    );
  });
}
