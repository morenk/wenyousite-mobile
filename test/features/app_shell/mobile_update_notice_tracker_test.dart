import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_notice_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_notice_tracker.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update_notice.dart';

const _android = MobileClientPlatform.android;
final _first = DateTime.utc(2026, 1, 1);

InstalledAppInfo _installed(
  int build, {
  bool replacement = false,
  bool times = true,
}) => InstalledAppInfo(
  platform: _android,
  version: '0.8.$build',
  build: build,
  firstInstallTime: times ? _first : null,
  lastUpdateTime: times
      ? _first.add(Duration(days: replacement ? 1 : 0))
      : null,
);

MobileUpdateInfo _update(int target, {bool required = false}) =>
    MobileUpdateInfo(
      kind: required ? MobileUpdateKind.required : MobileUpdateKind.recommended,
      platform: _android,
      currentVersion: '0.8.90',
      currentBuild: 90,
      targetBuild: target,
      targetVersion: '0.8.$target',
    );

class _Store implements MobileUpdateNoticeStore {
  final records = <MobileClientPlatform, MobileUpdateNoticeRecord>{};
  bool failRead = false;
  bool failWrite = false;
  bool cacheBeforeResult = false;
  Completer<void>? writing;
  int writes = 0;

  @override
  Future<MobileUpdateNoticeRecord?> read(MobileClientPlatform platform) async {
    if (failRead) throw StateError('read failed');
    return records[platform];
  }

  @override
  Future<void> write(
    MobileClientPlatform platform,
    MobileUpdateNoticeRecord record,
  ) async {
    writes++;
    await writing?.future;
    if (cacheBeforeResult) records[platform] = record;
    if (failWrite) throw StateError('write failed');
    records[platform] = record;
  }
}

class _Dismiss implements RecommendedUpdateDismissStore {
  int? build;
  @override
  Future<bool> isDismissed(
    MobileClientPlatform platform,
    int candidate,
  ) async => build == candidate;
  @override
  Future<void> dismiss(MobileClientPlatform platform, int value) async =>
      build = value;
}

