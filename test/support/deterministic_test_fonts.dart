import 'dart:io';

import 'package:flutter/services.dart';

/// Loads readable, deterministic fonts for Widget and Golden tests only.
///
/// Flutter's Material baseline resolves the platform default to `Roboto` in
/// tests, while `flutter test` otherwise uses `Ahem`. Registering the same
/// subset for both test families keeps screenshots readable while production
/// source remains free of custom font-family assignments. Neither this subset
/// nor its license is declared in `pubspec.yaml`, so it cannot be bundled into
/// an application artifact.
Future<void> loadDeterministicTestFonts() async {
  await Future.wait([
    _loadFile('Ahem', File('test/support/fonts/WenyouGoldenText-Variable.ttf')),
    _loadFile(
      'Roboto',
      File('test/support/fonts/WenyouGoldenText-Variable.ttf'),
    ),
    _loadFile(
      'monospace',
      File('test/support/fonts/WenyouGoldenText-Variable.ttf'),
    ),
    _loadMaterialIcons(),
  ]);
}

Future<void> _loadFile(String family, File font) async {
  final bytes = await font.readAsBytes();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
  await loader.load();
}

Future<void> _loadMaterialIcons() async {
  final configuredRoot = Platform.environment['FLUTTER_ROOT'];
  File? font;
  if (configuredRoot != null) {
    font = File(
      '$configuredRoot/bin/cache/artifacts/material_fonts/'
      'MaterialIcons-Regular.otf',
    );
  } else {
    var directory = File(Platform.resolvedExecutable).parent;
    for (var depth = 0; depth < 10; depth++) {
      final candidate = File(
        '${directory.path}/bin/cache/artifacts/material_fonts/'
        'MaterialIcons-Regular.otf',
      );
      if (candidate.existsSync()) {
        font = candidate;
        break;
      }
      directory = directory.parent;
    }
  }
  if (font == null || !font.existsSync()) return;
  await _loadFile('MaterialIcons', font);
}
