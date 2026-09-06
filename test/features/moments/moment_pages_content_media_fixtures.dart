import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_feed_page.dart';
import '../../support/moment_test_draft_store.dart';
import 'moment_pages_session_wallet_fixtures.dart';

Widget momentPagesTestFeedApp(MomentRepository repository) {
  return ProviderScope(
    overrides: [
      momentRepositoryProvider.overrideWithValue(repository),
      momentComposerOwnerResolverProvider.overrideWithValue(
        () async => 'user-1',
      ),
      momentDraftStoreProvider.overrideWithValue(MemoryMomentDraftStore()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const RepaintBoundary(
        key: Key('moment-feed-visual'),
        child: MomentFeedPage(),
      ),
    ),
  );
}

void momentPagesTestReplaceAtomicEditor(
  WidgetTester tester,
  Key key,
  String value,
) {
  final editor = tester.widget<QuillEditor>(find.byKey(key));
  final length = editor.controller.document.length - 1;
  editor.controller.replaceText(
    0,
    length,
    value,
    TextSelection.collapsed(offset: value.length),
  );
  editor.focusNode.requestFocus();
}

String momentPagesTestAtomicEditorPlainText(WidgetTester tester, Key key) {
  final editor = tester.widget<QuillEditor>(find.byKey(key));
  return editor.controller.document.toPlainText().trimRight();
}

class MomentPagesTestPageRepository extends Fake implements MomentRepository {
  MomentPagesTestPageRepository({MomentDetail? detail})
    : momentPagesTestDetailValue = detail ?? momentPagesTestDetail();

  final feedModes = <MomentFeedMode>[];
  final createdInputs = <MomentDraftInput>[];
  final commentInputs = <MomentCommentInput>[];
  final bookmarkMoves = <(String, String)>[];
  final bookmarkWrites = <({String momentId, bool active, String? folderId})>[];
  final commentOrders = <MomentCommentOrder>[];
  final MomentDetail momentPagesTestDetailValue;
  var commentAuthorCalls = 0;

  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) async {
    feedModes.add(mode);
    return CursorPage(
      items: [
        momentPagesTestCard(),
        momentPagesTestCard(
          id: 'moment-2',
          title: '这是一个足够长并且会占据两行空间的动态标题',
          theme: MomentTextCoverTheme.rose,
        ),
        momentPagesTestCard(
          id: 'moment-3',
          title: '第三条动态',
          theme: MomentTextCoverTheme.amber,
        ),
      ],
      cursor: null,
      hasMore: false,
    );
  }

  @override
  Future<MomentDetail> fetchDetail(String momentId) async =>
      momentPagesTestDetailValue;

  @override
  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
    String? folderId,
  }) async {
    bookmarkWrites.add((
      momentId: momentId,
      active: active,
      folderId: folderId,
    ));
    return MomentActionResult(
      momentId: momentId,
      count: active ? 2 : 1,
      active: active,
    );
  }

  @override
  Future<void> moveBookmark(String momentId, String folderId) async {
    bookmarkMoves.add((momentId, folderId));
  }

  @override
  Future<CursorPage<MomentRootComment>> fetchComments({
    required String momentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) async {
    commentOrders.add(order);
    return CursorPage(
      items: [momentPagesTestRootComment()],
      cursor: null,
      hasMore: false,
    );
  }

  @override
  Future<List<MomentAuthor>> fetchCommentAuthors(String momentId) async {
    commentAuthorCalls += 1;
    return [momentPagesTestAuthor()];
  }

  @override
  Future<MomentComment> createComment(
    String momentId,
    MomentCommentInput input, {
    required String clientRequestId,
  }) async {
    commentInputs.add(input);
    return MomentComment(
      id: 'comment-created',
      momentId: momentId,
      author: momentPagesTestAuthor(),
      content: input.content,
      parentCommentId: input.replyToCommentId == null ? null : 'comment-root',
      deleted: false,
      canDelete: true,
      createdAt: DateTime.utc(2026, 8, 10, 14),
    );
  }

  @override
  Future<MomentDetail> create(
    MomentDraftInput input, {
    required String clientRequestId,
  }) async {
    createdInputs.add(input.normalized());
    return momentPagesTestDetail();
  }
}

