import 'dart:io';
import 'package:flutter/services.dart';

Future<void> loadFoundationTestFonts() async {
  await Future.wait([
    _load(
      'Wenyou Noto Sans SC',
      'packages/wenyousite_foundation/fonts/NotoSansSC-Variable.ttf',
    ),
    _load(
      'Wenyou LXGW WenKai',
      'packages/wenyousite_foundation/fonts/LXGWWenKaiLite-Medium.ttf',
    ),
    _load(
      'Wenyou Nunito',
      'packages/wenyousite_foundation/fonts/Nunito-Variable.ttf',
    ),
    _loadMaterialIcons(),
  ]);
}

Future<void> _load(String family, String asset) async {
  final loader = FontLoader(family)..addFont(rootBundle.load(asset));
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
  final bytes = await font.readAsBytes();
  final loader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
  await loader.load();
}
