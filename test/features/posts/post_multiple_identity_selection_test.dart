import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_selection.dart';
import 'package:wenyousite_mobile/features/posts/application/post_publish_draft.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

class _Repository extends Mock implements ThreadIdentityRepository {}

const account = ThreadIdentityState(
  threadId: 'thread',
  userId: 'user',
  enabled: true,
  eligible: true,
  canEdit: true,
  accountName: '账号',
);
ThreadIdentityState role(String id, {String? token, bool usable = true}) =>
    ThreadIdentityState(
      threadId: 'thread',
      userId: 'user',
      enabled: true,
      eligible: true,
      canEdit: true,
      accountName: '账号',
      identityId: id,
      identityToken: token ?? 'token-$id',
      display: usable ? RpIdentity(id: id, nickname: '同名角色') : null,
    );
ThreadIdentityCollection roles(
  List<ThreadIdentityState> values, {
  String? compatibility = 'a',
  String? initial = 'a',
}) => ThreadIdentityCollection(
  account: account,
  identities: values,
  compatibilityIdentityId: compatibility,
  defaultIdentityId: initial,
);

void main() {
  late _Repository repo;
  late PostIdentitySelection selection;
  late ThreadIdentityCollection current;
  setUp(() {
    repo = _Repository();
    current = roles([role('a'), role('b')]);
    when(() => repo.list('thread')).thenAnswer((_) async => current);
    selection = PostIdentitySelection(repo, 'thread');
  });
  tearDown(() => selection.dispose());

  test('新建成功后列表失败仍保存新 ID，恢复读取后不会误用旧角色', () async {
    await selection.refresh();
    selection.acceptSaved(role('new'), created: true);
    when(() => repo.list('thread')).thenThrow(Exception('offline'));
    expect(await selection.refresh(), isFalse);
    expect(selection.identityId, 'new');
    expect(selection.acceptedToken, 'token-new');
    expect(selection.changed, isTrue);
    current = roles([role('a'), role('new')]);
    when(() => repo.list('thread')).thenAnswer((_) async => current);
    await selection.refresh();
    expect(selection.identityId, 'new');
    expect(selection.changed, isFalse);
  });

  test('明确保存当前角色接受新资料，编辑其他角色不切换 ACCOUNT 或 RP', () async {
    await selection.refresh();
    selection.acceptSaved(role('b', token: 'new-b'), created: false);
    expect(selection.identityId, 'a');
    selection.acceptSaved(role('a', token: 'new-a'), created: false);
    expect(selection.acceptedToken, 'new-a');
    selection.select(PostIdentityMode.account);
    selection.acceptSaved(role('b'), created: false);
    expect(selection.mode, PostIdentityMode.account);
  });

  test('同名角色按 ID 选择，编辑其他角色不改变选择或 token', () async {
    await selection.refresh();
    selection.select(PostIdentityMode.rp, id: 'b');
    current = roles([role('b'), role('a', token: 'renamed-a')]);
    await selection.refresh();
    expect(selection.identityId, 'b');
    expect(selection.acceptedToken, 'token-b');
    expect(selection.changed, isFalse);
  });
  test('已恢复草稿忽略新默认角色，删除原角色后等待确认再回到账号', () async {
    selection.restore(selected: PostIdentityMode.rp, id: 'b', token: 'token-b');
    await selection.refresh();
    current = roles([role('a')]);
    await selection.refresh();
    expect(selection.identityId, 'b');
    expect(selection.mode, PostIdentityMode.rp);
    expect(selection.changed, isTrue);
    selection.confirmCurrent();
    expect(selection.identityId, isNull);
    expect(selection.mode, PostIdentityMode.account);
  });
  test('清空两项资料的身份不能选择，也不顶替失效草稿', () async {
    current = roles([role('a', usable: false), role('b')], initial: 'b');
    await selection.refresh();
    selection.select(PostIdentityMode.rp, id: 'a');
    expect(selection.identityId, 'b');
  });
  test('旧 RP 草稿缺 ID 只使用兼容角色，不选择默认的其他角色', () async {
    current = roles([role('b')], compatibility: null, initial: 'b');
    selection.restore(selected: PostIdentityMode.rp, token: 'old');
    await selection.refresh();
    expect(selection.identityId, isNull);
    expect(selection.changed, isTrue);
    current = roles(
      [role('b'), role('new')],
      compatibility: 'new',
      initial: 'new',
    );
    await selection.refresh();
    expect(selection.identityId, isNull);
  });
  test('旧 RP 草稿映射兼容角色仍需核验原 token', () async {
    selection.restore(selected: PostIdentityMode.rp, token: 'token-a');
    await selection.refresh();
    expect(selection.identityId, 'a');
    expect(selection.changed, isFalse);
  });
  test('ACCOUNT 恢复不受默认角色改变影响', () async {
    selection.restore(selected: PostIdentityMode.account);
    await selection.refresh();
    expect(selection.mode, PostIdentityMode.account);
    expect(selection.identityId, isNull);
    expect(selection.changed, isFalse);
  });
  test('草稿和未知结果请求各自完整保存 ID，不随当前菜单选择改变', () {
    const draft = PostPublishDraft(
      mode: PostIdentityMode.rp,
      identityId: 'b',
      identityToken: 'token-b',
      pending: PendingPostCreate(
        input: PostCreateInput(
          subthreadId: 'sub',
          content: '冻结正文',
          clientRequestId: 'request',
          identityMode: PostIdentityMode.rp,
          identityId: 'a',
          identityToken: 'token-a',
        ),
      ),
    );
    final restored = PostPublishDraft.fromJson(draft.toJson())!;
    expect(restored.identityId, 'b');
    expect(restored.pending!.input.identityId, 'a');
    expect(restored.pending!.input.identityToken, 'token-a');
    expect(restored.pending!.input.clientRequestId, 'request');
  });
}
