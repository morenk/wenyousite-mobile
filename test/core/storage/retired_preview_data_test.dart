import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/storage/app_database.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/media/data/private_pending_media_file_store.dart';
import 'package:wenyousite_mobile/features/media/data/shared_preferences_media_picker_recovery_context_store.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('旧批次选图不会恢复到普通账号，新选择仍可使用', () async {
    const key = SharedPreferencesMediaPickerRecoveryContextStore.storageKey;
    const oldKey = 'preview_aaaaaaaaaaaaaaaaaaaaaaaa.$key';
    final purpose = MediaUploadPurpose.values.first;
    SharedPreferences.setMockInitialValues({
      'media.picker.environment.v1': oldKey,
      oldKey: purpose.name,
      key: purpose.name,
    });
    const store = SharedPreferencesMediaPickerRecoveryContextStore();
    expect(await store.read(), isNull);
    await store.begin(purpose);
    expect(await store.read(), purpose);
    await store.clear();
    expect(
      (await SharedPreferences.getInstance()).getString(oldKey),
      purpose.name,
    );
  });

  test('普通会话读取原键，退出不删除已退役批次的凭据', () async {
    const oldKey = 'preview_aaaaaaaaaaaaaaaaaaaaaaaa.wenyou_mobile_session_v1';
    final retained = jsonEncode({
      'accessToken': 'old',
      'refreshToken': 'old-refresh',
    });
    FlutterSecureStorage.setMockInitialValues({
      'wenyou_mobile_session_v1': jsonEncode({
        'accessToken': 'current',
        'refreshToken': 'current-refresh',
      }),
      oldKey: retained,
    });
    const secure = FlutterSecureStorage();
    final store = SecureTokenStore(secure);
    expect((await store.read())?.accessToken, 'current');
    await store.clear();
    expect(await store.read(), isNull);
    expect(await secure.read(key: oldKey), retained);
  });

  test('普通数据库重开保持原数据，不读取或清理旧批次文件', () async {
    final root = await Directory.systemTemp.createTemp('wenyou-retired-db-');
    final old = File(
      '${root.path}/preview_aaaaaaaaaaaaaaaaaaaaaaaa.wenyou_mobile.sqlite',
    );
    await old.writeAsString('retained old preview database');
    var database = AppDatabase(rootDirectory: root);
    addTearDown(() async {
      await database.close();
      await root.delete(recursive: true);
    });
    await database.customStatement('CREATE TABLE retained_marker (value TEXT)');
    await database.customStatement(
      "INSERT INTO retained_marker VALUES ('existing draft')",
    );
    await database.close();
    database = AppDatabase(rootDirectory: root);
    expect(
      (await database
              .customSelect('SELECT value FROM retained_marker')
              .getSingle())
          .read<String>('value'),
      'existing draft',
    );
    expect(await File('${root.path}/wenyou_mobile.sqlite').exists(), isTrue);
    expect(await old.readAsString(), 'retained old preview database');
  });

  test('普通图片草稿仍可恢复，删除目标不触及旧批次目录', () async {
    final root = await Directory.systemTemp.createTemp('wenyou-retired-media-');
    addTearDown(() => root.delete(recursive: true));
    final old = File(
      '${root.path}/preview_aaaaaaaaaaaaaaaaaaaaaaaa.pending-media-v1/retained.json',
    );
    await old.parent.create(recursive: true);
    await old.writeAsString('retained old image draft');
    final store = PrivatePendingMediaFileStore(rootDirectory: root);
    await store.write(
      accountId: 'same-user',
      target: 'same-target',
      payload: {'text': 'existing image draft'},
    );
    final reopened = PrivatePendingMediaFileStore(rootDirectory: root);
    expect(await reopened.read(accountId: 'same-user', target: 'same-target'), {
      'text': 'existing image draft',
    });
    await reopened.delete(accountId: 'same-user', target: 'same-target');
    expect(await old.readAsString(), 'retained old image draft');
  });
}