void main() {
  late _Store store;
  late _Dismiss dismiss;
  late MobileUpdateNoticeTracker tracker;
  setUp(() {
    store = _Store();
    dismiss = _Dismiss();
    tracker = MobileUpdateNoticeTracker(store, dismiss);
  });

  test('首次安装与安装证据缺失只建立基线', () async {
    expect(await tracker.observeInstalled(_installed(97)), isNull);
    expect(store.records[_android]!.lastInstalledBuild, 97);
    final other = _Store();
    expect(
      await MobileUpdateNoticeTracker(
        other,
        dismiss,
      ).observeInstalled(_installed(97, times: false)),
      isNull,
    );
  });

  test('插件先更新内存再报告落盘失败时，相同内容仍必须补写', () async {
    store
      ..cacheBeforeResult = true
      ..failWrite = true;
    await expectLater(
      tracker.observeInstalled(_installed(97)),
      throwsStateError,
    );
    expect(store.records[_android]!.lastInstalledBuild, 97);
    expect(store.writes, 1);
    store.failWrite = false;
    expect(await tracker.observeInstalled(_installed(97)), isNull);
    expect(store.writes, 2);
    final target = await tracker.observeInstalled(_installed(100));
    store.failWrite = true;
    await expectLater(
      tracker.presented(MobileUpdateNoticeKind.afterUpdate, target!),
      throwsStateError,
    );
    final writes = store.writes;
    store.failWrite = false;
    expect(await tracker.observeInstalled(_installed(100)), isNull);
    expect(store.writes, writes + 1);
  });

  test('首次迁移以覆盖安装证据提示当前版，不推断旧build；失败重启仍待展示', () async {
    final target = await tracker.observeInstalled(
      _installed(97, replacement: true),
    );
    expect(target, (platform: _android, build: 97, version: '0.8.97'));
    expect(tracker.isInstallationMigration(target!), isTrue);
    expect(store.records[_android]!.installedShown, isEmpty);
    tracker = MobileUpdateNoticeTracker(store, dismiss);
    expect(
      await tracker.observeInstalled(_installed(97, replacement: true)),
      target,
    );
    expect(tracker.isInstallationMigration(target), isTrue);
    await tracker.presented(MobileUpdateNoticeKind.afterUpdate, target);
    tracker = MobileUpdateNoticeTracker(store, dismiss);
    expect(
      await tracker.observeInstalled(_installed(97, replacement: true)),
      isNull,
    );
  });

  test('已有基线的跨版本升级仅提示实际安装版，同build与文案修订不重弹', () async {
    await tracker.observeInstalled(_installed(90));
    final target = await tracker.observeInstalled(
      _installed(103, replacement: true),
    );
    expect(target!.build, 103);
    expect(tracker.isInstallationMigration(target), isFalse);
    await tracker.presented(MobileUpdateNoticeKind.afterUpdate, target);
    expect(
      await tracker.observeInstalled(
        const InstalledAppInfo(
          platform: _android,
          version: 'renamed',
          build: 103,
        ),
      ),
      isNull,
    );
    expect(store.records[_android]!.installedShown, {103});
  });

  test('降级不提示或遗留更高版本说明，已展示build重新安装不重弹', () async {
    await tracker.observeInstalled(_installed(97));
    final target = await tracker.observeInstalled(_installed(100));
    await tracker.presented(MobileUpdateNoticeKind.afterUpdate, target!);
    expect(await tracker.observeInstalled(_installed(90)), isNull);
    expect(await tracker.observeInstalled(_installed(100)), isNull);
  });

  test('新的安装身份不把备份中的旧build当作本次升级', () async {
    await tracker.observeInstalled(_installed(90));
    final freshTime = _first.add(const Duration(days: 30));
    expect(
      await tracker.observeInstalled(
        InstalledAppInfo(
          platform: _android,
          version: '0.8.100',
          build: 100,
          firstInstallTime: freshTime,
          lastUpdateTime: freshTime,
        ),
      ),
      isNull,
    );
  });

  test('旧ignore记录仍生效；推荐与升级后按独立phase去重', () async {
    dismiss.build = 100;
    expect(await tracker.shouldRecommend(_update(100)), isFalse);
    expect(await tracker.shouldRecommend(_update(101)), isTrue);
    await tracker.presented(MobileUpdateNoticeKind.beforeUpdate, (
      platform: _android,
      version: '0.8.101',
      build: 101,
    ));
    tracker = MobileUpdateNoticeTracker(store, dismiss);
    expect(await tracker.shouldRecommend(_update(101)), isFalse);
    expect(
      await tracker.shouldRecommend(_update(101, required: true)),
      isFalse,
    );
    final target = await tracker.observeInstalled(
      _installed(101, replacement: true),
    );
    expect(target!.build, 101);
  });

  test('读取失败不覆盖存量或写入已展示；恢复后可重试', () async {
    store.failRead = true;
    await expectLater(
      tracker.observeInstalled(_installed(97, replacement: true)),
      throwsStateError,
    );
    expect(store.writes, 0);
    store.failRead = false;
    expect(
      await tracker.observeInstalled(_installed(97, replacement: true)),
      isNotNull,
    );
  });

  test('持久化失败不重复进程内弹窗，后续观察补写呈现凭据', () async {
    final target = await tracker.observeInstalled(
      _installed(97, replacement: true),
    );
    store.failWrite = true;
    await expectLater(
      tracker.presented(MobileUpdateNoticeKind.afterUpdate, target!),
      throwsStateError,
    );
    expect(store.records[_android]!.installedShown, isEmpty);
    store.failWrite = false;
    expect(
      await tracker.observeInstalled(_installed(97, replacement: true)),
      isNull,
    );
    expect(store.records[_android]!.installedShown, {97});
  });

  test('安装观察与呈现确认串行，较早写入不能覆盖已展示', () async {
    store.writing = Completer<void>();
    final observed = tracker.observeInstalled(
      _installed(97, replacement: true),
    );
    final shown = tracker.presented(MobileUpdateNoticeKind.beforeUpdate, (
      platform: _android,
      version: '0.8.100',
      build: 100,
    ));
    await Future<void>.delayed(Duration.zero);
    expect(store.writes, 1);
    store.writing!.complete();
    await observed;
    await shown;
    expect(store.records[_android]!.lastInstalledBuild, 97);
    expect(store.records[_android]!.recommendedShown, {100});
    expect(store.records[_android]!.pendingInstalledBuild, 97);
  });
}
