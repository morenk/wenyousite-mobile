import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

void main() {
  const installed = InstalledAppInfo(
    platform: MobileClientPlatform.android,
    version: '0.3.0',
    build: 7,
  );

  test('最低支持构建优先生成强制更新', () {
    final update = evaluateMobileUpdate(
      installed: installed,
      policy: const MobilePlatformPolicy(
        minimumSupportedBuild: 8,
        recommendedBuild: 10,
        updateUrl: 'https://wenyou.site/app.apk',
      ),
    );

    expect(update?.kind, MobileUpdateKind.required);
    expect(update?.targetBuild, 10);
    expect(update?.updateUri, Uri.parse('https://wenyou.site/app.apk'));
  });

  test('达到最低版本但低于推荐版本时生成推荐更新', () {
    final update = evaluateMobileUpdate(
      installed: installed,
      policy: const MobilePlatformPolicy(
        minimumSupportedBuild: 7,
        recommendedBuild: 9,
        updateUrl: 'https://testflight.apple.com/join/example',
      ),
    );

    expect(update?.kind, MobileUpdateKind.recommended);
    expect(update?.targetBuild, 9);
  });

  test('推荐更新地址非 HTTPS 时不打断用户', () {
    final update = evaluateMobileUpdate(
      installed: installed,
      policy: const MobilePlatformPolicy(
        recommendedBuild: 9,
        updateUrl: 'http://example.test/app.apk',
      ),
    );

    expect(update, isNull);
  });

  test('强制更新地址缺失时仍保持门禁', () {
    final update = evaluateMobileUpdate(
      installed: installed,
      policy: const MobilePlatformPolicy(minimumSupportedBuild: 8),
    );

    expect(update?.kind, MobileUpdateKind.required);
    expect(update?.canStartUpdate, isFalse);
  });

  test('达到推荐构建后无需更新', () {
    final update = evaluateMobileUpdate(
      installed: installed,
      policy: const MobilePlatformPolicy(
        minimumSupportedBuild: 5,
        recommendedBuild: 7,
        updateUrl: 'https://wenyou.site/app.apk',
      ),
    );

    expect(update, isNull);
  });
}
