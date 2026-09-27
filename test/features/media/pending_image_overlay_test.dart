import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/media_ui.dart';

void main() {
  testWidgets('只遮罩实际等待超过 300ms 的图片，排队和就绪保持清晰', (tester) async {
    Future<void> show({required bool active, bool failed = false}) =>
        tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Center(
              child: PendingImageOverlay(
                active: active,
                failed: failed,
                child: const SizedBox.square(dimension: 96),
              ),
            ),
          ),
        );

    const queued = MediaUploadTaskState(phase: MediaUploadTaskPhase.queued);
    await show(active: queued.isActivelyWorking);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await show(active: true);
    await tester.pump(const Duration(milliseconds: 299));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await show(active: false);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('失败图片内标记可点击且有可读状态', (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Center(
          child: PendingImageOverlay(
            active: false,
            failed: true,
            onFailureTap: () => opened++,
            child: const SizedBox.square(dimension: 96),
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel(RegExp('图片未完成')), findsOneWidget);
    await tester.tap(find.byType(PendingImageOverlay));
    expect(opened, 1);
  });
}
