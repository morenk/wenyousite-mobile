import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_drafts.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_local_draft.dart';
import 'package:wenyousite_mobile/features/posts/application/post_publish_draft.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

import '../../support/memory_pending_media_file_store.dart';

void main() {
  test('旧图片文件缺失仍迁移正文和可移除占位，不阻塞整份草稿恢复', () async {
    final store = MemoryPendingMediaFileStore();
    addTearDown(store.dispose);
    final target = _target();
    final legacy = 'post:${postComposerLegacyDraftKey(target)}';
    await store.write(
      accountId: 'account',
      target: legacy,
      payload: {
        'markdown': '保留的正文和图片占位',
        'images': [
          {
            'id': 'missing',
            'input': {
              'filename': 'missing.png',
              'path': '${store.directory.path}/missing.png',
              'length': 12,
              'purpose': 'richContent',
            },
          },
        ],
      },
    );
    final selected = await preparePostComposerLocalDraft(
      store: store,
      accountId: 'account',
      target: target,
    );
    final saved = (await store.read(
      accountId: 'account',
      target: selected.target,
    ))!;
    expect(saved['markdown'], '保留的正文和图片占位');
    final image = (saved['images'] as List).single as Map;
    expect(image['id'], 'missing');
    expect(
      (image['input'] as Map)['path'],
      '${store.directory.path}/missing.png',
    );
  });
  test('楼层和回复按主题共享；不同主题、编辑、子贴正文独立', () {
    final shared = postComposerDraftKey(_target());
    expect(
      postComposerDraftKey(_target(subthread: 'other', parent: 'b')),
      shared,
    );
    expect(
      postComposerDraftKey(_target(kind: PostComposerKind.createFloor)),
      shared,
    );
    expect(postComposerDraftKey(_target(thread: 'other')), isNot(shared));
    expect(
      postComposerDraftKey(_target(kind: PostComposerKind.editPost)),
      isNot(shared),
    );
    expect(
      postComposerDraftKey(_target(kind: PostComposerKind.upsertBody)),
      isNot(shared),
    );
  });

  test('迁移原入口旧草稿时复制图片，保留正文/元数据，旧记录不能再次恢复', () async {
    final store = MemoryPendingMediaFileStore();
    addTearDown(store.dispose);
    final target = _target();
    final legacy = 'post:${postComposerLegacyDraftKey(target)}';
    final input = await store.persist(
      MediaUploadInput(
        filename: 'draft.png',
        bytes: Uint8List.fromList([1, 2, 3]),
        purpose: MediaUploadPurpose.richContent,
      ),
      accountId: 'account',
      target: legacy,
      attachmentId: 'local-image',
    );
    await store.write(
      accountId: 'account',
      target: legacy,
      payload: {
        'markdown': '**草稿**\n![图片](wenyou-local-image:local-image)',
        'metadata': {'identityMode': 'rp', 'identityId': 'role'},
        'images': [
          {'id': 'local-image', 'input': encodePendingMediaInput(input)},
        ],
      },
    );
    final result = await preparePostComposerLocalDraft(
      store: store,
      accountId: 'account',
      target: target,
    );
    final saved = (await store.read(
      accountId: 'account',
      target: result.target,
    ))!;
    expect(saved['migratedFrom'], legacy);
    expect(saved['markdown'], startsWith('**草稿**'));
    expect(saved['metadata'], {'identityMode': 'rp', 'identityId': 'role'});
    final restoredInput =
        ((saved['images'] as List).single as Map)['input'] as Map;
    expect(restoredInput['path'], isNot(input.sourcePath));
    expect(File(restoredInput['path'] as String).readAsBytesSync(), [1, 2, 3]);
    expect(File(input.sourcePath!).existsSync(), isTrue);
    expect(
      (await store.read(accountId: 'account', target: legacy))!['completed'],
      true,
    );
    await store.delete(accountId: 'account', target: result.target);
    await preparePostComposerLocalDraft(
      store: store,
      accountId: 'account',
      target: target,
    );
    expect(
      await store.read(accountId: 'account', target: result.target),
      isNull,
    );
  });

  test('新快照已写但旧记录标记失败时，重试先补齐标记而不重新覆盖新稿', () async {
    final store = _FailLegacyMarkStore();
    addTearDown(store.dispose);
    final target = _target();
    final legacy = 'post:${postComposerLegacyDraftKey(target)}';
    await store.write(
      accountId: 'account',
      target: legacy,
      payload: {'markdown': '旧稿'},
    );
    store.failLegacyMark = true;
    await expectLater(
      preparePostComposerLocalDraft(
        store: store,
        accountId: 'account',
        target: target,
      ),
      throwsA(isA<FileSystemException>()),
    );
    final shared = 'post:${postComposerDraftKey(target)}';
    final payload = (await store.read(accountId: 'account', target: shared))!;
    expect(payload['migratedFrom'], legacy);
    store.failLegacyMark = false;
    await preparePostComposerLocalDraft(
      store: store,
      accountId: 'account',
      target: _target(parent: 'b'),
    );
    expect(
      (await store.read(accountId: 'account', target: legacy))!['completed'],
      true,
    );
  });

  test('共享待确认请求错目标打不开且原载荷不变，不同账号不读取它', () async {
    final store = MemoryPendingMediaFileStore();
    addTearDown(store.dispose);
    final target = _target();
    final key = 'post:${postComposerDraftKey(target)}';
    final payload = {'markdown': '冻结正文', 'metadata': _pending(target).toJson()};
    await store.write(accountId: 'account', target: key, payload: payload);
    await expectLater(
      preparePostComposerLocalDraft(
        store: store,
        accountId: 'account',
        target: _target(parent: 'b'),
      ),
      throwsA(isA<PostDraftTargetBlocked>()),
    );
    expect(await store.read(accountId: 'account', target: key), payload);
    expect(
      (await preparePostComposerLocalDraft(
        store: store,
        accountId: 'account',
        target: target,
      )).target,
      key,
    );
    await preparePostComposerLocalDraft(
      store: store,
      accountId: 'other',
      target: _target(parent: 'b'),
    );
    expect(await store.read(accountId: 'other', target: key), isNull);
  });

  test('旧版未确认请求仍从原入口单独恢复，不覆盖已写的共享草稿', () async {
    final store = MemoryPendingMediaFileStore();
    addTearDown(store.dispose);
    final target = _target();
    final legacy = 'post:${postComposerLegacyDraftKey(target)}';
    final shared = 'post:${postComposerDraftKey(target)}';
    await store.write(
      accountId: 'account',
      target: legacy,
      payload: {'markdown': '冻结正文', 'metadata': _pending(target).toJson()},
    );
    await store.write(
      accountId: 'account',
      target: shared,
      payload: {'markdown': '新草稿'},
    );
    final selected = await preparePostComposerLocalDraft(
      store: store,
      accountId: 'account',
      target: target,
    );
    expect(selected, (target: legacy, isolated: true));
    expect(
      (await store.read(accountId: 'account', target: shared))!['markdown'],
      '新草稿',
    );
  });
}

