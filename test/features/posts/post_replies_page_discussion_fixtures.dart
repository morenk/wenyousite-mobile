import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_reader_clipboard.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_thread_context_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_repository_ports.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';
import 'post_replies_page_upload_operations.dart';

Future<ProviderContainer> postRepliesPageTestPostContainer(
  PostRepository repository, {
  String? userId,
  PostRepliesPageTestFakeStickerRepository? stickerRepository,
  ReaderMarkdownClipboardWriter? clipboardWriter,
  bool markdownAlignment = false,
  bool markdownImageAlignment = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      appCapabilitiesProvider.overrideWithValue(
        AppCapabilities(
          markdownAlignment: markdownAlignment,
          markdownImageAlignment: markdownImageAlignment,
        ),
      ),
      tokenStoreProvider.overrideWithValue(
        PostRepliesPageTestMemoryTokenStore(),
      ),
      sessionRemoteProvider.overrideWithValue(
        PostRepliesPageTestFakeSessionRemote(),
      ),
      stickersEnabledProvider.overrideWithValue(stickerRepository != null),
      if (stickerRepository != null) ...[
        stickerRepositoryProvider.overrideWithValue(stickerRepository),
        stickerCollectionControllerProvider.overrideWith((ref) {
          return StickerCollectionController(
            stickerRepository,
            pollInterval: Duration.zero,
          );
        }),
      ],
      postRepositoryProvider.overrideWithValue(repository),
      postDiscussionAuthorDirectoryProvider.overrideWithValue(
        const PostRepliesPageTestFakePostDiscussionAuthorDirectory(),
      ),
      postThreadContextLookupProvider.overrideWithValue(
        (_) async =>
            const PostThreadContext(isPrivate: false, canManageThread: false),
      ),
      if (clipboardWriter != null)
        readerMarkdownClipboardWriterProvider.overrideWithValue(
          clipboardWriter,
        ),
    ],
  );
  if (userId != null) {
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(postRepliesPageTestTokensFor(userId));
  }
  return container;
}

Widget postRepliesPageTestPostRepliesApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.light,
      home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
    ),
  );
}

Future<void> postRepliesPageTestPumpUi(
  WidgetTester tester, [
  int frames = 6,
]) async {
  for (var frame = 0; frame < frames; frame += 1) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

Future<void> postRepliesPageTestDismissPostComposerFromOutside(
  WidgetTester tester,
) async {
  expect(find.byKey(const Key('post-composer-dismiss-region')), findsOneWidget);
  final sheetTop = tester
      .getTopLeft(find.byKey(const Key('post-composer-viewport')))
      .dy;
  expect(sheetTop, greaterThan(0));
  await tester.tapAt(Offset(12, sheetTop / 2));
  await tester.pumpAndSettle();
}

Rect postRepliesPageTestGlyphRect(
  WidgetTester tester,
  Finder finder,
  int textLength,
) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: 0, extentOffset: textLength),
  );
  expect(boxes, isNotEmpty);
  Rect? result;
  for (final box in boxes) {
    final local = box.toRect();
    final global = Rect.fromPoints(
      paragraph.localToGlobal(local.topLeft),
      paragraph.localToGlobal(local.bottomRight),
    );
    result = result?.expandToInclude(global) ?? global;
  }
  return result!;
}

Future<void> postRepliesPageTestLongPressPostMetadata(
  WidgetTester tester,
  String postId,
) async {
  final card = find.byKey(Key('post-card-$postId'));
  final rect = tester.getRect(card);
  await tester.longPressAt(Offset(rect.right - 12, rect.top + 24));
}

Future<void> postRepliesPageTestConfirmImageCrop(WidgetTester tester) async {
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('editor-image-crop-dialog')), findsOneWidget);
  tester
      .widget<FilledButton>(find.byKey(const Key('image-crop-confirm')))
      .onPressed!();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

Future<void> postRepliesPageTestReplaceComposerText(
  WidgetTester tester,
  String text,
) async {
  final editor = find.byKey(const Key('post-composer-body'));
  expect(editor, findsOneWidget);
  final state = tester.state<QuillEditorState>(editor);
  state.widget.focusNode.requestFocus();
  await tester.pump();
  expect(state.widget.focusNode.hasFocus, isTrue);
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: '$text\n',
      selection: TextSelection.collapsed(offset: text.length),
    ),
  );
  await tester.idle();
}

typedef PostRepliesPageTestFetchRepliesHandler =
    Future<PostReplyPage> Function({
      required String rootPostId,
      String? cursor,
      required PostReplyOrder order,
      String? authorId,
    });

typedef PostRepliesPageTestUpdateHandler =
    Future<PostItem> Function({
      required String postId,
      required String content,
      required int version,
    });

