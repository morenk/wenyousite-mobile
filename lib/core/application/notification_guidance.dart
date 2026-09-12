import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class NotificationGuidanceStore {
  Future<bool> readHandled();
  Future<void> writeHandled();
}

/// 设备级一次性引导，与账号、通知授权结果分开记录。
class NotificationGuidanceController {
  NotificationGuidanceController(this._store);

  final NotificationGuidanceStore _store;
  bool _attempted = false;

  Future<bool> claimAutomaticPrompt() async {
    if (_attempted) return false;
    _attempted = true;
    try {
      if (await _store.readHandled()) return false;
      // 先保存再展示，避免退出、崩溃或保存失败导致每次启动都打扰。
      await _store.writeHandled();
      return true;
    } on Object {
      // 只跳过自动引导；账号设置中的手动申请和系统设置入口仍可用。
      return false;
    }
  }
}

class _MemoryNotificationGuidanceStore implements NotificationGuidanceStore {
  bool _handled = false;
  @override
  Future<bool> readHandled() async => _handled;
  @override
  Future<void> writeHandled() async => _handled = true;
}

final notificationGuidanceStoreProvider = Provider<NotificationGuidanceStore>(
  (ref) => _MemoryNotificationGuidanceStore(),
);
final notificationGuidanceControllerProvider =
    Provider<NotificationGuidanceController>(
      (ref) => NotificationGuidanceController(
        ref.watch(notificationGuidanceStoreProvider),
      ),
    );
