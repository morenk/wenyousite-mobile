import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/storage/app_database.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_composer_controller.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_draft_store.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

void main() {
  late AppDatabase database;
  late DatabaseMomentDraftStore store;
  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    store = DatabaseMomentDraftStore(database);
  });
  tearDown(() => database.close());

  test('动态草稿按账号与编辑对象隔离，旧无归属草稿保留但不恢复', () async {
    final legacy = jsonEncode(_draft('旧草稿').toJson());
    SharedPreferences.setMockInitialValues({
      'moment.compose.draft.v1:new': legacy,
    });
    expect(await store.read('a', null), isNull);
    await store.write('a', null, _draft('账号甲'));
    await store.write('b', null, _draft('账号乙'));
    await store.write('a', 'existing', _draft('编辑旧动态'));
    expect((await store.read('a', null))?.title, '账号甲');
    expect((await store.read('b', null))?.title, '账号乙');
    expect((await store.read('a', 'existing'))?.title, '编辑旧动态');
    expect(await store.read('b', 'existing'), isNull);
    await store.delete('a', null);
    expect((await store.read('b', null))?.title, '账号乙');
    expect(
      (await SharedPreferences.getInstance()).getString(
        'moment.compose.draft.v1:new',
      ),
      legacy,
    );
  });

  test('首次提交快照与待确认操作原子写入，失败回滚已有草稿', () async {
    await store.write('a', null, _draft('原草稿'));
    await database.customStatement(
      '''CREATE TRIGGER fail_pending BEFORE INSERT
      ON pending_create_operations BEGIN SELECT RAISE(ABORT, 'test write failure'); END''',
    );
    await expectLater(
      store.beginCreate('a', _draft('提交内容'), _operation()),
      throwsA(isA<Object>()),
    );
    expect((await store.read('a', null))?.title, '原草稿');
    expect(await database.findPendingCreateOperation('request-a'), isNull);
  });

  test('待确认快照拒绝普通保存、删除、载荷替换和跨账号清理', () async {
    await store.beginCreate('a', _draft('提交内容'), _operation());
    await store.write('a', null, _draft('迟到的自动保存'));
    expect((await store.read('a', null))?.title, '提交内容');
    await expectLater(store.delete('a', null), throwsStateError);
    await expectLater(
      store.beginCreate('a', _draft('替换内容'), _operation(title: '替换内容')),
      throwsStateError,
    );
    await expectLater(
      store.finishCreate('a', 'another-id', discardDraft: true),
      throwsStateError,
    );
    await store.finishCreate('b', 'request-a', discardDraft: true);
    expect(
      (await store.read('a', null))?.pendingCreate?.clientRequestId,
      'request-a',
    );
    await store.finishCreate('a', 'request-a', discardDraft: false);
    expect((await store.read('a', null))?.pendingCreate, isNull);
    expect((await store.read('a', null))?.title, '提交内容');
    await store.delete('a', null);
    expect(await store.read('a', null), isNull);
  });

  test('schema v1 原表可保存动态并跨数据库重开恢复原子待确认操作', () async {
    await database.close();
    final directory = await Directory.systemTemp.createTemp(
      'wenyou-moment-v1-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/moments.sqlite');
    final first = AppDatabase.forTesting(NativeDatabase(file));
    await DatabaseMomentDraftStore(
      first,
    ).beginCreate('a', _draft('提交内容'), _operation());
    expect(first.schemaVersion, 1);
    await first.close();
    final reopened = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(reopened.close);
    final restored = await DatabaseMomentDraftStore(reopened).read('a', null);
    expect(restored?.content, '完整正文');
    expect(restored?.images.single.feedUrl, 'https://example.com/feed.png');
    expect(restored?.clientRequestId, 'request-a');
    expect(
      restored?.pendingCreate?.normalizedPayload,
      _operation().normalizedPayload,
    );
  });

  test('超时与页面重建保留原载荷和 UUID，恢复不自动发布', () async {
    final repository = _Repository()
      ..failure = const ApiFailure(httpStatus: 503);
    final first = _controller(repository, store);
    await first.load();
    expect(await first.submit(_input(), draft: _draft('提交内容')), isNull);
    expect(first.state.canEditContent, isFalse);
    expect(await first.saveDraft(_draft('不能修改')), isFalse);
    expect(await first.deleteDraft(), isFalse);
    final requestId = repository.requests.single.$1;
    first.dispose();
    final resumed = _controller(repository, store);
    addTearDown(resumed.dispose);
    await resumed.load();
    expect(repository.requests, hasLength(1));
    expect(resumed.state.awaitingConfirmation, isTrue);
    expect(resumed.state.localDraft?.title, '提交内容');
    repository.failure = null;
    expect(await resumed.submit(_input(title: '后续输入不得替换')), isNotNull);
    expect(repository.requests.map((request) => request.$1), [
      requestId,
      requestId,
    ]);
    expect(repository.requests.map((request) => request.$2.title), [
      '提交内容',
      '提交内容',
    ]);
    expect(repository.requests.last.$2.mediaIds, ['media-a']);
    expect(await store.read('a', null), isNull);
    expect(await database.findPendingCreateOperation(requestId), isNull);
  });

  test('首次持久化失败不发请求，恢复保存后允许明确重试', () async {
    final repository = _Repository();
    final failing = _ControlledStore(store)..failBegin = true;
    final controller = _controller(repository, failing);
    addTearDown(controller.dispose);
    await controller.load();
    expect(await controller.submit(_input(), draft: _draft('提交内容')), isNull);
    expect(repository.requests, isEmpty);
    expect(controller.state.canEditContent, isTrue);
    failing.failBegin = false;
    expect(await controller.submit(_input(), draft: _draft('提交内容')), isNotNull);
  });

  test('成功但本机清理失败时原页面只重试清理，不重复创建', () async {
    final repository = _Repository();
    final failing = _ControlledStore(store)..failFinish = true;
    final controller = _controller(repository, failing);
    addTearDown(controller.dispose);
    await controller.load();
    expect(await controller.submit(_input(), draft: _draft('提交内容')), isNull);
    expect(controller.state.awaitingConfirmation, isTrue);
    failing.failFinish = false;
    expect(await controller.submit(_input()), isNotNull);
    expect(repository.requests, hasLength(1));
    expect(await store.read('a', null), isNull);
  });

  test('已开始的慢保存先完成再删除，删除后不复活草稿', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final delayed = _ControlledStore(store)
      ..beforeWrite = () async {
        entered.complete();
        await release.future;
      };
    final controller = _controller(_Repository(), delayed);
    addTearDown(controller.dispose);
    await controller.load();
    final save = controller.saveDraft(_draft('慢保存'));
    await entered.future;
    final discard = controller.deleteDraft();
    release.complete();
    expect(await save, isTrue);
    expect(await discard, isTrue);
    expect(await store.read('a', null), isNull);
  });

  test('账号切换释放控制器后不发送已排队的创建操作', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final delayed = _ControlledStore(store)
      ..beforeBegin = () async {
        entered.complete();
        await release.future;
      };
    final repository = _Repository();
    final controller = _controller(repository, delayed);
    await controller.load();
    final submit = controller.submit(_input(), draft: _draft('提交内容'));
    await entered.future;
    controller.dispose();
    release.complete();
    expect(await submit, isNull);
    expect(repository.requests, isEmpty);
    expect((await store.read('a', null))?.pendingCreate, isNotNull);
    expect(await store.read('b', null), isNull);
  });
}

