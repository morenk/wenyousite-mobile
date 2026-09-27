import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/config/app_environment.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/storage/app_database.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/media/data/private_pending_media_file_store.dart';

AppEnvironment previewEnvironment({
  String run = 'aaaaaaaaaaaaaaaaaaaaaaaa',
  String api = 'http://127.0.0.1:23080/api/v1',
  String media = 'http://127.0.0.1:23081',
}) => AppEnvironment(
  apiBaseUrl: api,
  previewSession: 'test-preview',
  previewRun: 'preview_$run',
  previewSnapshotAt: '2026-09-26T00:00:00Z',
  previewSnapshotSha: 'a' * 64,
  previewMediaOrigin: media,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const production = AppEnvironment(apiBaseUrl: 'https://wenyou.site/api/v1');
  test('预览只允许完整 Debug 配置与独立 loopback，release 和线上地址拒绝', () {
    expect(
      () => previewEnvironment().validatePreview(isDebugMode: true),
      returnsNormally,
    );
    expect(
      () => previewEnvironment().validatePreview(isDebugMode: false),
      throwsStateError,
    );
    for (final api in [
      'https://wenyou.site/api/v1',
      'http://127.0.0.1:3000/api/v1',
      'http://127.0.0.1:3001/api/v1',
      'http://127.0.0.1:23080/api/v1?target=online',
    ]) {
      expect(
        () => previewEnvironment(api: api).validatePreview(isDebugMode: true),
        throwsStateError,
      );
    }
    expect(
      () => const AppEnvironment(
        apiBaseUrl: 'https://wenyou.site/api/v1',
        previewRun: 'incomplete',
      ).validatePreview(isDebugMode: true),
      throwsStateError,
    );
  });
  test('旧键保持不变，同名批次 reset 后按 runId 分离', () {
    expect(
      production.storageName('wenyou_mobile.sqlite'),
      'wenyou_mobile.sqlite',
    );
    expect(
      previewEnvironment().storageName('wenyou_mobile.sqlite'),
      isNot(production.storageName('wenyou_mobile.sqlite')),
    );
    expect(
      previewEnvironment(run: 'b' * 24).storageName('draft'),
      isNot(previewEnvironment().storageName('draft')),
    );
  });
  test('相同固定端口切换批次，待提交记录和图片草稿独立且恢复保留', () async {
    final root = await Directory.systemTemp.createTemp('wenyou-switch-data-');
    final first = previewEnvironment(
      api: 'http://127.0.0.1:14311/api/v1',
      media: 'http://127.0.0.1:14312',
    );
    final second = previewEnvironment(
      run: 'b' * 24,
      api: first.apiBaseUrl,
      media: first.previewMediaOrigin,
    );
    final firstDb = AppDatabase(environment: first, rootDirectory: root);
    final secondDb = AppDatabase(environment: second, rootDirectory: root);
    final firstDraft = PrivatePendingMediaFileStore(
      environment: first,
      rootDirectory: root,
    );
    final secondDraft = PrivatePendingMediaFileStore(
      environment: second,
      rootDirectory: root,
    );
    addTearDown(() async {
      await firstDb.close();
      await secondDb.close();
      await root.delete(recursive: true);
    });
    await firstDb.savePendingCreateOperation(
      PendingCreateOperation(
        clientRequestId: 'same-request',
        operationType: 'create-thread',
        normalizedPayload: '{"body":"pending-first"}',
        state: PendingOperationState.awaitingConfirmation,
        updatedAt: DateTime.utc(2026, 9, 26),
      ),
    );
    await firstDraft.write(
      accountId: 'same-user',
      target: 'same-target',
      payload: {'draft': 'keep-first'},
    );
    expect(await secondDb.findPendingCreateOperation('same-request'), isNull);
    expect(
      await secondDraft.read(accountId: 'same-user', target: 'same-target'),
      isNull,
    );
    await secondDraft.write(
      accountId: 'same-user',
      target: 'same-target',
      payload: {'draft': 'second'},
    );
    final restored = PrivatePendingMediaFileStore(
      environment: first,
      rootDirectory: root,
    );
    expect(await restored.read(accountId: 'same-user', target: 'same-target'), {
      'draft': 'keep-first',
    });
    expect(
      (await firstDb.findPendingCreateOperation(
        'same-request',
      ))?.normalizedPayload,
      '{"body":"pending-first"}',
    );
  });
  test('预览 Token 读写与退出均不读取或删除旧线上及其他批次凭据', () async {
    FlutterSecureStorage.setMockInitialValues({
      'wenyou_mobile_session_v1': jsonEncode({
        'accessToken': 'existing-access',
        'refreshToken': 'existing-refresh',
      }),
    });
    const secure = FlutterSecureStorage();
    final online = SecureTokenStore(secure, environment: production);
    final preview = SecureTokenStore(secure, environment: previewEnvironment());
    final reset = SecureTokenStore(
      secure,
      environment: previewEnvironment(run: 'b' * 24),
    );
    expect(await preview.read(), isNull);
    await preview.write(
      const SessionTokens(
        accessToken: 'preview-access',
        refreshToken: 'preview-refresh',
      ),
    );
    expect((await online.read())?.accessToken, 'existing-access');
    expect(await reset.read(), isNull);
    await preview.clear();
    expect((await online.read())?.refreshToken, 'existing-refresh');
  });
  test('数据库路径分离，预览 pending 操作不会进入旧线上数据库', () async {
    final root = await Directory.systemTemp.createTemp('wenyou-env-db-');
    final online = AppDatabase(environment: production, rootDirectory: root);
    final preview = AppDatabase(
      environment: previewEnvironment(),
      rootDirectory: root,
    );
    addTearDown(() async {
      await online.close();
      await preview.close();
      await root.delete(recursive: true);
    });
    await online.customStatement(
      'CREATE TABLE environment_marker (value TEXT)',
    );
    await online.customStatement(
      "INSERT INTO environment_marker VALUES ('keep-online')",
    );
    final rows = await preview
        .customSelect(
          "SELECT name FROM sqlite_master WHERE name='environment_marker'",
        )
        .get();
    expect(rows, isEmpty);
    expect(
      (await online
              .customSelect('SELECT value FROM environment_marker')
              .getSingle())
          .read<String>('value'),
      'keep-online',
    );
    expect(await File('${root.path}/wenyou_mobile.sqlite').exists(), isTrue);
    expect(
      await File(
        '${root.path}/${previewEnvironment().storageName('wenyou_mobile.sqlite')}',
      ).exists(),
      isTrue,
    );
  });
  test('相同账号和编辑目标的图片草稿按预览批次隔离且清理只影响本批次', () async {
    final root = await Directory.systemTemp.createTemp('wenyou-env-media-');
    addTearDown(() => root.delete(recursive: true));
    final online = PrivatePendingMediaFileStore(
      rootDirectory: root,
      environment: production,
    );
    final preview = PrivatePendingMediaFileStore(
      rootDirectory: root,
      environment: previewEnvironment(),
    );
    await online.write(
      accountId: 'user',
      target: 'new',
      payload: {'text': 'keep'},
    );
    expect(await preview.read(accountId: 'user', target: 'new'), isNull);
    await preview.write(
      accountId: 'user',
      target: 'new',
      payload: {'text': 'preview'},
    );
    await preview.delete(accountId: 'user', target: 'new');
    expect(await online.read(accountId: 'user', target: 'new'), {
      'text': 'keep',
    });
  });
}
