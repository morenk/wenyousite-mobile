import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS 静态配置保留中文品牌、相册说明和手机竖屏边界', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(
      plist,
      contains('<key>CFBundleDisplayName</key>\n\t<string>温油站</string>'),
    );
    expect(plist, contains('<key>NSPhotoLibraryUsageDescription</key>'));

    final phoneOrientations = RegExp(
      r'<key>UISupportedInterfaceOrientations</key>\s*<array>(.*?)</array>',
      dotAll: true,
    ).firstMatch(plist)?.group(1);
    expect(phoneOrientations, isNotNull);
    expect(phoneOrientations, contains('UIInterfaceOrientationPortrait'));
    expect(phoneOrientations, isNot(contains('Landscape')));

    // iOS 暂不发布：保留 iPad 模板声明，不把 Windows 静态检查表述为构建验收。
    expect(plist, contains('<key>UISupportedInterfaceOrientations~ipad</key>'));
  });
}
