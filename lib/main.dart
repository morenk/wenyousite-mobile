import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/production_overrides.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';
import 'package:wenyousite_mobile/core/application/appearance_preference.dart';
import 'package:wenyousite_mobile/core/application/background_reminder_preference.dart';
import 'package:wenyousite_mobile/core/application/data_saver_preference.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_bootstrap.dart';
import 'package:wenyousite_mobile/core/storage/shared_preferences_appearance_store.dart';
import 'package:wenyousite_mobile/core/storage/shared_preferences_background_reminder_store.dart';
import 'package:wenyousite_mobile/core/storage/shared_preferences_data_saver_store.dart';
import 'package:wenyousite_mobile/features/media/application/recovered_media_selection.dart';
import 'package:wenyousite_mobile/features/media/data/media_picker_recovery.dart';
import 'package:wenyousite_mobile/features/media/data/system_image_picker_configuration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFailureDiagnostics();
  if (wenyouFieldDiagnosticsEnabled) installWenyouDebugDiagnostics();
  configureSystemImagePicker();
  final recoveredMediaSelection = RecoveredMediaSelectionStore.fromResult(
    await recoverLostEditorMediaSelection(),
  );
  const appearanceStore = SharedPreferencesAppearanceStore();
  final initialAppearance = await loadInitialAppearancePreference(
    appearanceStore,
  );
  const dataSaverStore = SharedPreferencesDataSaverStore();
  final initialDataSaver = await loadInitialDataSaverPreference(dataSaverStore);
  const backgroundReminderStore = SharedPreferencesBackgroundReminderStore();
  final initialBackgroundReminder =
      await loadInitialBackgroundReminderPreference(backgroundReminderStore);
  runApp(
    ProviderScope(
      overrides: [
        ...productionProviderOverrides(),
        backgroundReminderPreferenceStoreProvider.overrideWithValue(
          backgroundReminderStore,
        ),
        initialBackgroundReminderPreferenceProvider.overrideWithValue(
          initialBackgroundReminder,
        ),
        appearancePreferenceStoreProvider.overrideWithValue(appearanceStore),
        dataSaverPreferenceStoreProvider.overrideWithValue(dataSaverStore),
        initialDataSaverPreferenceStateProvider.overrideWithValue(
          initialDataSaver,
        ),
        recoveredMediaSelectionStoreProvider.overrideWithValue(
          recoveredMediaSelection,
        ),
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
