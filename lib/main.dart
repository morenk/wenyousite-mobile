import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/production_overrides.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';
import 'package:wenyousite_mobile/core/application/appearance_preference.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';
import 'package:wenyousite_mobile/core/storage/shared_preferences_appearance_store.dart';
import 'package:wenyousite_mobile/features/media/data/system_image_picker_configuration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (wenyouFieldDiagnosticsEnabled) installWenyouDebugDiagnostics();
  configureSystemImagePicker();
  const appearanceStore = SharedPreferencesAppearanceStore();
  final initialAppearance = await loadInitialAppearancePreference(
    appearanceStore,
  );
  runApp(
    ProviderScope(
      overrides: [
        ...productionProviderOverrides(),
        appearancePreferenceStoreProvider.overrideWithValue(appearanceStore),
        initialAppearancePreferenceStateProvider.overrideWithValue(
          initialAppearance,
        ),
      ],
      child: const WenyouApp(
        enableDebugDiagnosticConsole: wenyouFieldDiagnosticsEnabled,
      ),
    ),
  );
}