class PostRepliesPageTestFakePostRepository implements PostRepository {
  PostRepliesPageTestFakePostRepository({
    this.createCompleter,
    this.onFetchPost,
    this.onFetchReplies,
    this.onCreate,
    this.onUpdate,
    this.onRemove,
    List<PostItem>? initialReplies,
  }) : replies =
           initialReplies ??
           [
             postRepliesPageTestReply(
               'reply-own',
               '自己的回复',
               postRepliesPageTestAuthor,
             ),
             postRepliesPageTestReply(
               'reply-other',
               '他人的回复',
               postRepliesPageTestOtherAuthor,
             ),
           ];

  final Completer<PostItem>? createCompleter;
  final Future<PostItem> Function(String postId)? onFetchPost;
  final PostRepliesPageTestFetchRepliesHandler? onFetchReplies;
  final Future<PostItem> Function(PostCreateInput input)? onCreate;
  final PostRepliesPageTestUpdateHandler? onUpdate;
  final Future<void> Function(String postId)? onRemove;
  final List<PostItem> replies;
  final List<PostCreateInput> createInputs = [];
  final List<({String id, String content, int version})> updateRequests = [];
  final List<String> removedIds = [];

  @override
  Future<PostItem> fetchPost(String postId) async {
    if (onFetchPost case final handler?) return handler(postId);
    if (postId == 'root') return postRepliesPageTestRoot;
    return replies.singleWhere((post) => post.id == postId);
  }

  @override
  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) async {
    if (onFetchReplies case final handler?) {
      return handler(
        rootPostId: rootPostId,
        cursor: cursor,
        order: order,
        authorId: authorId,
      );
    }
    final filtered =
        replies
            .where((post) => authorId == null || post.author.id == authorId)
            .toList()
          ..sort(
            (left, right) => order == PostReplyOrder.oldest
                ? left.createdAt.compareTo(right.createdAt)
                : right.createdAt.compareTo(left.createdAt),
          );
    return CursorPage(items: filtered, hasMore: false);
  }

  @override
  Future<PostItem> create(PostCreateInput input) async {
    createInputs.add(input);
    final created = onCreate != null
        ? await onCreate!(input)
        : createCompleter == null
        ? postRepliesPageTestReply(
            'created',
            input.content,
            postRepliesPageTestAuthor,
          )
        : await createCompleter!.future;
    replies.add(created);
    return created;
  }

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) async {
    updateRequests.add((id: postId, content: content, version: version));
    final index = replies.indexWhere((post) => post.id == postId);
    final previous = replies[index];
    final updated = onUpdate != null
        ? await onUpdate!(postId: postId, content: content, version: version)
        : postRepliesPageTestReply(
            postId,
            content,
            previous.author,
            version: version + 1,
          );
    replies[index] = updated;
    return updated;
  }

  @override
  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
  }) {
    throw UnsupportedError('not used');
  }

  @override
  Future<void> remove(String postId) async {
    await onRemove?.call(postId);
    removedIds.add(postId);
    replies.removeWhere((post) => post.id == postId);
  }

  @override
  Future<void> setPinned(String postId, {required bool pinned}) async {}
}

