import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/application/notification_guidance.dart';

class SharedPreferencesNotificationGuidanceStore
    implements NotificationGuidanceStore {
  const SharedPreferencesNotificationGuidanceStore();

  static const storageKey = 'notifications.guidance.handled.v1';

  @override
  Future<bool> readHandled() async =>
      (await SharedPreferences.getInstance()).getBool(storageKey) ?? false;

  @override
  Future<void> writeHandled() async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setBool(storageKey, true)) {
      throw StateError('Cannot save notification guidance preference');
    }
  }
}
