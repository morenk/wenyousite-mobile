import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/production_overrides.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';
import 'package:wenyousite_mobile/features/media/data/system_image_picker_configuration.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (wenyouFieldDiagnosticsEnabled) installWenyouDebugDiagnostics();
  configureSystemImagePicker();
  runApp(
    ProviderScope(
      overrides: productionProviderOverrides(),
      child: const WenyouApp(
        enableDebugDiagnosticConsole: wenyouFieldDiagnosticsEnabled,
      ),
    ),
  );
}
