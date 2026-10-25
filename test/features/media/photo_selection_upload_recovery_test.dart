import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/photo_selection_host.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/data/unified_image_picker.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/pending_image_overlay.dart';
import 'package:wenyousite_mobile/features/media/presentation/photo_selection_page.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_comment_composer.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/memory_pending_media_file_store.dart';
import 'fake_photo_library.dart';
import 'media_processing_resume_fixtures.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('统一图库刷新后选图失败，重开只查询且明确重试复用媒体', (tester) async {
    final api = MediaRecoveryApiFixture()
      ..purpose = 'MOMENT_COMMENT'
      ..status = 'UPLOADING'
      ..putFails = true;
    final library = _RecoveryPhotoLibrary(api.input);
    final store = MemoryPendingMediaFileStore();
    final generation = ValueNotifier(0);
    var draft = const MomentCommentDraft(content: '保留评论文字');
    final sent = <MomentCommentInput>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: ValueListenableBuilder<int>(
              valueListenable: generation,
              builder: (_, value, _) => MomentCommentComposer(
                key: ValueKey(value),
                momentId: 'moment-one',
                replyTo: null,
                isSending: false,
                initialDraft: value == 0
                    ? const MomentCommentDraft(content: '保留评论文字')
                    : const MomentCommentDraft(),
                onDraftChanged: (value) => draft = value,
                onCancelReply: () {},
                onClose: () {},
                onSend: (value) async {
                  sent.add(value);
                  return true;
                },
              ),
            ),
          ),
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        appRouterProvider.overrideWithValue(router),
        sessionScopeProvider.overrideWithValue(
          const SessionScope(accountId: 'owner', generation: 1),
        ),
        photoLibraryProvider.overrideWithValue(library),
        editorImagePickerPortProvider.overrideWith(
          (ref) =>
              UnifiedImagePicker(ref.read(photoSelectionCoordinatorProvider)),
        ),
        momentComposerOwnerResolverProvider.overrideWithValue(
          () async => 'owner',
        ),
        pendingMediaFileStoreProvider.overrideWithValue(store),
        mediaUploadGatewayPortProvider.overrideWithValue(api.gateway),
      ],
    );
    addTearDown(api.close);
    addTearDown(store.dispose);
    addTearDown(generation.dispose);
    addTearDown(router.dispose);
    addTearDown(container.dispose);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
          builder: (_, child) => PhotoSelectionHost(child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-comment-image')));
    await tester.pumpAndSettle();
    router.refresh();
    await tester.pumpAndSettle();
    expect(find.byType(PhotoSelectionPage), findsOneWidget);
    expect(api.postCount, 0);
    await tester.tap(find.byKey(const ValueKey('photo-select-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photo-confirm')));
    await tester.pumpAndSettle();
    expect(library.resolved, ['0']);
    expect(api.allocateCount, 1);
    expect(api.putCount, 1);
    expect(api.confirmCount, 0);
    await tester.pump(const Duration(milliseconds: 300));
    final saved = MomentLocalDraft.fromJson(store.drafts.values.single)!;
    expect(saved.pendingImages.single.pending?.mediaId, 'media-one');
    expect(saved.pendingImages.single.pending?.needsTransfer, isTrue);
    expect(
      saved.pendingImages.single.pending?.contentSha256,
      matches(r'^[a-f0-9]{64}$'),
    );
    expect(draft.content, '保留评论文字');

    generation.value++;
    await tester.pumpAndSettle();
    expect(api.getCount, 1);
    expect(api.allocateCount, 1);
    expect(api.reissueCount, 0);
    expect(api.putCount, 1);
    expect(api.confirmCount, 0);
    expect(
      MomentLocalDraft.fromJson(
        store.drafts.values.single,
      )!.pendingImages.single.pending?.mediaId,
      'media-one',
    );
    expect(sent, isEmpty);

    api
      ..putFails = false
      ..completeAfterPut = true;
    final failedImage = find.byWidgetPredicate(
      (widget) => widget is PendingImageOverlay && widget.failed,
    );
    expect(failedImage, findsOneWidget);
    await tester.tap(failedImage);
    await tester.pumpAndSettle();
    await tester.tap(find.text('重试'));
    // 重开草稿使用真实临时文件；交替驱动文件 IO 与 widget zone。
    for (var attempt = 0; attempt < 100 && draft.image == null; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(draft.image?.mediaId, 'media-one');
    await tester.pumpAndSettle();
    expect(api.allocateCount, 1);
    expect(api.reissueCount, 1);
    expect(api.putCount, 2);
    expect(api.confirmCount, 1);
    expect(draft.image?.mediaId, 'media-one');
    expect(draft.content, '保留评论文字');
    expect(sent, isEmpty);
    await tester.tap(find.byKey(const Key('moment-comment-send')));
    await tester.pumpAndSettle();
    expect(sent, hasLength(1));
    expect(sent.single.mediaId, 'media-one');
    expect(sent.single.content, '保留评论文字');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _RecoveryPhotoLibrary extends FakePhotoLibrary {
  _RecoveryPhotoLibrary(this.input);
  final MediaUploadInput input;

  @override
  Future<MediaUploadInput> resolve(
    LocalPhoto photo,
    MediaUploadPurpose purpose,
  ) async {
    resolved.add(photo.id);
    return input.withPurpose(purpose);
  }
}
