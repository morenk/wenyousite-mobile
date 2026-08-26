import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_repository_ports.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_body_editor.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('主题管理正文与原子表情共同保存', (tester) async {
    const expected =
        '前文![表情]($_stickerUrl '
        '"wenyousite-sticker:v1:$_stickerAssetId")后文';
    final repository = _StickerRepository();
    final editorController = ThreadManagementBodyEditorController();
    final changes = <String>[];
    addTearDown(editorController.dispose);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: ThreadManagementBodyEditor(
              threadId: 'thread-one',
              initialMarkdown: '前文后文',
              onChanged: changes.add,
              controller: editorController,
            ),
          ),
        ),
        GoRoute(
          path: '/stickers',
          name: 'me-stickers',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickersEnabledProvider.overrideWithValue(true),
          stickerRepositoryProvider.overrideWithValue(repository),
          stickerCollectionControllerProvider.overrideWith((ref) {
            return StickerCollectionController(
              repository,
              pollInterval: Duration.zero,
            );
          }),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    final quillController = tester
        .widget<QuillEditor>(
          find.byKey(const Key('thread-management-body-editor')),
        )
        .controller;
    quillController.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    quillController.formatSelection(Attribute.bold);

    final promotedSticker = find.byKey(const Key('editor-sticker'));
    if (promotedSticker.evaluate().isEmpty) {
      await tester.tap(find.byKey(const Key('editor-more')));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byTooltip('表情包').hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('收藏表情'));
    await tester.pumpAndSettle();

    expect(await editorController.flush(), isTrue);
    expect(editorController.codecFailure, isNull);
    expect(changes.last, expected);
  });
}

class _StickerRepository implements StickerRepository {
  @override
  Future<StickerCollection> fetchCollection() async => _collection;

  @override
  Future<StickerImport> fetchImport(String id) => throw UnimplementedError();

  @override
  Future<StickerImport> importSource(
    StickerImportSource source, {
    required String clientRequestId,
  }) => throw UnimplementedError();

  @override
  Future<StickerCollection> remove(String favoriteId) =>
      throw UnimplementedError();

  @override
  Future<StickerCollection> reorder({
    required int version,
    required List<String> favoriteIds,
  }) => throw UnimplementedError();
}

const _stickerAssetId = 'cm1234567890123456789012';
const _stickerUrl = 'https://cdn.example.com/stickers/management.webp';
const _sticker = UserSticker(
  id: 'favorite-management',
  position: 0,
  asset: StickerAsset(
    id: _stickerAssetId,
    url: _stickerUrl,
    thumbnailUrl: 'https://cdn.example.com/stickers/management-thumb.webp',
    width: 96,
    height: 96,
    animated: false,
    frameCount: 1,
    durationMs: 0,
  ),
  markdown: '![表情]($_stickerUrl "wenyousite-sticker:v1:$_stickerAssetId")',
);
const _collection = StickerCollection(
  version: 1,
  limit: 200,
  items: [_sticker],
  recent: [],
  pendingImports: [],
);
