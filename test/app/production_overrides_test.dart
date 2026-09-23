import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/app/production_overrides.dart';
import 'package:wenyousite_mobile/core/application/profile_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/contract_info.dart';
import 'package:wenyousite_mobile/features/auth/application/auth_ports.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_repository_ports.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_draft_repository_ports.dart';
import 'package:wenyousite_mobile/features/editor/application/editor_snapshot_store_ports.dart';
import 'package:wenyousite_mobile/features/home/application/home_repository_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/search/application/search_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_repository_ports.dart';

void main() {
  test('关系变更同时失效我的计数、本人公开资料和对方公开资料', () {
    final container = ProviderContainer(
      overrides: [
        ...productionProviderOverrides(),
        sessionScopeProvider.overrideWithValue(
          const SessionScope(accountId: 'me', generation: 1),
        ),
        meProfileControllerProvider.overrideWith(
          (ref) => MeProfileController(_MockMeRepository(), autoStart: false),
        ),
        publicUserControllerProvider.overrideWith(
          (ref, id) => PublicUserController(
            _MockPublicRepository(),
            id,
            autoStart: false,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final me = container.listen(meProfileControllerProvider, (_, _) {});
    final self = container.listen(
      publicUserControllerProvider('me'),
      (_, _) {},
    );
    final peer = container.listen(
      publicUserControllerProvider('peer'),
      (_, _) {},
    );
    addTearDown(me.close);
    addTearDown(self.close);
    addTearDown(peer.close);
    final beforeMe = container.read(meProfileControllerProvider.notifier);
    final beforeSelf = container.read(
      publicUserControllerProvider('me').notifier,
    );
    final beforePeer = container.read(
      publicUserControllerProvider('peer').notifier,
    );
    container.read(profileCacheInvalidatorProvider)('peer');
    expect(
      identical(container.read(meProfileControllerProvider.notifier), beforeMe),
      false,
    );
    expect(
      identical(
        container.read(publicUserControllerProvider('me').notifier),
        beforeSelf,
      ),
      false,
    );
    expect(
      identical(
        container.read(publicUserControllerProvider('peer').notifier),
        beforePeer,
      ),
      false,
    );
  });
  test('生产组合根绑定启动、公开浏览、创作与消息必需端口', () {
    final container = ProviderContainer(
      overrides: productionProviderOverrides(),
    );
    addTearDown(container.dispose);
    final mandatoryPorts = <ProviderListenable<Object?>>[
      metaRepositoryProvider,
      authRepositoryProvider,
      homeRepositoryProvider,
      threadDetailRepositoryProvider,
      searchRepositoryProvider,
      contentDraftRepositoryProvider,
      editorSnapshotStoreProvider,
      momentRepositoryProvider,
      postRepositoryProvider,
      directMessageRepositoryProvider,
      notificationRepositoryProvider,
      walletRepositoryProvider,
      editorImagePickerPortProvider,
      mediaUploadGatewayPortProvider,
    ];

    for (final provider in mandatoryPorts) {
      expect(() => container.read(provider), returnsNormally);
    }
  });

  test('Markdown v4 启用文字块对齐，v5 再启用图片块对齐', () {
    const v3 = ContractInfo(
      contractVersion: '5.14.0',
      markdownContractVersion: 3,
      stickersEnabled: true,
    );
    const v4 = ContractInfo(
      contractVersion: '5.14.0',
      markdownContractVersion: 4,
      directMessagesEnabled: true,
    );
    const v5 = ContractInfo(
      contractVersion: '5.15.0',
      markdownContractVersion: 5,
    );

    expect(appCapabilitiesForContract(v3).markdownAlignment, isFalse);
    expect(appCapabilitiesForContract(v3).markdownImageAlignment, isFalse);
    expect(appCapabilitiesForContract(v3).stickers, isTrue);
    expect(appCapabilitiesForContract(v4).markdownAlignment, isTrue);
    expect(appCapabilitiesForContract(v4).markdownImageAlignment, isFalse);
    expect(appCapabilitiesForContract(v4).directMessages, isTrue);
    expect(appCapabilitiesForContract(v5).markdownAlignment, isTrue);
    expect(appCapabilitiesForContract(v5).markdownImageAlignment, isTrue);
    expect(appCapabilitiesForContract(null).markdownAlignment, isFalse);
  });
}

class _MockMeRepository extends Mock implements MeProfileRepository {}

class _MockPublicRepository extends Mock implements PublicUserRepository {}
