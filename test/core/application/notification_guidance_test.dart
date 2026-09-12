import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/application/notification_guidance.dart';
import 'package:wenyousite_mobile/core/storage/shared_preferences_notification_guidance_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('设备引导只展示一次，并发、重建和跨重启不重复', () async {
    SharedPreferences.setMockInitialValues({});
    const store = SharedPreferencesNotificationGuidanceStore();
    final controller = NotificationGuidanceController(store);
    expect(
      await Future.wait([
        controller.claimAutomaticPrompt(),
        controller.claimAutomaticPrompt(),
      ]),
      [true, false],
    );
    expect(await store.readHandled(), isTrue);
    expect(
      await NotificationGuidanceController(store).claimAutomaticPrompt(),
      isFalse,
    );
  });

  for (final failRead in [true, false]) {
    test('引导${failRead ? '读取' : '保存'}失败不循环打扰', () async {
      final store = _FailingStore(failRead);
      final controller = NotificationGuidanceController(store);
      expect(await controller.claimAutomaticPrompt(), isFalse);
      expect(await controller.claimAutomaticPrompt(), isFalse);
      expect(store.reads, 1);
    });
  }
}

class _FailingStore implements NotificationGuidanceStore {
  _FailingStore(this.failRead);
  final bool failRead;
  int reads = 0;
  @override
  Future<bool> readHandled() async {
    reads++;
    if (failRead) throw StateError('read failed');
    return false;
  }

  @override
  Future<void> writeHandled() async => throw StateError('write failed');
}
