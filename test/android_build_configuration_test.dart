import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Debug 构建使用独立包名避免污染正式签名更新链', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(gradle, contains('applicationId = "site.wenyou.app"'));
    expect(gradle, contains('applicationIdSuffix = ".debug"'));
    expect(gradle, contains('manifestPlaceholders["appLabel"] = "温油站 Debug"'));
    expect(manifest, contains(r'android:label="${appLabel}"'));
    expect(
      manifest,
      contains(r'android:authorities="${applicationId}.fileprovider"'),
    );
  });

  test('Profile 构建使用独立包名避免覆盖 Debug 和正式安装', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, contains('getByName("profile")'));
    expect(gradle, contains('applicationIdSuffix = ".profile"'));
    expect(gradle, contains('versionNameSuffix = "-profile"'));
    expect(
      gradle,
      contains('manifestPlaceholders["appLabel"] = "温油站 Profile"'),
    );
  });

  test('Android 诊断构建可显式 A/B 切换 Impeller 且默认保持启用', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(manifest, contains('io.flutter.embedding.android.EnableImpeller'));
    expect(manifest, contains(r'android:value="${enableImpeller}"'));
    expect(gradle, contains('gradleProperty("wenyouEnableImpeller")'));
    expect(gradle, contains('.orElse("true")'));
  });

  test('尽力后台提醒只声明通知权限且不注册前台服务', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final resourceKeepRules = File(
      'android/app/src/main/res/raw/keep.xml',
    ).readAsStringSync();

    expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
    expect(manifest, isNot(contains('android.permission.FOREGROUND_SERVICE')));
    expect(manifest, isNot(contains('android.permission.WAKE_LOCK')));
    expect(
      manifest,
      isNot(contains('android.permission.RECEIVE_BOOT_COMPLETED')),
    );
    expect(
      manifest,
      isNot(contains('android.permission.SCHEDULE_EXACT_ALARM')),
    );
    expect(manifest, isNot(contains('android.permission.USE_EXACT_ALARM')));
    expect(manifest, isNot(contains('ForegroundService')));
    expect(manifest, isNot(contains('android:foregroundServiceType')));
    expect(manifest, isNot(contains('<service')));
    expect(manifest, isNot(contains('<receiver')));
    expect(manifest, isNot(contains('WorkManager')));
    expect(gradle, contains('isCoreLibraryDesugaringEnabled = true'));
    expect(gradle, contains('coreLibraryDesugaring('));
    expect(
      File('android/app/src/main/res/drawable/ic_stat_wenyou.xml').existsSync(),
      isTrue,
    );
    expect(
      resourceKeepRules,
      contains(r'tools:keep="@drawable/ic_stat_wenyou"'),
      reason: '通知图标只由 Dart 动态引用，正式构建必须阻止资源压缩删除它。',
    );
  });

  test('Android 系统备份与设备迁移不会复制账号数据', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final legacyRules = File(
      'android/app/src/main/res/xml/backup_rules.xml',
    ).readAsStringSync();
    final extractionRules = File(
      'android/app/src/main/res/xml/data_extraction_rules.xml',
    ).readAsStringSync();

    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:fullBackupContent="@xml/backup_rules"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
    for (final domain in ['root', 'file', 'database', 'sharedpref']) {
      expect(legacyRules, contains('domain="$domain" path="."'));
      expect(extractionRules, contains('domain="$domain" path="."'));
    }
    expect(extractionRules, contains('<cloud-backup>'));
    expect(extractionRules, contains('<device-transfer>'));
  });
}
