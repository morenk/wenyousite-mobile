import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_publish_draft.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

class _Repository extends Mock implements PostRepository {}

const _target = (
  kind: PostComposerKind.upsertBody,
  threadId: 'thread',
  subthreadId: 'sub',
  postId: null,
  parentPostId: null,
  replyToPostId: null,
  version: null,
  initialContent: '正文',
  label: '添加正文',
);

void main() {
  setUpAll(() => registerFallbackValue(PostIdentityMode.account));
  test('首次BODY请求前保存身份；关闭重开后不会改用新身份或正文重试', () async {
    final repository = _Repository();
    final calls = <Map<Symbol, dynamic>>[];
    when(
      () => repository.upsertBody(
        subthreadId: 'sub',
        content: any(named: 'content'),
        version: null,
        identityToken: any(named: 'identityToken'),
        identityMode: any(named: 'identityMode'),
      ),
    ).thenAnswer((invocation) async {
      calls.add(invocation.namedArguments);
      throw const ApiFailure(userMessage: '连接中断');
    });
    var controller = PostComposerController(repository, _target);
    PostPublishDraft? saved;
    await controller.submit(
      identityMode: PostIdentityMode.rp,
      identityToken: 'old',
      persistCreateIntent: () async {
        expect(calls, isEmpty);
        saved = PostPublishDraft.fromJson(
          PostPublishDraft(pending: controller.state.pendingCreate).toJson(),
        );
        return true;
      },
    );
    controller.dispose();
    controller = PostComposerController(repository, _target)
      ..restorePendingCreate(saved!.pending!);
    addTearDown(controller.dispose);
    controller.updateContent('不能改写');
    await controller.submit(
      identityMode: PostIdentityMode.account,
      identityToken: 'new',
    );
    expect(calls, hasLength(2));
    expect(calls.last[#content], '正文');
    expect(calls.last[#identityMode], PostIdentityMode.rp);
    expect(calls.last[#identityToken], 'old');
    expect(calls.last[#version], isNull);
  });

  test('首次BODY已存在的冲突不自动获取新version覆盖他人正文', () async {
    final repository = _Repository();
    var writes = 0;
    when(
      () => repository.upsertBody(
        subthreadId: 'sub',
        content: '正文',
        version: null,
        identityToken: null,
        identityMode: PostIdentityMode.account,
      ),
    ).thenAnswer((_) async {
      writes++;
      throw const ApiFailure(
        httpStatus: 409,
        businessCode: 40002,
        userMessage: '正文已存在',
      );
    });
    final controller = PostComposerController(repository, _target);
    addTearDown(controller.dispose);
    await controller.submit(identityMode: PostIdentityMode.account);
    expect(writes, 1);
    expect(controller.state.content, '正文');
    expect(controller.state.pendingCreate, isNull);
    expect(controller.state.conflict, isNull);
    expect(await controller.retryConflict(), isNull);
    expect(writes, 1);
  });
}
