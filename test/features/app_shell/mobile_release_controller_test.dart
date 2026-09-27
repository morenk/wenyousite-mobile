import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

import '../../app_shell_fixtures.dart';
import 'mobile_release_test_support.dart';

void main() {
  test('说明和当前安装版均要求平台、版本名、构建号精确一致', () {
    final release = releaseFixture();
    for (final target in [
      releaseTarget,
      (platform: MobileClientPlatform.ios, build: 100, version: '0.9.0'),
      (platform: MobileClientPlatform.android, build: 99, version: '0.9.0'),
      (platform: MobileClientPlatform.android, build: 100, version: '0.9.1'),
    ]) {
      expect(
        release.isInstalled(
          InstalledAppInfo(
            platform: target.platform,
            version: target.version,
            build: target.build,
          ),
        ),
        target == releaseTarget,
      );
      expect(
        release.matchesUpdate(
          MobileUpdateInfo(
            kind: MobileUpdateKind.recommended,
            platform: target.platform,
            currentVersion: '0.8.0',
            currentBuild: 97,
            targetBuild: target.build,
            targetVersion: target.version,
          ),
        ),
        target == releaseTarget,
      );
    }
  });

  test('错误目标说明拒绝展示，缺失保持空态，失败重试重新读取', () async {
    final repository = TestReleaseRepository();
    final container = ProviderContainer(
      overrides: [
        mobileReleaseRepositoryProvider.overrideWithValue(repository),
        mobileUpdateServiceProvider.overrideWithValue(
          AppShellTestFakeMobileUpdateService(build: 97),
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = mobileReleaseProvider(releaseTarget);
    repository.release = releaseFixture(
      target: (
        platform: MobileClientPlatform.android,
        build: 99,
        version: '0.8.0',
      ),
    );
    container.listen(provider, (_, _) {});
    await expectLater(
      container.read(provider.future),
      throwsA(isA<ApiFailure>()),
    );
    repository.release = null;
    expect(await container.refresh(provider.future), isNull);
    repository.detailError = StateError('offline');
    await expectLater(container.refresh(provider.future), throwsStateError);
    repository.detailError = null;
    repository.release = releaseFixture();
    expect(await container.refresh(provider.future), repository.release);
    expect(repository.detailCalls, 4);
  });

  test('分页保留不透明游标、按build倒序去重，失败重试不丢已有页', () async {
    final repository = TestReleaseRepository();
    var failNext = true;
    repository.onPage = (cursor) async {
      if (cursor == null) {
        return MobileReleasePage(
          items: [releaseFixture()],
          nextCursor: 'opaque+/=',
        );
      }
      if (failNext) {
        failNext = false;
        throw StateError('offline');
      }
      return MobileReleasePage(
        items: [
          releaseFixture(),
          releaseFixture(
            target: (
              platform: MobileClientPlatform.android,
              build: 98,
              version: '0.8.0',
            ),
          ),
        ],
      );
    };
    final container = ProviderContainer(
      overrides: [
        mobileReleaseRepositoryProvider.overrideWithValue(repository),
        mobileUpdateServiceProvider.overrideWithValue(
          AppShellTestFakeMobileUpdateService(build: 97),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(mobileReleaseHistoryProvider, (_, _) {});
    await pumpEventQueue();
    final controller = container.read(mobileReleaseHistoryProvider.notifier);
    await controller.loadMore();
    expect(container.read(mobileReleaseHistoryProvider).failed, isTrue);
    expect(container.read(mobileReleaseHistoryProvider).items, hasLength(1));
    await controller.loadMore();
    expect(repository.cursors, [null, 'opaque+/=', 'opaque+/=']);
    expect(
      container
          .read(mobileReleaseHistoryProvider)
          .items
          .map((e) => e.target.build),
      [100, 98],
    );
    expect(container.read(mobileReleaseHistoryProvider).nextCursor, isNull);
  });

  test('无效游标重新读取首页；迟到分页不能覆盖刷新', () async {
    final repository = TestReleaseRepository();
    repository.onPage = (cursor) async {
      if (cursor != null) throw const ApiFailure(businessCode: 40007);
      return MobileReleasePage(items: [releaseFixture()], nextCursor: 'cursor');
    };
    final container = ProviderContainer(
      overrides: [
        mobileReleaseRepositoryProvider.overrideWithValue(repository),
        mobileUpdateServiceProvider.overrideWithValue(
          AppShellTestFakeMobileUpdateService(build: 97),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(mobileReleaseHistoryProvider, (_, _) {});
    await pumpEventQueue();
    final controller = container.read(mobileReleaseHistoryProvider.notifier);
    await controller.loadMore();
    expect(repository.cursors, [null, 'cursor', null]);
    final pending = Completer<MobileReleasePage>();
    repository.onPage = (cursor) => cursor == null
        ? Future.value(const MobileReleasePage(items: []))
        : pending.future;
    final loading = controller.loadMore();
    await controller.refresh();
    pending.complete(MobileReleasePage(items: [releaseFixture()]));
    await loading;
    expect(container.read(mobileReleaseHistoryProvider).items, isEmpty);
  });

  test('手动刷新期间及失败后保留已读记录和游标', () async {
    final repository = TestReleaseRepository()
      ..onPage = (_) async =>
          MobileReleasePage(items: [releaseFixture()], nextCursor: 'next');
    final container = ProviderContainer(
      overrides: [
        mobileReleaseRepositoryProvider.overrideWithValue(repository),
        mobileUpdateServiceProvider.overrideWithValue(
          AppShellTestFakeMobileUpdateService(build: 97),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(mobileReleaseHistoryProvider, (_, _) {});
    await pumpEventQueue();
    final pending = Completer<MobileReleasePage>();
    repository.onPage = (_) => pending.future;
    final refreshing = container
        .read(mobileReleaseHistoryProvider.notifier)
        .refresh();
    expect(container.read(mobileReleaseHistoryProvider).items, hasLength(1));
    pending.completeError(StateError('offline'));
    await refreshing;
    final state = container.read(mobileReleaseHistoryProvider);
    expect(state.items, hasLength(1));
    expect(state.nextCursor, 'next');
    expect(state.failed, isTrue);
    expect(state.loadMoreFailed, isFalse);
  });
}
