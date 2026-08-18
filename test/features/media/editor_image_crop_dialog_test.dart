import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/editor_image_crop_dialog.dart';
import 'package:wenyousite_mobile/features/media/presentation/image_crop_dialog.dart';

import '../../support/fake_image_crop_processor.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('裁剪画布完整保持原图比例并用目标比例取景框选择区域', (tester) async {
    final input = MediaUploadInput(
      filename: 'source.png',
      declaredContentType: 'image/png',
      bytes: Uint8List.fromList([1]),
    );
    final source = await const FakePassThroughImageCropProcessor().prepare(
      input,
    );
    final controller = CropViewportController(
      sourceAspectRatio: 2,
      targetAspectRatio: 1,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: ImageCropEditor(source: source, controller: controller),
            ),
          ),
        ),
      ),
    );

    final viewport = tester.getSize(
      find.byKey(const Key('image-crop-viewport')),
    );
    expect(viewport.width / viewport.height, closeTo(2, .001));
    expect(
      tester.widget<Image>(find.byKey(const Key('image-crop-source'))).fit,
      BoxFit.contain,
    );
    expect(controller.crop.left, closeTo(.25, .001));
    expect(controller.crop.top, closeTo(0, .001));
    expect(controller.crop.width, closeTo(.5, .001));
    expect(controller.crop.height, closeTo(1, .001));
  });

  test('拖动手势移动取景框而不是反向平移原图', () {
    final controller = CropViewportController(
      sourceAspectRatio: 2,
      targetAspectRatio: 1,
    );
    addTearDown(controller.dispose);

    controller.updateGesture(
      viewport: const Size(400, 200),
      startZoom: 1,
      startCenter: const Offset(.5, .5),
      focalDelta: const Offset(80, 0),
      scale: 1,
    );

    expect(controller.center.dx, closeTo(.7, .001));
    expect(controller.crop.left, closeTo(.45, .001));
    expect(controller.crop.right, closeTo(.95, .001));
  });

  testWidgets('多图裁剪在底部横向缩略栏切换并逐张输出', (tester) async {
    List<MediaUploadInput>? result;
    final inputs = [
      for (var index = 0; index < 3; index++)
        MediaUploadInput(
          filename: 'image-$index.png',
          declaredContentType: 'image/png',
          bytes: Uint8List.fromList([index + 1]),
        ),
    ];
    final processor = _RecordingCropProcessor();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await showEditorImageCropDialog(
                context,
                inputs: inputs,
                processor: processor,
              );
            },
            child: const Text('打开'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('image-crop-thumbnail-tabs')), findsOneWidget);
    expect(
      tester
          .widget<ListView>(
            find.descendant(
              of: find.byKey(const Key('image-crop-thumbnail-tabs')),
              matching: find.byType(ListView),
            ),
          )
          .scrollDirection,
      Axis.horizontal,
    );
    for (var index = 0; index < 3; index++) {
      expect(
        find.byKey(ValueKey('image-crop-thumbnail-$index')),
        findsOneWidget,
      );
    }

    await tester.ensureVisible(find.byKey(const Key('image-crop-thumbnail-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('image-crop-thumbnail-1')));
    await tester.pump();
    expect(find.text('图片 2/3'), findsOneWidget);
    tester
        .widget<ChoiceChip>(find.byKey(const Key('image-crop-ratio-1-1:1')))
        .onSelected!(true);
    await tester.pump();

    final confirm = tester.widget<FilledButton>(
      find.byKey(const Key('image-crop-confirm')),
    );
    expect(confirm.onPressed, isNotNull);
    confirm.onPressed!();
    await tester.pumpAndSettle();

    expect(processor.crops, hasLength(3));
    expect(find.byKey(const Key('image-crop-error')), findsNothing);
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(result, hasLength(3));
    expect(processor.crops[1].width, closeTo(.5, .001));
    expect(processor.crops[1].height, closeTo(1, .001));
  });

  testWidgets('图片准备失败会显示错误并可原地重试', (tester) async {
    final processor = _FailOnceCropProcessor();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () => showEditorImageCropDialog(
              context,
              inputs: [
                MediaUploadInput(
                  filename: 'image.png',
                  bytes: Uint8List.fromList([1]),
                ),
              ],
              processor: processor,
            ),
            child: const Text('打开'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('image-crop-error')), findsOneWidget);
    expect(
      find.byKey(const Key('editor-image-crop-prepare-retry')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('editor-image-crop-prepare-retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('image-crop-error')), findsNothing);
    expect(find.byKey(const Key('image-crop-confirm')), findsOneWidget);
    tester
        .widget<IconButton>(find.byKey(const Key('image-crop-close')))
        .onPressed!();
    await tester.pumpAndSettle();
  });
}

class _RecordingCropProcessor extends FakePassThroughImageCropProcessor {
  final crops = <NormalizedCropRect>[];

  @override
  Future<MediaUploadInput> cropImage(
    CropImageSource source,
    NormalizedCropRect crop,
  ) async {
    crops.add(crop);
    return source.original;
  }
}

class _FailOnceCropProcessor implements ImageCropProcessor {
  var attempts = 0;

  @override
  Future<CropImageSource> prepare(MediaUploadInput input) async {
    attempts += 1;
    if (attempts == 1) throw StateError('failed');
    return const FakePassThroughImageCropProcessor().prepare(input);
  }

  @override
  Future<MediaUploadInput> cropAvatar(
    CropImageSource source,
    NormalizedCropRect crop,
  ) => throw UnimplementedError();

  @override
  Future<MediaUploadInput> cropImage(
    CropImageSource source,
    NormalizedCropRect crop,
  ) async => source.original;

  @override
  Future<ProfileCoverImageSelection> cropProfileCover(
    CropImageSource source, {
    required NormalizedCropRect webCrop,
    required NormalizedCropRect mobileCrop,
  }) => throw UnimplementedError();
}
