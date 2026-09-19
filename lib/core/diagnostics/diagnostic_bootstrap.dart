import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_runtime.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_sentry_sender.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';

class FileDiagnosticStore implements DiagnosticStore {
  FileDiagnosticStore(this.file);
  final File file;
  @override
  Future<String?> read() async {
    if (!await file.exists()) return null;
    if (await file.length() > FailureDiagnostics.maximumBytes) {
      throw const FormatException('diagnostic store too large');
    }
    return file.readAsString();
  }

  @override
  Future<void> write(String value) async {
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(value, flush: true);
    await temporary.rename(file.path);
  }
}

Future<void> initializeFailureDiagnostics() async {
  DiagnosticStore? store;
  final fields = <String, Object?>{
    'os': Platform.operatingSystem,
    'buildMode': kReleaseMode
        ? 'release'
        : kProfileMode
        ? 'profile'
        : 'debug',
  };
  try {
    final directory = await getApplicationSupportDirectory();
    store = FileDiagnosticStore(
      File('${directory.path}/failure-diagnostics-v1.json'),
    );
  } on Object {
    // Missing/unwritable storage must not prevent the application from starting.
  }
  try {
    final info = await PackageInfo.fromPlatform();
    fields['appVersion'] = info.version;
    fields['build'] = info.buildNumber;
    fields['appPackage'] = info.packageName;
  } on Object {
    // Do not guess a version when the platform cannot provide one.
  }
  if (Platform.isAndroid) fields.addAll(await loadDiagnosticAndroidRuntime());
  final diagnostics =
      FailureDiagnostics(
          store: store,
          sender: DiagnosticSentrySender(
            const String.fromEnvironment('SENTRY_DSN'),
            enabled:
                kReleaseMode ||
                const bool.fromEnvironment('WENYOU_ENABLE_ERROR_REPORTING'),
          ),
        )
        ..environment = sanitizeDiagnosticFields(fields)
        ..lifecycle = () => WidgetsBinding.instance.lifecycleState?.name;
  FailureDiagnostics.instance = diagnostics;
  await diagnostics.initialize();
  if (store == null) {
    diagnostics.storageAvailable = false;
    diagnostics.automaticSending = false;
  }
  installFailureDiagnosticHandlers(diagnostics);
}

void installFailureDiagnosticHandlers(FailureDiagnostics diagnostics) {
  final previousFlutter = FlutterError.onError;
  FlutterError.onError = (details) {
    diagnostics.capture(
      details.exception,
      stackTrace: details.stack,
      operation: DiagnosticOperation.flutterError,
      frameworkLibrary: details.library,
    );
    if (previousFlutter != null) {
      previousFlutter(details);
    } else {
      FlutterError.presentError(details);
    }
  };
  final previousPlatform = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    diagnostics.capture(
      error,
      stackTrace: stack,
      operation: DiagnosticOperation.dartError,
    );
    return previousPlatform?.call(error, stack) ?? false;
  };
}
