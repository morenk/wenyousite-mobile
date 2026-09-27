import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_notice_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update_notice.dart';

typedef _ShownNotice = ({
  MobileClientPlatform platform,
  MobileUpdateNoticeKind phase,
  int build,
});

class MobileUpdateNoticeTracker {
  MobileUpdateNoticeTracker(this._store, this._dismissStore);

  final MobileUpdateNoticeStore _store;
  final RecommendedUpdateDismissStore _dismissStore;
  final _cache = <MobileClientPlatform, MobileUpdateNoticeRecord>{};
  final _shownInProcess = <_ShownNotice>{};
  final _needsWriteRetry = <MobileClientPlatform>{};
  Future<void> _tail = Future.value();

  // 展示确认、安装观察及前后台重试串行，防止较早快照覆盖较新的已展示记录。
  Future<T> _serial<T>(Future<T> Function() action) {
    final next = _tail.then((_) => action());
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  Future<MobileUpdateNoticeRecord> _read(MobileClientPlatform platform) async =>
      _cache[platform] ??
      await _store.read(platform) ??
      const MobileUpdateNoticeRecord();

  MobileUpdateNoticeRecord _withPresentationReceipts(
    MobileClientPlatform platform,
    MobileUpdateNoticeRecord record,
  ) {
    for (final receipt in _shownInProcess) {
      if (receipt.platform == platform) {
        record = record.presented(receipt.phase, receipt.build);
      }
    }
    return record;
  }

  Future<void> _save(
    MobileClientPlatform platform,
    MobileUpdateNoticeRecord previous,
    MobileUpdateNoticeRecord next,
  ) async {
    if (_needsWriteRetry.contains(platform) ||
        jsonEncode(previous.toJson()) != jsonEncode(next.toJson())) {
      // SharedPreferences 可能先更新插件内存缓存再报告磁盘失败，
      // 因此下一次不能仅凭读取内容相同就跳过补写。
      _needsWriteRetry.add(platform);
      await _store.write(platform, next);
      _needsWriteRetry.remove(platform);
    }
    _cache[platform] = next;
  }

  Future<MobileReleaseTarget?> observeInstalled(InstalledAppInfo installed) =>
      _serial(() async {
        if (installed.platform != MobileClientPlatform.android) return null;
        final previous = await _read(installed.platform);
        final next = _withPresentationReceipts(
          installed.platform,
          previous,
        ).observe(installed);
        await _save(installed.platform, previous, next);
        if (next.pendingInstalledBuild != installed.build) return null;
        return (
          platform: installed.platform,
          build: installed.build,
          version: installed.version,
        );
      });

  Future<bool> shouldRecommend(MobileUpdateInfo update) => _serial(() async {
    if (update.isRequired) return false;
    final previous = await _read(update.platform);
    final next = _withPresentationReceipts(update.platform, previous);
    await _save(update.platform, previous, next);
    return !next.recommendedShown.contains(update.targetBuild) &&
        !await _dismissStore.isDismissed(update.platform, update.targetBuild);
  });

  bool isInstallationMigration(MobileReleaseTarget target) {
    final record = _cache[target.platform];
    return record?.pendingInstalledBuild == target.build &&
        record?.pendingFromInstallationEvidence == true;
  }

  Future<void> presented(
    MobileUpdateNoticeKind phase,
    MobileReleaseTarget target,
  ) {
    // 只有完整文案已实际呈现后调用。写入失败时本进程仍不重弹，
    // 下次观察会补写；磁盘未成功保存时不谎称跨进程记录已完成。
    _shownInProcess.add((
      platform: target.platform,
      phase: phase,
      build: target.build,
    ));
    return _serial(() async {
      final previous = await _read(target.platform);
      final next = _withPresentationReceipts(target.platform, previous);
      await _save(target.platform, previous, next);
    });
  }
}

final mobileUpdateNoticeTrackerProvider = Provider<MobileUpdateNoticeTracker>(
  (ref) => MobileUpdateNoticeTracker(
    ref.watch(mobileUpdateNoticeStoreProvider),
    ref.watch(recommendedUpdateDismissStoreProvider),
  ),
  dependencies: [
    mobileUpdateNoticeStoreProvider,
    recommendedUpdateDismissStoreProvider,
  ],
);
