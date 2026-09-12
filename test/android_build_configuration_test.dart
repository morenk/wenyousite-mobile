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

  test('后台提醒只声明 specialUse 服务且划掉停止，不申请唤醒和开机恢复', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final resourceKeepRules = File(
      'android/app/src/main/res/raw/keep.xml',
    ).readAsStringSync();

    expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
    expect(manifest, contains('android.permission.FOREGROUND_SERVICE'));
    expect(
      manifest,
      contains('android.permission.FOREGROUND_SERVICE_SPECIAL_USE'),
    );
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
    expect(manifest, contains('android:foregroundServiceType="specialUse"'));
    expect(manifest, contains('android:stopWithTask="true"'));
    expect(manifest, contains('android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE'));
    expect(
      manifest,
      contains('android:name=".WenyouBackgroundReminderService"'),
    );
    expect(manifest, isNot(contains('android.permission.SYSTEM_ALERT_WINDOW')));
    expect(
      manifest,
      isNot(contains('android.permission.USE_FULL_SCREEN_INTENT')),
    );
    expect(
      manifest,
      isNot(
        contains('android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS'),
      ),
    );
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

  test('原生常驻卡片静音且与消息频道隔离，停止不支持自动重建', () {
    final service = File(
      'android/app/src/main/kotlin/site/wenyou/app/WenyouBackgroundReminderService.kt',
    ).readAsStringSync();
    final channel = File(
      'android/app/src/main/kotlin/site/wenyou/app/BackgroundExecutionChannel.kt',
    ).readAsStringSync();
    final activity = File(
      'android/app/src/main/kotlin/site/wenyou/app/MainActivity.kt',
    ).readAsStringSync();
    expect(service, contains('"wenyou_background_reminders_v1"'));
    expect(service, contains('"wenyou_messages_v1"'));
    expect(service, contains('NotificationManager.IMPORTANCE_LOW'));
    expect(service, contains('setSound(null, null)'));
    expect(service, contains('enableVibration(false)'));
    expect(service, contains('.setSilent(true)'));
    expect(service, contains('.setOngoing(true)'));
    expect(service, contains('return START_NOT_STICKY'));
    expect(service, contains('STOP_FOREGROUND_REMOVE'));
    expect(
      service,
      contains('channel.importance != NotificationManager.IMPORTANCE_NONE'),
    );
    expect(service, contains('?.isBlocked != true'));
    expect(service, contains('handler.postDelayed(this, 30_000)'));
    expect(channel, contains('Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS'));
    expect(channel, contains('if (resumed) startBeforePause()'));
    expect(
      activity.indexOf('backgroundExecutionChannel?.onPause()'),
      lessThan(activity.indexOf('super.onPause()')),
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