PostComposerTarget _target({
  String thread = 'thread',
  String subthread = 'subthread',
  String parent = 'a',
  PostComposerKind kind = PostComposerKind.createReply,
}) => (
  kind: kind,
  threadId: thread,
  subthreadId: subthread,
  postId: kind == PostComposerKind.editPost ? 'post' : null,
  parentPostId: kind == PostComposerKind.createReply ? parent : null,
  replyToPostId: kind == PostComposerKind.createReply ? parent : null,
  version: null,
  initialContent: '',
  label: '回复',
);

PostPublishDraft _pending(PostComposerTarget target) => PostPublishDraft(
  pending: PendingPostCreate(
    input: PostCreateInput(
      subthreadId: target.subthreadId,
      parentPostId: target.parentPostId,
      replyToPostId: target.replyToPostId,
      content: '冻结正文',
      clientRequestId: 'same-request',
    ),
  ),
);

class _FailLegacyMarkStore extends MemoryPendingMediaFileStore {
  bool failLegacyMark = false;
  @override
  Future<void> write({
    required String accountId,
    required String target,
    required Map<String, Object?> payload,
  }) {
    if (failLegacyMark && payload['completed'] == true) {
      throw const FileSystemException('标记失败');
    }
    return super.write(accountId: accountId, target: target, payload: payload);
  }
}