class MomentPagesTestCleanupPageRepository
    extends MomentPagesTestPageRepository {
  MomentPagesTestCleanupPageRepository()
    : super(detail: momentPagesTestEditableDetail(title: '原始标题', version: 1));
  int updateCalls = 0;
  int removeCalls = 0;

  @override
  Future<MomentDetail> update(
    String id,
    MomentDraftInput input, {
    required int version,
  }) async {
    updateCalls += 1;
    return momentPagesTestEditableDetail(
      title: input.title,
      version: version + 1,
    );
  }

  @override
  Future<void> remove(String id) async {
    removeCalls += 1;
  }
}

class MomentPagesTestFlakyDeleteStore extends MemoryMomentDraftStore {
  bool failNext = true;

  @override
  Future<void> delete(String ownerId, String? momentId) async {
    if (failNext) {
      failNext = false;
      throw StateError('Test cleanup failure.');
    }
    await super.delete(ownerId, momentId);
  }
}

class MomentPagesTestMomentFolderRepository extends Fake
    implements BookmarkFolderCatalog {
  @override
  Future<List<BookmarkFolderItem>> fetchFolders() async => [
    BookmarkFolderItem(
      id: 'folder-default',
      name: '默认收藏夹',
      isDefault: true,
      bookmarkCount: 1,
      createdAt: DateTime.utc(2026, 8, 19),
    ),
    BookmarkFolderItem(
      id: 'folder-later',
      name: '稍后阅读',
      isDefault: false,
      bookmarkCount: 3,
      createdAt: DateTime.utc(2026, 8, 19),
    ),
  ];
}

class MomentPagesTestPendingPageRepository
    extends MomentPagesTestPageRepository {
  final feed = Completer<CursorPage<MomentCard>>();

  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) {
    feedModes.add(mode);
    return feed.future;
  }
}

class MomentPagesTestPagingPageRepository
    extends MomentPagesTestPageRepository {
  final cursors = <String?>[];

  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) async {
    feedModes.add(mode);
    cursors.add(cursor);
    if (cursor == 'next') {
      return CursorPage(
        items: [momentPagesTestCard(id: 'moment-next', title: '分页动态')],
        hasMore: false,
      );
    }
    return CursorPage(
      items: [
        for (var index = 0; index < 30; index++)
          momentPagesTestCard(id: 'moment-$index', title: '动态 $index'),
      ],
      cursor: 'next',
      hasMore: true,
    );
  }
}

class MomentPagesTestWaterfallRegressionRepository
    extends MomentPagesTestPageRepository {
  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) async {
    feedModes.add(mode);
    return CursorPage(
      items: [
        for (var index = 0; index < 24; index++)
          momentPagesTestCard(
            id: 'waterfall-regression-$index',
            title: index.isEven
                ? '动态 $index'
                : '这是第 $index 条用于验证双列滚动稳定性的较长动态标题',
            coverMedia: switch (index % 3) {
              0 => momentPagesTestWaterfallMedia(
                index,
                width: 900,
                height: 1600,
              ),
              1 => momentPagesTestWaterfallMedia(
                index,
                width: 1600,
                height: 900,
              ),
              _ => null,
            },
            imageCount: index % 3 == 2 ? 0 : 1,
          ),
      ],
      hasMore: false,
    );
  }
}

MomentMedia momentPagesTestWaterfallMedia(
  int index, {
  required int width,
  required int height,
}) {
  return MomentMedia(
    id: 'waterfall-image-$index',
    url: 'https://cdn.example.com/waterfall-feed.webp',
    width: width,
    height: height,
  );
}

class MomentPagesTestConflictPageRepository
    extends MomentPagesTestPageRepository {
  MomentPagesTestConflictPageRepository()
    : super(detail: momentPagesTestEditableDetail(title: '原来的标题', version: 3));

  var fetchCalls = 0;

  @override
  Future<MomentDetail> fetchDetail(String momentId) async {
    fetchCalls += 1;
    return fetchCalls == 1
        ? momentPagesTestEditableDetail(title: '原来的标题', version: 3)
        : momentPagesTestEditableDetail(title: '服务端最新标题', version: 4);
  }

  @override
  Future<MomentDetail> update(
    String momentId,
    MomentDraftInput input, {
    required int version,
  }) async {
    throw const ApiFailure(businessCode: 40002, userMessage: '这条动态刚刚更新了。');
  }
}