MomentComposerController _controller(
  MomentRepository repository,
  MomentDraftStore store,
) => MomentComposerController(
  repository,
  draftStore: store,
  resolveOwner: () async => 'a',
  autoStart: false,
);

MomentDraftInput _input({String title = '提交内容'}) => MomentDraftInput(
  title: title,
  content: '完整正文',
  mediaIds: const ['media-a'],
  coverMediaId: 'media-a',
);

MomentLocalDraft _draft(String title) => MomentLocalDraft(
  title: title,
  content: '完整正文',
  updatedAt: DateTime.utc(2026, 9, 7),
  coverMediaId: 'media-a',
  images: const [
    UploadedEditorImage(
      mediaId: 'media-a',
      url: 'https://example.com/image.png',
      feedUrl: 'https://example.com/feed.png',
    ),
  ],
);

PendingCreateOperation _operation({String title = '提交内容'}) =>
    PendingCreateOperation(
      clientRequestId: 'request-a',
      operationType: 'moment.create',
      normalizedPayload: jsonEncode({
        'ownerId': 'a',
        'input': {
          'title': title,
          'content': '完整正文',
          'mediaIds': ['media-a'],
          'coverMediaId': 'media-a',
        },
      }),
      state: PendingOperationState.awaitingConfirmation,
      updatedAt: DateTime.utc(2026, 9, 7),
    );

class _Repository extends Fake implements MomentRepository {
  final requests = <(String, MomentDraftInput)>[];
  ApiFailure? failure;

  @override
  Future<MomentDetail> create(
    MomentDraftInput input, {
    required String clientRequestId,
  }) async {
    requests.add((clientRequestId, input));
    if (failure case final error?) throw error;
    return MomentDetail(
      card: MomentCard(
        id: 'created',
        author: const MomentAuthor(id: 'a', username: '测试', level: 1),
        title: input.title,
        contentExcerpt: input.content,
        coverType: MomentCoverType.text,
        textCoverTheme: MomentTextCoverTheme.rose,
        imageCount: 0,
        likeCount: 0,
        commentCount: 0,
        bookmarkCount: 0,
        tipTotal: '0',
        viewerLiked: false,
        viewerBookmarked: false,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      content: input.content,
      images: const [],
      version: 1,
      canEdit: true,
      canDelete: true,
    );
  }
}

class _ControlledStore implements MomentDraftStore {
  _ControlledStore(this.delegate);
  final MomentDraftStore delegate;
  bool failBegin = false;
  bool failFinish = false;
  Future<void> Function()? beforeWrite;
  Future<void> Function()? beforeBegin;

  @override
  Future<MomentLocalDraft?> read(String ownerId, String? momentId) =>
      delegate.read(ownerId, momentId);
  @override
  Future<void> write(
    String ownerId,
    String? momentId,
    MomentLocalDraft draft,
  ) async {
    await beforeWrite?.call();
    await delegate.write(ownerId, momentId, draft);
  }

  @override
  Future<void> delete(String ownerId, String? momentId) =>
      delegate.delete(ownerId, momentId);
  @override
  Future<void> beginCreate(
    String ownerId,
    MomentLocalDraft draft,
    PendingCreateOperation operation,
  ) async {
    await beforeBegin?.call();
    if (failBegin) throw StateError('Test persistence failure.');
    await delegate.beginCreate(ownerId, draft, operation);
  }

  @override
  Future<void> finishCreate(
    String ownerId,
    String requestId, {
    required bool discardDraft,
  }) async {
    if (failFinish) throw StateError('Test persistence failure.');
    await delegate.finishCreate(ownerId, requestId, discardDraft: discardDraft);
  }
}
