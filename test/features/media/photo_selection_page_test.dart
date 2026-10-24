import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/photo_selection_page.dart';

import '../../support/deterministic_test_fonts.dart';
import 'fake_photo_library.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  Future<void> finishImages(WidgetTester tester) async {
    final images = tester.widgetList<Image>(find.byType(Image)).toList();
    final context = tester.element(find.byType(PhotoSelectionPage));
    await tester.runAsync(() async {
      await Future.wait(
        images.map((image) => precacheImage(image.image, context)),
      );
    });
    await tester.pumpAndSettle();
  }

  Future<void> open(
    WidgetTester tester,
    FakePhotoLibrary library, {
    bool dark = false,
    double scale = 1,
    Future<List<MediaUploadInput>> Function()? system,
    ValueChanged<List<MediaUploadInput>?>? result,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                final inputs = await Navigator.of(context)
                    .push<List<MediaUploadInput>>(
                      MaterialPageRoute(
                        builder: (_) => PhotoSelectionPage(
                          library: library,
                          request: const PhotoSelectionRequest(
                            limit: 2,
                            purpose: MediaUploadPurpose.moment,
                          ),
                          systemPicker: system ?? () async => [],
                        ),
                      ),
                    );
                result?.call(inputs);
              },
              child: const Text('选择图片'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('选择图片'));
    await tester.pumpAndSettle();
  }

  testWidgets('四列默认最近、切相册保留顺序、预览和确认', (tester) async {
    final library = FakePhotoLibrary();
    List<MediaUploadInput>? result;
    await open(tester, library, result: (value) => result = value);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('photo-confirm')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('photo-select-1')));
    await tester.tap(find.byKey(const Key('photo-album-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('photo-album-other')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('photo-select-82')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photo-preview-selected')));
    await tester.pumpAndSettle();
    expect(find.text('1 / 2'), findsOneWidget);
    expect(library.resolved, isEmpty);
    await tester.tap(find.byKey(const Key('photo-confirm')));
    await tester.pumpAndSettle();
    expect(result?.map((input) => input.filename), ['1.png', '82.png']);
  });

  testWidgets('缩略图点按预览，返回取消不读文件', (tester) async {
    final library = FakePhotoLibrary();
    List<MediaUploadInput>? result;
    await open(tester, library, result: (value) => result = value);
    await tester.tap(find.bySemanticsLabel('预览第 1 张图片'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('photo-preview-pages')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(library.resolved, isEmpty);
  });

  for (final access in [
    PhotoLibraryAccess.denied,
    PhotoLibraryAccess.restricted,
  ]) {
    testWidgets('$access 保留系统选择和设置', (tester) async {
      final library = FakePhotoLibrary()..access = access;
      var system = 0;
      await open(
        tester,
        library,
        system: () async {
          system++;
          return [];
        },
      );
      await tester.tap(find.byKey(const Key('photo-open-settings')));
      await tester.pumpAndSettle();
      expect(library.settings, 1);
      await tester.tap(find.byKey(const Key('photo-system-picker')));
      await tester.pumpAndSettle();
      expect(system, 1);
      expect(find.byKey(const Key('photo-system-picker')), findsOneWidget);
    });
  }

  testWidgets('部分权限选择更多与回前台刷新', (tester) async {
    final library = FakePhotoLibrary()..access = PhotoLibraryAccess.limited;
    await open(tester, library);
    await tester.tap(find.byKey(const Key('photo-select-more')));
    await tester.pumpAndSettle();
    expect(library.more, 1);
    library.access = PhotoLibraryAccess.denied;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('photo-system-picker')), findsOneWidget);
  });

  for (final variant in [
    (name: 'light', dark: false, width: 390.0, scale: 1.0),
    (name: 'dark', dark: true, width: 390.0, scale: 1.0),
    (name: 'narrow-large', dark: false, width: 320.0, scale: 2.0),
  ]) {
    testWidgets('选图画面 ${variant.name}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(variant.width, 740);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final library = FakePhotoLibrary()..access = PhotoLibraryAccess.limited;
      await open(tester, library, dark: variant.dark, scale: variant.scale);
      await tester.tap(find.byKey(const ValueKey('photo-select-1')));
      await tester.pumpAndSettle();
      await finishImages(tester);
      await expectLater(
        find.byType(PhotoSelectionPage),
        matchesGoldenFile('goldens/photo-picker-${variant.name}.png'),
      );
      await tester.tap(find.byKey(const Key('photo-album-dropdown')));
      await tester.pumpAndSettle();
      await finishImages(tester);
      await expectLater(
        find.byType(PhotoSelectionPage),
        matchesGoldenFile('goldens/photo-albums-${variant.name}.png'),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
