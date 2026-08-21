import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/threads/application/remote_thread_drafts_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

void main() {
  test('访问令牌刷新保留草稿箱，账号代次变化才重建', () async {
    final repository = _FakeRepository(drafts: [_summary('draft-one')]);
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(
          _RotatingSessionRemote(_tokensFor('user-one', '2')),
        ),
        threadComposeRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final session = container.read(sessionControllerProvider.notifier);
    await session.authenticate(_tokensFor('user-one', '1'));
    final subscription = container.listen(
      remoteThreadDraftsControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await _waitUntil(
      () =>
          container.read(remoteThreadDraftsControllerProvider).phase ==
          RemoteThreadDraftsPhase.ready,
      reason: 'initial provider did not become ready',
    );
    final original = container.read(
      remoteThreadDraftsControllerProvider.notifier,
    );

    await session.refresh();
    await container.pump();

    expect(
      container.read(remoteThreadDraftsControllerProvider.notifier),
      same(original),
    );
    expect(repository.fetchCalls, 1);
    expect(
      container.read(remoteThreadDraftsControllerProvider).drafts.single.id,
      'draft-one',
    );

    await session.authenticate(_tokensFor('user-two', '1'));
    await container.pump();
    expect(container.read(sessionScopeProvider).accountId, 'user-two');
    expect(
      container.read(remoteThreadDraftsControllerProvider.notifier),
      isNot(same(original)),
      reason: 'scope changed without recreating the drafts controller',
    );
    await _waitUntil(
      () => repository.fetchCalls == 2,
      reason: 'account switch did not recreate the provider',
    );

    expect(
      container.read(remoteThreadDraftsControllerProvider.notifier),
      isNot(same(original)),
    );
  });

  test('云端草稿箱加载并仅在删除确认后移除权威记录', () async {
    final repository = _FakeRepository(drafts: [_summary('draft-one')]);
    final controller = RemoteThreadDraftsController(
      repository,
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.state.phase, RemoteThreadDraftsPhase.ready);
    expect(controller.state.drafts.single.id, 'draft-one');

    expect(await controller.remove(controller.state.drafts.single), isTrue);
    expect(repository.removedIds, ['draft-one']);
    expect(controller.state.drafts, isEmpty);
  });

  test('草稿删除失败保留原列表、稳定错误与请求 ID', () async {
    final repository = _FakeRepository(
      drafts: [_summary('draft-one')],
      removeFailure: const ApiFailure(
        userMessage: '删除失败',
        requestId: 'request-one',
      ),
    );
    final controller = RemoteThreadDraftsController(
      repository,
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();

    expect(await controller.remove(controller.state.drafts.single), isFalse);
    expect(controller.state.drafts.single.id, 'draft-one');
    expect(controller.state.removeFailure?.requestId, 'request-one');
  });
}

ThreadRemoteDraftSummary _summary(String id) {
  return ThreadRemoteDraftSummary(
    id: id,
    title: '草稿 $id',
    categorySlug: 'TRPG',
    visibility: ThreadComposeVisibility.public,
    tags: const ['跑团'],
    createdAt: DateTime.utc(2026, 8, 9),
    updatedAt: DateTime.utc(2026, 8, 10),
    subthreadCount: 1,
    postCount: 2,
  );
}

Future<void> _waitUntil(bool Function() predicate, {String? reason}) async {
  for (var i = 0; i < 100 && !predicate(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  expect(predicate(), isTrue, reason: reason);
}

SessionTokens _tokensFor(String userId, String nonce) {
  final payload = base64Url
      .encode(utf8.encode('{"sub":"$userId","nonce":"$nonce"}'))
      .replaceAll('=', '');
  return SessionTokens(
    accessToken: 'header.$payload.signature',
    refreshToken: 'refresh-$userId-$nonce',
  );
}

class _FakeRepository implements ThreadComposeRepository {
  _FakeRepository({required this.drafts, this.removeFailure});

  final List<ThreadRemoteDraftSummary> drafts;
  final ApiFailure? removeFailure;
  final List<String> removedIds = [];
  int fetchCalls = 0;

  @override
  Future<List<ThreadRemoteDraftSummary>> fetchDrafts() async {
    fetchCalls += 1;
    return drafts;
  }

  @override
  Future<void> removeDraft(String id) async {
    final failure = removeFailure;
    if (failure != null) throw failure;
    removedIds.add(id);
  }

  @override
  Future<ThreadComposeBootstrap> fetchBootstrap() => throw UnimplementedError();

  @override
  Future<ThreadRemoteDraft> fetchDraft({
    required String id,
    required String ownerId,
  }) => throw UnimplementedError();

  @override
  Future<ThreadRemoteDraft> createDraft(ThreadCreatePayload payload) =>
      throw UnimplementedError();

  @override
  Future<ThreadRemoteDraft> saveAggregate({
    required ThreadRemoteDraft remoteDraft,
    required String title,
    required String? categorySlug,
    required ThreadComposeVisibility visibility,
    required List<String> tags,
    required String body,
    required bool publish,
  }) => throw UnimplementedError();
}

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class _RotatingSessionRemote implements SessionRemote {
  _RotatingSessionRemote(this.nextTokens);

  final SessionTokens nextTokens;

  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async => nextTokens;
}
