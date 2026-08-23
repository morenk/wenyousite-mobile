import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('原生品牌资源与 Foundation v6.4.0 生成清单一致', () async {
    final packageConfigFile = File('.dart_tool/package_config.json');
    final packageConfig = jsonDecode(await packageConfigFile.readAsString());
    final package = (packageConfig['packages'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .singleWhere((entry) => entry['name'] == 'wenyousite_foundation');
    final packageRootValue = packageConfigFile.uri.resolve(
      package['rootUri']! as String,
    );
    final packageRoot = Uri.parse(
      packageRootValue.toString().endsWith('/')
          ? packageRootValue.toString()
          : '${packageRootValue.toString()}/',
    );
    final manifest = jsonDecode(
      await File.fromUri(
        packageRoot.resolve('brand_assets/manifest.json'),
      ).readAsString(),
    );
    expect(manifest['version'], '6.4.0');
    final hashes = (manifest['assets'] as Map<String, Object?>)
        .cast<String, String>();

    final mappings = <({String source, String target})>[
      for (final density in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'])
        (
          source: 'brand/app/android/mipmap-$density/ic_launcher.png',
          target: 'android/app/src/main/res/mipmap-$density/ic_launcher.png',
        ),
      (
        source: 'brand/app/android/adaptive/ic_launcher_background-432.png',
        target:
            'android/app/src/main/res/drawable-nodpi/ic_launcher_background.png',
      ),
      (
        source: 'brand/app/android/adaptive/ic_launcher_foreground-432.png',
        target:
            'android/app/src/main/res/drawable-nodpi/ic_launcher_foreground.png',
      ),
      (
        source: 'brand/app/apple/launch/LaunchMark-96.png',
        target: 'android/app/src/main/res/drawable-mdpi/launch_mark.png',
      ),
      (
        source: 'brand/app/apple/launch/LaunchMark-192.png',
        target: 'android/app/src/main/res/drawable-xhdpi/launch_mark.png',
      ),
      (
        source: 'brand/app/apple/launch/LaunchMark-288.png',
        target: 'android/app/src/main/res/drawable-xxhdpi/launch_mark.png',
      ),
      (
        source: 'brand/app/apple/AppIcon-1024.png',
        target:
            'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
      ),
      for (final entry in _appleLegacyMappings.entries)
        (
          source: 'brand/app/apple/legacy/${entry.value}',
          target: 'ios/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
        ),
      (
        source: 'brand/app/apple/launch/LaunchMark-96.png',
        target:
            'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png',
      ),
      (
        source: 'brand/app/apple/launch/LaunchMark-192.png',
        target:
            'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png',
      ),
      (
        source: 'brand/app/apple/launch/LaunchMark-288.png',
        target:
            'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png',
      ),
    ];

    for (final mapping in mappings) {
      final bytes = await File(mapping.target).readAsBytes();
      expect(
        sha256.convert(bytes).toString(),
        hashes[mapping.source],
        reason: mapping.target,
      );
    }
  });

  test('系统启动过渡保持纯白且应用图标声明 adaptive 与 monochrome', () async {
    final adaptive = await File(
      'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
    ).readAsString();
    final monochrome = await File(
      'android/app/src/main/res/mipmap-anydpi-v33/ic_launcher.xml',
    ).readAsString();
    final colors = await File(
      'android/app/src/main/res/values/colors.xml',
    ).readAsString();
    final launch = await File(
      'android/app/src/main/res/drawable/launch_background.xml',
    ).readAsString();
    final android12Launch = await File(
      'android/app/src/main/res/values-v31/styles.xml',
    ).readAsString();
    final iosLaunch = await File(
      'ios/Runner/Base.lproj/LaunchScreen.storyboard',
    ).readAsString();

    expect(adaptive, contains('ic_launcher_foreground'));
    expect(adaptive, contains('ic_launcher_background'));
    expect(monochrome, contains('<monochrome'));
    expect(colors, contains('#F3C6DD'));
    expect(launch, contains('@android:color/white'));
    expect(launch, isNot(contains('@drawable/launch_mark')));
    expect(android12Launch, contains('@drawable/splash_transparent'));
    expect(android12Launch, contains('@android:color/white'));
    expect(android12Launch, isNot(contains('@drawable/launch_mark')));
    expect(iosLaunch, isNot(contains('LaunchImage')));
    expect(iosLaunch, contains('red="1" green="1" blue="1" alpha="1"'));
  });
}

const _appleLegacyMappings = <String, String>{
  'Icon-App-20x20@1x.png': 'AppIcon-20.png',
  'Icon-App-20x20@2x.png': 'AppIcon-40.png',
  'Icon-App-20x20@3x.png': 'AppIcon-60.png',
  'Icon-App-29x29@1x.png': 'AppIcon-29.png',
  'Icon-App-29x29@2x.png': 'AppIcon-58.png',
  'Icon-App-29x29@3x.png': 'AppIcon-87.png',
  'Icon-App-40x40@1x.png': 'AppIcon-40.png',
  'Icon-App-40x40@2x.png': 'AppIcon-80.png',
  'Icon-App-40x40@3x.png': 'AppIcon-120.png',
  'Icon-App-60x60@2x.png': 'AppIcon-120.png',
  'Icon-App-60x60@3x.png': 'AppIcon-180.png',
  'Icon-App-76x76@1x.png': 'AppIcon-76.png',
  'Icon-App-76x76@2x.png': 'AppIcon-152.png',
  'Icon-App-83.5x83.5@2x.png': 'AppIcon-167.png',
};
