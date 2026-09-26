import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

final installedAppInfoProvider = FutureProvider.autoDispose<InstalledAppInfo>(
  (ref) => ref.watch(mobileUpdateServiceProvider).readInstalledApp(),
  dependencies: [mobileUpdateServiceProvider],
);

final mobileReleaseProvider = FutureProvider.autoDispose
    .family<MobileRelease?, MobileReleaseTarget>((ref, target) async {
      final release = await ref
          .watch(mobileReleaseRepositoryProvider)
          .fetch(target);
      // 历史记录及 APK 元数据三项精确绑定，禁止以相邻版本替代。
      if (release != null && release.target != target) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'mobile_release_target_mismatch',
        );
      }
      return release;
    }, dependencies: [mobileReleaseRepositoryProvider]);

// 历史入口独立查询可用目标；忽略横幅不影响这里，也不改变启动门禁。
final availableMobileReleaseUpdateProvider =
    FutureProvider.autoDispose<MobileUpdateInfo?>(
      (ref) async {
        final service = ref.watch(mobileUpdateServiceProvider);
        final repository = ref.watch(metaRepositoryProvider);
        if (service.platform != MobileClientPlatform.android) return null;
        final installed = await ref.watch(installedAppInfoProvider.future);
        final contract = await repository.fetch();
        final update = evaluateMobileUpdate(
          installed: installed,
          policy: contract.policyFor(installed.platform),
        );
        if (update == null || !update.canStartUpdate) return null;
        if (service is! MobileUpdateAvailabilityChecker) return null;
        final availability = await (service as MobileUpdateAvailabilityChecker)
            .checkAvailability(update);
        if (!availability.isAvailable || availability.targetVersion == null) {
          return null;
        }
        return update.withTargetVersion(availability.targetVersion);
      },
      dependencies: [
        mobileUpdateServiceProvider,
        metaRepositoryProvider,
        installedAppInfoProvider,
      ],
    );

class MobileReleaseHistoryState {
  const MobileReleaseHistoryState({
    this.items = const [],
    this.nextCursor,
    this.loading = true,
    this.loadingMore = false,
    this.failed = false,
    this.loadMoreFailed = false,
  });

  final List<MobileRelease> items;
  final String? nextCursor;
  final bool loading;
  final bool loadingMore;
  final bool failed;
  final bool loadMoreFailed;
}

class MobileReleaseHistoryController
    extends AutoDisposeNotifier<MobileReleaseHistoryState> {
  int _epoch = 0;
  bool _disposed = false;

  @override
  MobileReleaseHistoryState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _epoch++;
    });
    unawaited(Future<void>.microtask(refresh));
    return const MobileReleaseHistoryState();
  }

  Future<void> refresh() => _load();

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || state.nextCursor == null) return;
    await _load(cursor: state.nextCursor);
  }

  Future<void> _load({String? cursor}) async {
    if (_disposed) return;
    final epoch = ++_epoch;
    final previous = state;
    state = cursor == null
        ? MobileReleaseHistoryState(
            items: previous.items,
            nextCursor: previous.nextCursor,
          )
        : MobileReleaseHistoryState(
            items: previous.items,
            nextCursor: cursor,
            loading: false,
            loadingMore: true,
          );
    try {
      if (ref.read(mobileUpdateServiceProvider).platform !=
          MobileClientPlatform.android) {
        state = const MobileReleaseHistoryState(loading: false);
        return;
      }
      final page = await ref
          .read(mobileReleaseRepositoryProvider)
          .fetchPage(platform: MobileClientPlatform.android, cursor: cursor);
      if (_disposed || epoch != _epoch) return;
      if (page.items.any(
            (item) => item.target.platform != MobileClientPlatform.android,
          ) ||
          (cursor != null && page.nextCursor == cursor)) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'mobile_release_page_invalid',
        );
      }
      final byBuild = <int, MobileRelease>{
        if (cursor != null)
          for (final item in previous.items) item.target.build: item,
      };
      for (final item in page.items) {
        final existing = byBuild[item.target.build];
        if (existing != null && existing.target != item.target) {
          throw const ApiFailure.invalidResponse(
            diagnosticCode: 'mobile_release_identity_changed',
          );
        }
        if (existing == null || item.revision >= existing.revision) {
          byBuild[item.target.build] = item;
        }
      }
      final items = byBuild.values.toList()
        ..sort((a, b) => b.target.build.compareTo(a.target.build));
      state = MobileReleaseHistoryState(
        items: List.unmodifiable(items),
        nextCursor: page.nextCursor,
        loading: false,
      );
    } on Object catch (error) {
      if (_disposed || epoch != _epoch) return;
      if (cursor != null &&
          error is ApiFailure &&
          error.businessCode == 40007) {
        await refresh();
        return;
      }
      state = MobileReleaseHistoryState(
        items: previous.items,
        nextCursor: previous.nextCursor,
        loading: false,
        failed: true,
        loadMoreFailed: cursor != null,
      );
    }
  }
}

final mobileReleaseHistoryProvider =
    NotifierProvider.autoDispose<
      MobileReleaseHistoryController,
      MobileReleaseHistoryState
    >(
      MobileReleaseHistoryController.new,
      dependencies: [
        mobileReleaseRepositoryProvider,
        mobileUpdateServiceProvider,
      ],
    );
