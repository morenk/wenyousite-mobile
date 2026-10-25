import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_reply_action_bar.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';

import '../../support/deterministic_test_fonts.dart';
import '../threads/thread_detail_page_test_support.dart' as threads;
import 'post_replies_page_test_support.dart';

class _OfflineFonts extends TextFontService {
  _OfflineFonts() : super(WenyouApi(), observePlatform: false);
  final runtime =
      TextFontRuntime(
          cache: TextFontCache(Directory.systemTemp),
          download: (_) async => throw StateError('禁止请求字体'),
        )
        ..assetsAvailable = true
        ..manifest = TextFontManifest(
          File('contracts/thread-font-manifest-v1.json').readAsBytesSync(),
        );
  @override
  Future<TextFontRuntime> openPicker() async => runtime;
  @override
  Future<TextFontRuntime> load() async => runtime;
}

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final scenario in [
    (height: 800.0, top: 280.0, keyboard: 220.0, fontOnly: false),
    (height: 800.0, top: 280.0, keyboard: 220.0, fontOnly: true),
    (height: 568.0, top: 96.0, keyboard: 220.0, fontOnly: false),
  ]) {
    testWidgets(
      '主题详情正文真实入口安全区、字体列表及键盘 ${scenario.height} fontOnly=${scenario.fontOnly}',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final fontScale = ValueNotifier(1.0);
        addTearDown(fontScale.dispose);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(
          scenario.fontOnly || scenario.height < 600 ? 320 : 360,
          scenario.height,
        );
        tester.view.viewPadding = FakeViewPadding(
          top: scenario.top,
          bottom: 24,
        );
        tester.view.padding = FakeViewPadding(top: scenario.top, bottom: 24);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewPadding);
        addTearDown(tester.view.resetViewInsets);
        final repository = threads.ThreadDetailPageTestFakePostRepository();
        final service = _OfflineFonts();
        addTearDown(service.dispose);
        final container = await postRepliesPageTestPostContainer(
          repository,
          userId: 'collaborator-1',
          extraOverrides: [
            threadDetailRepositoryProvider.overrideWithValue(
              threads.ThreadDetailPageTestFakeThreadDetailRepository(
                detail: threads.threadDetailPageTestManagerDetail,
              ),
            ),
            threadSubscriptionRepositoryProvider.overrideWithValue(
              threads.ThreadDetailPageTestFakeThreadSubscriptionRepository(),
            ),
            appCapabilitiesProvider.overrideWithValue(
              const AppCapabilities(
                textFontSupported: true,
                textFontWriteEnabled: true,
              ),
            ),
            textFontServiceProvider.overrideWithValue(service),
          ],
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: scenario.fontOnly ? AppTheme.dark : AppTheme.light,
              builder: (context, child) => ValueListenableBuilder<double>(
                valueListenable: fontScale,
                builder: (context, scale, _) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
              ),
              home: const ThreadDetailPage(threadId: 'thread-1'),
            ),
          ),
        );
        await postRepliesPageTestPumpUi(tester);
        // 真实主题详情的编辑正文操作，进入 upsertBody 及共享嵌套编辑宿主。
        await tester.tap(find.byKey(const Key('thread-detail-more')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('thread-detail-edit-body')));
        await postRepliesPageTestPumpUi(tester);
        await tester.tap(find.byKey(const Key('post-composer-expand')));
        await tester.pumpAndSettle();
        // 入口动作菜单的既有大字号固定高度限制不属于本次安全区；
        // 正常打开后对真实编辑器施加两倍字号，仍不吞被测布局异常。
        fontScale.value = scenario.fontOnly ? 2.0 : 1.0;
        await tester.pumpAndSettle();
        void checkBounds() {
          final bounds = tester.getRect(
            find.byKey(const Key('post-composer-viewport')),
          );
          expect(bounds.top, greaterThanOrEqualTo(scenario.top));
          expect(
            bounds.bottom,
            lessThanOrEqualTo(scenario.height - tester.view.viewInsets.bottom),
          );
        }

        if (!scenario.fontOnly) checkBounds();
        final variant =
            '${scenario.height.toInt()}-${scenario.fontOnly ? 'dark-narrow' : 'light'}';
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/compose-expanded-$variant.png'),
        );
        final editor = tester.widget<QuillEditor>(
          find.byKey(const Key('post-composer-body')),
        );
        final content = editor.controller.document.toDelta();
        final selection = editor.controller.selection;
        await tester.tap(find.byKey(const Key('editor-heading')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('editor-font-picker')));
        await tester.pumpAndSettle();
        final fontBounds = tester.getRect(
          find.byKey(const Key('editor-font-sheet-bounds')),
        );
        expect(fontBounds.top, greaterThanOrEqualTo(scenario.top));
        expect(
          find.byKey(const Key('editor-font-language-zh')),
          findsOneWidget,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/compose-fonts-$variant.png'),
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(editor.controller.document.toDelta(), content);
        expect(editor.controller.selection, selection);
        tester.view.viewInsets = FakeViewPadding(bottom: scenario.keyboard);
        tester.view.padding = FakeViewPadding(top: scenario.top);
        await tester.pumpAndSettle();
        checkBounds();
        tester.view.viewInsets = const FakeViewPadding();
        tester.view.padding = FakeViewPadding(top: scenario.top, bottom: 24);
        await tester.pumpAndSettle();
        checkBounds();
        expect(tester.takeException(), isNull);
        expect(repository.removedIds, isEmpty);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }

  for (final dark in [false, true]) {
    testWidgets('楼中楼共享底栏，末条与阅读滑块均使用底栏上缘 dark=$dark', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(dark ? 320 : 360, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = PostRepliesPageTestFakePostRepository(
        initialReplies: [
          for (var index = 0; index < 15; index++)
            postRepliesPageTestReply(
              'reply-$index',
              '第 $index 条讨论正文\n\n更多正文',
              postRepliesPageTestOtherAuthor,
            ),
        ],
      );
      final container = await postRepliesPageTestPostContainer(
        repository,
        userId: 'root-author',
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: dark ? AppTheme.dark : AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(dark ? 1.5 : 1)),
              child: child!,
            ),
            home: PostRepliesPage(
              threadId: 'thread',
              rootPostId: 'root',
              timeReference: postRepliesPageTestVisualTimeReference,
            ),
          ),
        ),
      );
      await postRepliesPageTestPumpUi(tester);
      expect(find.byType(WenyouReplyActionBar), findsOneWidget);
      expect(find.byType(WenyouReplyFieldAction), findsOneWidget);
      final bar = tester.getRect(find.byType(WenyouReplyActionBar));
      final list = find.byKey(const Key('post-replies-list'));
      expect(tester.getRect(list).bottom, closeTo(bar.top, 1));
      await tester.drag(list, const Offset(0, -5000));
      await tester.pumpAndSettle();
      final last = find.text('第 14 条讨论正文');
      expect(last, findsOneWidget);
      expect(tester.getRect(last).bottom, lessThanOrEqualTo(bar.top));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/reply-bar-${dark ? 'dark-narrow' : 'light'}.png',
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
