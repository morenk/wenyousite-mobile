import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

export 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart'
    show RecommendedUpdateDismissStore;

class SharedPreferencesRecommendedUpdateDismissStore
    implements RecommendedUpdateDismissStore {
  static String _key(MobileClientPlatform platform) =>
      'dismissed_recommended_build_${platform.name}';

  @override
  Future<bool> isDismissed(MobileClientPlatform platform, int build) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_key(platform)) == build;
  }

  @override
  Future<void> dismiss(MobileClientPlatform platform, int build) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_key(platform), build);
  }
}

final sharedPreferencesRecommendedUpdateDismissStoreProvider =
    Provider<RecommendedUpdateDismissStore>((ref) {
      return SharedPreferencesRecommendedUpdateDismissStore();
    });