class PostRepliesPageTestFakeStickerRepository implements StickerRepository {
  @override
  Future<StickerCollection> fetchCollection() async =>
      postRepliesPageTestStickerCollection;

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

const postRepliesPageTestStickerAssetId = 'cm1234567890123456789012';

const postRepliesPageTestStickerUrl =
    'https://cdn.example.com/stickers/reply.webp';

const postRepliesPageTestSticker = UserSticker(
  id: 'favorite-reply',
  position: 0,
  asset: StickerAsset(
    id: postRepliesPageTestStickerAssetId,
    url: postRepliesPageTestStickerUrl,
    thumbnailUrl: 'https://cdn.example.com/stickers/reply-thumb.webp',
    width: 96,
    height: 96,
    animated: false,
    frameCount: 1,
    durationMs: 0,
  ),
  markdown:
      '![表情]($postRepliesPageTestStickerUrl "wenyousite-sticker:v1:$postRepliesPageTestStickerAssetId")',
);

const postRepliesPageTestStickerCollection = StickerCollection(
  version: 1,
  limit: 200,
  items: [postRepliesPageTestSticker],
  recent: [],
  pendingImports: [],
);

class PostRepliesPageTestFakePostDiscussionAuthorDirectory
    implements PostDiscussionAuthorDirectory {
  const PostRepliesPageTestFakePostDiscussionAuthorDirectory();

  @override
  Future<List<PostDiscussionAuthor>> fetchFloorAuthors(
    String subthreadId,
  ) async => const [];

  @override
  Future<List<PostDiscussionAuthor>> fetchReplyAuthors(
    String rootPostId,
  ) async {
    return [
      PostDiscussionAuthor(
        userId: postRepliesPageTestRootAuthor.id,
        username: postRepliesPageTestRootAuthor.username,
        role: PostDiscussionAuthorRole.owner,
      ),
      PostDiscussionAuthor(
        userId: postRepliesPageTestAuthor.id,
        username: postRepliesPageTestAuthor.username,
        role: PostDiscussionAuthorRole.player,
      ),
    ];
  }
}

class PostRepliesPageTestMutablePostDiscussionAuthorDirectory
    implements PostDiscussionAuthorDirectory {
  int floorCalls = 0;
  int replyCalls = 0;
  List<PostDiscussionAuthor> replyAuthors = [
    PostDiscussionAuthor(
      userId: postRepliesPageTestRootAuthor.id,
      username: postRepliesPageTestRootAuthor.username,
      role: PostDiscussionAuthorRole.owner,
    ),
    PostDiscussionAuthor(
      userId: postRepliesPageTestAuthor.id,
      username: postRepliesPageTestAuthor.username,
      role: PostDiscussionAuthorRole.player,
    ),
  ];

  @override
  Future<List<PostDiscussionAuthor>> fetchFloorAuthors(
    String subthreadId,
  ) async {
    floorCalls += 1;
    return const [];
  }

  @override
  Future<List<PostDiscussionAuthor>> fetchReplyAuthors(
    String rootPostId,
  ) async {
    replyCalls += 1;
    return replyAuthors;
  }
}

const postRepliesPageTestAuthor = PostAuthor(
  id: 'author-1',
  username: '自己',
  level: 3,
);

const postRepliesPageTestOtherAuthor = PostAuthor(
  id: 'author-2',
  username: '他人',
  level: 2,
);

const postRepliesPageTestRootAuthor = PostAuthor(
  id: 'root-author',
  username: '楼层作者',
  level: 4,
);

final postRepliesPageTestRootCreatedAt = DateTime.utc(2026, 8, 20, 12);

final postRepliesPageTestVisualTimeReference = DateTime.utc(2026, 8, 22, 12);

final postRepliesPageTestRoot = postRepliesPageTestRootWithContent('原楼层内容');

PostItem postRepliesPageTestRootWithContent(
  String content, {
  bool isDeleted = false,
}) => PostItem(
  id: 'root',
  threadId: 'thread',
  subthreadId: 'subthread',
  author: postRepliesPageTestRootAuthor,
  content: content,
  version: 2,
  createdAt: postRepliesPageTestRootCreatedAt,
  updatedAt: postRepliesPageTestRootCreatedAt,
  isBody: false,
  isDeleted: isDeleted,
  floorNumber: 8,
  replyCount: 2,
  threadTitle: '远行主题',
  subthreadTitle: '主线',
);

PostItem postRepliesPageTestReply(
  String id,
  String content,
  PostAuthor author, {
  int version = 1,
  bool isDeleted = false,
}) {
  final createdAt = DateTime.utc(
    2026,
    8,
    22,
    12,
  ).subtract(Duration(days: id == 'reply-other' ? 1 : 2));
  return PostItem(
    id: id,
    threadId: 'thread',
    subthreadId: 'subthread',
    author: author,
    content: content,
    version: version,
    createdAt: createdAt,
    updatedAt: createdAt,
    isBody: false,
    isDeleted: isDeleted,
    parentPostId: 'root',
    replyToPostId: 'root',
    replyToAuthor: postRepliesPageTestRootAuthor,
  );
}

SessionTokens postRepliesPageTestTokensFor(String userId) {
  final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': userId})));
  return SessionTokens(
    accessToken: 'e30.$payload.signature',
    refreshToken: 'refresh-token',
  );
}

class PostRepliesPageTestMemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class PostRepliesPageTestFakeSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async =>
      postRepliesPageTestTokensFor('author-1');
}

class PostRepliesPageTestFakeEditorImagePicker implements EditorImagePicker {
  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    return MediaUploadInput(
      filename: 'reply.png',
      declaredContentType: 'image/png',
      bytes: Uint8List.fromList(const [137, 80, 78, 71]),
    );
  }
}

class PostRepliesPageTestFakeMediaUploadRepository
    implements MediaUploadRepository {
  @override
  Future<UploadedEditorImage> uploadImage(
    MediaUploadInput input, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  }) async {
    return const UploadedEditorImage(
      mediaId: 'reply-image',
      url: 'https://cdn.example.com/reply.png',
    );
  }
}

class PostRepliesPageTestFailingThenSuccessfulMediaUploadGateway
    implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length,
        totalBytes: input.bytes.length,
      ),
    );
    if (inputs.length == 1) {
      return PostRepliesPageTestFailingMediaUploadOperation();
    }
    return PostRepliesPageTestSuccessfulMediaUploadOperation();
  }
}
