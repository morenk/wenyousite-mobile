import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/presentation/pending_image_overlay.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_images.dart';

import 'moment_pages_content_media_fixtures.dart';

void main() {
  for (final code in [40100, 40103, 40300, 40400]) {
    testWidgets('媒体 $code 禁止重试时仍可移除图片', (tester) async {
      final fixture = _Fixture(_failure(canRetry: false, code: code));
      await fixture.pump(tester);
      await fixture.open(tester);
      expect(find.text('重试'), findsNothing);
      expect(find.text('移除图片'), findsOneWidget);
      await tester.tap(find.text('移除图片'));
      await tester.pumpAndSettle();
      expect(fixture.removals, 1);
      expect(fixture.retries, 0);
    });
  }

  testWidgets('40101 已成功续期允许明确重试一次', (tester) async {
    final fixture = _Fixture(_failure(canRetry: true, code: 40101));
    await fixture.pump(tester);
    await fixture.open(tester);
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(fixture.retries, 1);
    expect(fixture.removals, 0);
  });

  testWidgets('处理中附件保留继续等待动作', (tester) async {
    final fixture = _Fixture(
      _failure(canRetry: true, phase: MediaUploadTaskPhase.processingPending),
    );
    await fixture.pump(tester);
    await fixture.open(tester);
    await tester.tap(find.text('继续等待'));
    await tester.pumpAndSettle();
    expect(fixture.retries, 1);
  });

  testWidgets('弹层打开后权限失效，旧重试动作不能执行回调', (tester) async {
    final fixture = _Fixture(_failure(canRetry: true));
    await fixture.pump(tester);
    await fixture.open(tester);
    fixture.state.value = _failure(canRetry: false, code: 40300);
    await tester.pump();
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(fixture.retries, 0);
  });

  testWidgets('重新打开动作按新状态判断，不永久锁死恢复入口', (tester) async {
    final fixture = _Fixture(_failure(canRetry: false, code: 40100));
    await fixture.pump(tester);
    await fixture.open(tester);
    expect(find.text('重试'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    fixture.state.value = _failure(canRetry: true, code: 40101);
    await tester.pump();
    await fixture.open(tester);
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(fixture.retries, 1);
  });
}

MediaUploadTaskState _failure({
  required bool canRetry,
  int? code,
  MediaUploadTaskPhase phase = MediaUploadTaskPhase.failed,
}) => MediaUploadTaskState(
  phase: phase,
  failure: MediaUploadFailure(
    failure: ApiFailure(businessCode: code),
    presentation: const UserFacingFailure(
      title: '图片未完成',
      message: '图片已保留。',
      recoveryAction: FailureRecoveryAction.retry,
      placement: FailurePresentationPlacement.inline,
      retainContent: true,
    ),
    canRetry: canRetry,
  ),
);

class _Fixture {
  _Fixture(MediaUploadTaskState initial) : state = ValueNotifier(initial);
  final ValueNotifier<MediaUploadTaskState> state;
  int retries = 0, removals = 0;
  Future<void> pump(WidgetTester tester) async {
    final input = (await MomentPagesTestFakeImagePicker().pickFromGallery())!;
    addTearDown(state.dispose);
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 112,
              height: 112,
              child: ValueListenableBuilder<MediaUploadTaskState>(
                valueListenable: state,
                builder: (_, value, _) => MomentPendingImageThumbnail(
                  pending: MomentPendingComposeImage(
                    id: 'pending-one',
                    input: input,
                    state: value,
                    completed: false,
                    active: false,
                    failed: true,
                  ),
                  index: 0,
                  onRemove: () => removals++,
                  onRetry: () => retries++,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(PendingImageOverlay));
    await tester.pumpAndSettle();
  }
}
