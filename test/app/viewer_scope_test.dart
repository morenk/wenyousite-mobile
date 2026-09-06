import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/tags/application/tag_repository_ports.dart';
import 'package:wenyousite_mobile/features/tags/application/tag_threads_controller.dart';
import 'package:wenyousite_mobile/features/tags/domain/tag_models.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';

import '../support/moment_test_draft_store.dart';

void main() {
  test('真实会话切换和退出淘汰所有身份投影，刷新 Token 保留同一投影', () async {
    final container = _container();
    addTearDown(container.dispose);
    final session = container.read(sessionControllerProvider.notifier);
    await session.authenticate(_tokens('account-a'));
    final readers = <ProviderListenable<Object>>[
      momentFeedControllerProvider(
        const MomentFeedTarget.main(MomentFeedMode.discover),
      ).notifier,
      momentDetailControllerProvider('moment').notifier,
      publicUserControllerProvider('public-user').notifier,
      meUserContentControllerProvider('account-a').notifier,
      tagThreadsControllerProvider('tag').notifier,
      notificationListControllerProvider.notifier,
      notificationUnreadControllerProvider.notifier,
      directConversationListControllerProvider(
        DirectConversationView.inbox,
      ).notifier,
      directUnreadControllerProvider.notifier,
      stickerCollectionControllerProvider.notifier,
    ];
    for (final reader in readers) {
      container.listen(reader, (_, _) {});
    }
    final first = readers.map(container.read).toList();
    await _settle();
    final scope = container.read(viewerScopeProvider);
    await session.refresh();
    expect(container.read(viewerScopeProvider), scope);
    for (var i = 0; i < readers.length; i++) {
      expect(
        container.read(readers[i]),
        same(first[i]),
        reason: '刷新不清空第 $i 个投影',
      );
    }

    await session.authenticate(_tokens('account-b'));
    final second = readers.map(container.read).toList();
    for (var i = 0; i < readers.length; i++) {
      expect(second[i], isNot(same(first[i])), reason: '切号必须清空第 $i 个投影');
    }
    await _settle();
    await session.logoutLocally();
    for (var i = 0; i < readers.length; i++) {
      expect(
        container.read(readers[i]),
        isNot(same(second[i])),
        reason: '退出必须清空第 $i 个投影',
      );
    }
    expect(container.read(notificationUnreadControllerProvider).count, 0);
    await _settle();
  });

  for (final lateFailure in [false, true]) {
    test('可见性变更淘汰标签缓存并丢弃迟到${lateFailure ? '失败' : '成功'}，未发布草稿保留', () async {
      final repository = _Tags();
      final container = _container(tags: repository);
      addTearDown(container.dispose);
      await container
          .read(sessionControllerProvider.notifier)
          .authenticate(_tokens('owner'));
      final tag = tagThreadsControllerProvider('tag');
      final composer = momentComposerControllerProvider(null);
      container.listen(tag, (_, _) {});
      container.listen(composer, (_, _) {});
      final old = container.read(tag.notifier);
      final draft = container.read(composer.notifier);
      await _settle();
      expect(repository.requests, hasLength(1));
      container.read(visibilityCacheInvalidatorProvider)();
      final current = container.read(tag.notifier);
      expect(current, isNot(same(old)));
      expect(container.read(composer.notifier), same(draft));
      expect(repository.requests, hasLength(2));
      repository.requests[1].complete(_tagPage('新可见标签'));
      await _settle();
      if (lateFailure) {
        repository.requests[0].completeError(const ApiFailure(httpStatus: 503));
      } else {
        repository.requests[0].complete(_tagPage('旧可见标签'));
      }
      await _settle();
      expect(container.read(tag).tag?.name, '新可见标签');
      expect(container.read(tag).failure, isNull);
      expect(container.read(composer.notifier), same(draft));
    });
  }
}

ProviderContainer _container({TagRepository? tags}) => ProviderContainer(
  overrides: [
    tokenStoreProvider.overrideWithValue(_Tokens()),
    sessionRemoteProvider.overrideWithValue(_Remote()),
    momentDraftStoreProvider.overrideWithValue(MemoryMomentDraftStore()),
    momentComposerOwnerResolverProvider.overrideWithValue(() async => 'owner'),
    if (tags != null) tagRepositoryProvider.overrideWithValue(tags),
  ],
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

SessionTokens _tokens(String account) => SessionTokens(
  accessToken:
      'header.${base64Url.encode(utf8.encode(jsonEncode({'sub': account}))).replaceAll('=', '')}.signature',
  refreshToken: account,
);

class _Tokens implements TokenStore {
  SessionTokens? value;
  @override
  Future<SessionTokens?> read() async => value;
  @override
  Future<void> write(SessionTokens tokens) async {
    value = tokens;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

class _Remote extends Fake implements SessionRemote {
  @override
  Future<SessionTokens> refresh(String refreshToken) async =>
      _tokens(refreshToken);
}

class _Tags extends Fake implements TagRepository {
  final requests = <Completer<TagThreadsBootstrap>>[];
  @override
  Future<TagThreadsBootstrap> loadTagThreads(String tagId) {
    final request = Completer<TagThreadsBootstrap>();
    requests.add(request);
    return request.future;
  }
}

TagThreadsBootstrap _tagPage(String name) => TagThreadsBootstrap(
  tag: TopicTagModel(id: 'tag', name: name, sortOrder: 0, isActive: true),
  categories: const [],
  page: const CursorPage(items: [], hasMore: false),
);
