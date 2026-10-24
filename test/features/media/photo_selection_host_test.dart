import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/photo_selection_host.dart';
import 'package:wenyousite_mobile/app/production_overrides.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/data/unified_image_picker.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/presentation/photo_selection_page.dart';

import '../../support/deterministic_test_fonts.dart';
import 'fake_photo_library.dart';

final _scope = StateProvider(
  (ref) => const SessionScope(accountId: 'one', generation: 1),
);

void main() {
  setUpAll(loadDeterministicTestFonts);
  test('生产三类端口均绑定统一选择器', () {
    final container = ProviderContainer(
      overrides: productionProviderOverrides(),
    );
    addTearDown(container.dispose);
    expect(
      container.read(editorImagePickerPortProvider),
      isA<UnifiedImagePicker>(),
    );
    expect(
      container.read(avatarImagePickerPortProvider),
      isA<UnifiedImagePicker>(),
    );
    expect(
      container.read(profileCoverImagePickerPortProvider),
      isA<UnifiedImagePicker>(),
    );
  });

  testWidgets('路由刷新不丢图库，换号丢弃已确认但尚未读取完成的结果', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('原页面')),
        ),
      ],
    );
    addTearDown(router.dispose);
    final library = FakePhotoLibrary();
    final container = ProviderContainer(
      overrides: [
        appRouterProvider.overrideWithValue(router),
        photoLibraryProvider.overrideWithValue(library),
        sessionScopeProvider.overrideWith((ref) => ref.watch(_scope)),
      ],
    );
    addTearDown(container.dispose);
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
    final result = container
        .read(photoSelectionCoordinatorProvider)
        .pick(
          const PhotoSelectionRequest(
            limit: 1,
            purpose: MediaUploadPurpose.avatar,
          ),
        );
    await tester.pumpAndSettle();
    router.refresh();
    await tester.pumpAndSettle();
    expect(find.byType(PhotoSelectionPage), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('photo-select-0')));
    await tester.pumpAndSettle();
    final pending = library.pendingResolve = Completer<MediaUploadInput>();
    await tester.tap(find.byKey(const Key('photo-confirm')));
    await tester.pump();
    await tester.pump();
    container.read(_scope.notifier).state = const SessionScope(
      accountId: 'two',
      generation: 2,
    );
    await tester.pump();
    await tester.pumpAndSettle();
    pending.complete(
      MediaUploadInput(filename: 'private.png', bytes: Uint8List(1)),
    );
    await tester.pumpAndSettle();
    expect(await result, isNull);
    expect(find.byType(PhotoSelectionPage), findsNothing);
    expect(find.text('原页面'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
