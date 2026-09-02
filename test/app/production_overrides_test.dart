import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/production_overrides.dart';
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
import 'package:wenyousite_mobile/features/wallet/application/wallet_repository_ports.dart';

void main() {
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
