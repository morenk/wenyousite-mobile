import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/production_overrides.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
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
}