class MomentPagesTestFakeImagePicker implements EditorImagePicker {
  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    return MediaUploadInput(
      filename: 'moment.png',
      declaredContentType: 'image/png',
      bytes: Uint8List.fromList(const [137, 80, 78, 71]),
    );
  }
}

class MomentPagesTestFakeMultiImagePicker
    implements EditorImagePicker, MultiEditorImagePicker {
  int? lastLimit;

  @override
  Future<MediaUploadInput?> pickFromGallery() async => null;

  @override
  Future<List<MediaUploadInput>> pickManyFromGallery({
    required int limit,
  }) async {
    lastLimit = limit;
    return [
      for (var index = 0; index < 3; index++)
        MediaUploadInput(
          filename: 'moment-$index.png',
          declaredContentType: 'image/png',
          bytes: Uint8List.fromList([index + 1]),
        ),
    ];
  }
}

class MomentPagesTestSuccessfulBatchUploadGateway
    implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    return MomentPagesTestImmediateUploadOperation(
      Future.value(
        UploadedEditorImage(
          mediaId: 'moment-image-${inputs.length}',
          url: 'https://cdn.example.com/moment-${inputs.length}.png',
        ),
      ),
    );
  }
}

class MomentPagesTestControlledBatchUploadGateway
    implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];
  final operations = <Completer<UploadedEditorImage>>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    final completion = Completer<UploadedEditorImage>();
    operations.add(completion);
    return MomentPagesTestImmediateUploadOperation(completion.future);
  }

  void complete(int index) {
    operations[index].complete(
      UploadedEditorImage(
        mediaId: 'moment-image-${index + 1}',
        url: 'https://cdn.example.com/moment-${index + 1}.png',
      ),
    );
  }
}

class MomentPagesTestFailingThenSuccessfulUploadGateway
    implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    if (inputs.length == 1) {
      return MomentPagesTestImmediateUploadOperation(
        Future<UploadedEditorImage>.error(
          const ApiFailure(
            userMessage: '图片处理失败',
            requestId: 'moment-upload-one',
          ),
        ),
      );
    }
    return MomentPagesTestImmediateUploadOperation(
      Future.value(
        const UploadedEditorImage(
          mediaId: 'moment-image',
          url: 'https://cdn.example.com/moment.png',
        ),
      ),
    );
  }
}

class MomentPagesTestFirstSuccessfulThenFailingUploadGateway
    implements MediaUploadGateway {
  var calls = 0;

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    calls += 1;
    if (calls == 1) {
      return MomentPagesTestImmediateUploadOperation(
        Future.value(
          const UploadedEditorImage(
            mediaId: 'moment-image-1',
            url: 'https://cdn.example.com/moment-1.png',
          ),
        ),
      );
    }
    return MomentPagesTestImmediateUploadOperation(
      Future<UploadedEditorImage>.error(
        const ApiFailure(userMessage: '第二张图片上传失败'),
      ),
    );
  }
}

class MomentPagesTestImmediateUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  MomentPagesTestImmediateUploadOperation(this.result);

  @override
  final Future<UploadedEditorImage> result;

  @override
  void cancel() {}
}

class MomentPagesTestLateCompletingUploadGateway implements MediaUploadGateway {
  final operation = MomentPagesTestLateCompletingUploadOperation();
  MediaUploadInput? input;

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    this.input = input;
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length ~/ 2,
        totalBytes: input.bytes.length,
      ),
    );
    return operation;
  }
}

class MomentPagesTestLateCompletingUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  final momentPagesTestCompleter = Completer<UploadedEditorImage>();
  var cancelled = false;

  @override
  Future<UploadedEditorImage> get result => momentPagesTestCompleter.future;

  @override
  void cancel() => cancelled = true;

  void complete(UploadedEditorImage image) =>
      momentPagesTestCompleter.complete(image);
}

MomentAuthor momentPagesTestAuthor() =>
    const MomentAuthor(id: 'user-1', username: '温柔测试员', level: 4);
