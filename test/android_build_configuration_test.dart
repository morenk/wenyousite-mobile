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
}
