import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/data/meta_repository.dart';
import 'package:wenyousite_mobile/features/app_shell/data/mobile_update_service.dart';
import 'package:wenyousite_mobile/features/app_shell/data/recommended_update_dismiss_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        metaRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiMetaRepositoryProvider),
        ),
        mobileUpdateServiceProvider.overrideWith(
          (ref) => ref.watch(deviceMobileUpdateServiceProvider),
        ),
        recommendedUpdateDismissStoreProvider.overrideWith(
          (ref) =>
              ref.watch(sharedPreferencesRecommendedUpdateDismissStoreProvider),
        ),
      ],
      child: const WenyouApp(),
    ),
  );
}
