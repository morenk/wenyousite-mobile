import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_media.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_widgets.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/data/sticker_repository.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';

void main() {
  testWidgets('私信输入器选择收藏表情后以独占 asset ID 发送', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _FakeStickerRepository();
    String? sentStickerId;
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: DirectMessageComposer(
                onSend: ({content, mediaId, mediaInput, stickerAssetId}) async {
                  expect(content, isNull);
                  expect(mediaId, isNull);
                  expect(mediaInput, isNull);
                  sentStickerId = stickerAssetId;
                  return true;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    const fieldKey = Key('direct-message-composer-field');
    await tester.tap(find.byKey(fieldKey));
    final editor = tester.state<QuillEditorState>(find.byKey(fieldKey));
    editor.widget.focusNode.requestFocus();
    await tester.pump();
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '保留的文字\n',
        selection: TextSelection.collapsed(offset: 5),
      ),
    );
    await tester.idle();
    expect(editor.widget.focusNode.hasFocus, isTrue);

    await tester.tap(find.byKey(const Key('direct-message-composer-sticker')));
    await tester.pumpAndSettle();
    expect(editor.widget.focusNode.hasFocus, isTrue);
    expect(editor.widget.controller.document.toPlainText().trim(), '保留的文字');
    expect(
      tester.getRect(find.byKey(const Key('sticker-favorite-grid'))).bottom,
      lessThan(
        tester
            .getRect(find.byKey(const Key('direct-message-composer-sticker')))
            .top,
      ),
    );
    await tester.tap(find.byType(StickerTile).first);
    await tester.pumpAndSettle();

    expect(sentStickerId, 'asset-1');
    expect(editor.widget.focusNode.hasFocus, isTrue);
    expect(editor.widget.controller.document.toPlainText().trim(), '保留的文字');
    expect(tester.takeException(), isNull);
  });

  testWidgets('已展示的私聊图片可按消息 ID 收藏，陌生图片查看前不暴露入口', (tester) async {
    final repository = _FakeStickerRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: DirectMessageBubble(
                message: _message(),
                mine: false,
                hideIncomingRequestImage: true,
                canRecall: false,
                onRecall: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('direct-message-save-sticker-message-1')),
      findsNothing,
    );
    await tester.tap(
      find.byKey(const ValueKey('direct-message-reveal-message-1')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.longPress(
      find.byKey(const ValueKey('direct-message-actions-message-1')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final actionRect = tester.getRect(
      find.byKey(const ValueKey('direct-message-save-sticker-message-1')),
    );
    final bubbleRect = tester.getRect(
      find.byKey(const ValueKey('direct-message-actions-message-1')),
    );
    expect(
      actionRect.bottom <= bubbleRect.top ||
          actionRect.top >= bubbleRect.bottom,
      isTrue,
      reason: '操作气泡 $actionRect 不应覆盖消息气泡 $bubbleRect',
    );
    await tester.tap(
      find.byKey(const ValueKey('direct-message-save-sticker-message-1')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.sources.single, isA<StickerDirectMessageSource>());
    expect(
      (repository.sources.single as StickerDirectMessageSource).directMessageId,
      'message-1',
    );
  });

  testWidgets('私聊图片原图页保留按消息收藏入口', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _FakeStickerRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: DirectMessageBubble(
              message: _message(),
              mine: true,
              canRecall: false,
              onRecall: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.byType(DirectMessageImage));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.byKey(const Key('content-image-actions')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(of: find.text('添加到表情收藏'), matching: find.byType(ListTile)),
    );
    await tester.pumpAndSettle();

    expect(repository.sources.single, isA<StickerDirectMessageSource>());
    expect(
      (repository.sources.single as StickerDirectMessageSource).directMessageId,
      'message-1',
    );
  });
}

List<Override> _overrides(_FakeStickerRepository repository) => [
  sessionControllerProvider.overrideWith(
    (ref) => _AuthenticatedSessionController(),
  ),
  stickersEnabledProvider.overrideWithValue(true),
  stickerRepositoryProvider.overrideWithValue(repository),
  stickerCollectionControllerProvider.overrideWith((ref) {
    return StickerCollectionController(repository, pollInterval: Duration.zero);
  }),
];

class _AuthenticatedSessionController extends SessionController {
  _AuthenticatedSessionController() : super(_TokenStore(), _SessionRemote()) {
    state = const SessionState.authenticated();
  }
}

class _TokenStore implements TokenStore {
  @override
  Future<void> clear() async {}

  @override
  Future<SessionTokens?> read() async => null;

  @override
  Future<void> write(SessionTokens tokens) async {}
}

class _SessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw UnimplementedError();
}

class _FakeStickerRepository implements StickerRepository {
  final sources = <StickerImportSource>[];

  @override
  Future<StickerCollection> fetchCollection() async => _collection;

  @override
  Future<StickerImport> fetchImport(String id) => throw UnimplementedError();

  @override
  Future<StickerImport> importSource(
    StickerImportSource source, {
    required String clientRequestId,
  }) async {
    sources.add(source);
    return StickerImport(
      id: 'import-1',
      status: StickerImportStatus.completed,
      favorite: _sticker,
      alreadySaved: false,
    );
  }

  @override
  Future<StickerCollection> remove(String favoriteId) =>
      throw UnimplementedError();

  @override
  Future<StickerCollection> reorder({
    required int version,
    required List<String> favoriteIds,
  }) => throw UnimplementedError();
}

const _asset = StickerAsset(
  id: 'asset-1',
  url: 'https://cdn.example.com/sticker.webp',
  thumbnailUrl: 'https://cdn.example.com/sticker-thumb.webp',
  width: 96,
  height: 96,
  animated: false,
  frameCount: 1,
  durationMs: 0,
);

const _sticker = UserSticker(
  id: 'favorite-1',
  position: 0,
  asset: _asset,
  markdown: '![表情](https://cdn.example.com/sticker.webp)',
);

const _collection = StickerCollection(
  version: 3,
  limit: 200,
  items: [_sticker],
  recent: [],
  pendingImports: [],
);

DirectMessage _message() => DirectMessage(
  id: 'message-1',
  conversationId: 'conversation-1',
  senderId: 'user-2',
  recipientId: 'user-1',
  media: const DirectMessageMedia(
    id: 'media-1',
    url: 'https://cdn.example.com/image.webp',
    isSticker: false,
  ),
  createdAt: DateTime.utc(2026, 8, 10),
);
