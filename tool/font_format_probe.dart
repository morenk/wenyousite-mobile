import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

/// 离线诊断工具，输入不是服务端协议，不进入应用运行时或 APK。
Future<Uint8List> readLockedFontFile(
  String root,
  String relativePath,
  String expectedSha,
) async {
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(expectedSha) ||
      p.isAbsolute(relativePath)) {
    throw const FormatException('必须提供相对路径及完整 SHA-256');
  }
  final directory = await Directory(root).resolveSymbolicLinks();
  final file = File(p.join(directory, relativePath));
  final resolved = await file.resolveSymbolicLinks();
  if (!p.isWithin(directory, resolved)) {
    throw const FormatException('字体路径越出输入目录');
  }
  final bytes = await File(resolved).readAsBytes();
  if (sha256.convert(bytes).toString() != expectedSha) {
    throw FormatException('SHA-256 不一致：$relativePath');
  }
  return bytes;
}

Set<String> inspectFontTables(
  Uint8List bytes, {
  required String outline,
  required bool defaultInstance,
}) {
  if (bytes.length < 12) throw const FormatException('SFNT 头不完整');
  final data = ByteData.sublistView(bytes);
  final signature = data.getUint32(0);
  if (signature != 0x00010000 && signature != 0x4f54544f) {
    throw const FormatException('只接受解包后的 TTF / OpenType SFNT');
  }
  final count = data.getUint16(4);
  if (count == 0 || 12 + count * 16 > bytes.length) {
    throw const FormatException('SFNT 表目录不完整');
  }
  final tables = <String>{};
  for (var index = 0; index < count; index++) {
    final offset = 12 + index * 16;
    final tag = latin1.decode(bytes.sublist(offset, offset + 4));
    final start = data.getUint32(offset + 8);
    final length = data.getUint32(offset + 12);
    if (start + length > bytes.length || !tables.add(tag)) {
      throw const FormatException('SFNT 表越界或重复');
    }
  }
  if (!{'glyf', 'CFF ', 'CFF2'}.contains(outline) ||
      !tables.contains(outline) ||
      (outline == 'glyf' ? signature != 0x00010000 : signature != 0x4f54544f)) {
    throw const FormatException('实际轮廓类型不符合清单');
  }
  if (defaultInstance && tables.contains('fvar')) {
    throw const FormatException('默认实例产物仍包含可变轴 fvar');
  }
  return tables;
}

Future<void> loadProbeFont(String family, Uint8List bytes) async {
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

class ProbeRaster {
  const ProbeRaster(this.png, this.pixelSha, this.inkPixels, this.width);
  final Uint8List png;
  final String pixelSha;
  final int inkPixels;
  final double width;
}

Future<ProbeRaster> rasterProbeText(
  String text,
  String family,
  String fallback,
) async {
  final builder =
      ui.ParagraphBuilder(
        ui.ParagraphStyle(textDirection: ui.TextDirection.ltr, fontSize: 40),
      )..pushStyle(
        ui.TextStyle(
          fontFamily: family,
          fontFamilyFallback: [fallback],
          fontSize: 40,
          color: const ui.Color(0xff000000),
        ),
      );
  builder.addText(text);
  final paragraph = builder.build()
    ..layout(const ui.ParagraphConstraints(width: 1800));
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawColor(const ui.Color(0xffffffff), ui.BlendMode.src);
  canvas.drawParagraph(paragraph, const ui.Offset(64, 64));
  final picture = recorder.endRecording();
  final image = await picture.toImage(1920, 256);
  try {
    if (paragraph.height > 128 || paragraph.longestLine > 1792) {
      throw const FormatException('样张超出离线验证画布');
    }
    final raw = (await image.toByteData())!.buffer.asUint8List();
    final png = (await image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    var ink = 0;
    for (var index = 3; index < raw.length; index += 4) {
      if (raw[index] != 0 &&
          (raw[index - 3] != 255 ||
              raw[index - 2] != 255 ||
              raw[index - 1] != 255)) {
        ink++;
      }
    }
    return ProbeRaster(
      png,
      sha256.convert(raw).toString(),
      ink,
      paragraph.longestLine,
    );
  } finally {
    image.dispose();
    picture.dispose();
    paragraph.dispose();
  }
}

/// 两套回退必须能区分每个可见字符，否则不能证明目标字体接管了字形。
Future<ProbeRaster> verifyProbeRendering({
  required String family,
  required String text,
  required String fallbackA,
  required String fallbackB,
}) async {
  if (text.trim().isEmpty || text.runes.length > 64 || text.contains('\n')) {
    throw const FormatException('探针需要 1–64 个字符的单行样张');
  }
  for (final rune in text.runes.toSet()) {
    final character = String.fromCharCode(rune);
    if (character.trim().isEmpty) continue;
    final controlA = await rasterProbeText(character, fallbackA, fallbackA);
    final controlB = await rasterProbeText(character, fallbackB, fallbackB);
    if (controlA.pixelSha == controlB.pixelSha) {
      throw FormatException('回退对照无法区分 U+${rune.toRadixString(16)}');
    }
    final actualA = await rasterProbeText(character, family, fallbackA);
    final actualB = await rasterProbeText(character, family, fallbackB);
    final absentA = await rasterProbeText(
      character,
      'WenyouProbeUnregistered-$family',
      fallbackA,
    );
    final absentB = await rasterProbeText(
      character,
      'WenyouProbeUnregistered-$family',
      fallbackB,
    );
    if (actualA.inkPixels == 0 ||
        actualA.pixelSha != actualB.pixelSha ||
        (actualA.pixelSha == absentA.pixelSha &&
            actualB.pixelSha == absentB.pixelSha)) {
      throw FormatException('目标字体缺字或发生回退：U+${rune.toRadixString(16)}');
    }
  }
  final first = await rasterProbeText(text, family, fallbackA);
  final second = await rasterProbeText(text, family, fallbackB);
  if (first.inkPixels == 0 || first.pixelSha != second.pixelSha) {
    throw const FormatException('整行绘制为空或发生字体回退');
  }
  return first;
}

Future<Map<String, String>> loadProbeControls() async {
  var directory = File(Platform.resolvedExecutable).parent;
  File? ahem;
  for (var index = 0; index < 10; index++) {
    final candidate = File(
      p.join(directory.path, 'packages/flutter_tools/static/Ahem.ttf'),
    );
    if (candidate.existsSync()) {
      ahem = candidate;
      break;
    }
    directory = directory.parent;
  }
  if (ahem == null) throw StateError('找不到 Flutter SDK 的 Ahem 对照字体');
  final files = {
    'WenyouProbeControlA': ahem,
    'WenyouProbeControlB': File(
      'test/support/fonts/WenyouGoldenText-Variable.ttf',
    ),
  };
  final hashes = <String, String>{};
  for (final entry in files.entries) {
    final bytes = await entry.value.readAsBytes();
    await loadProbeFont(entry.key, bytes);
    hashes[entry.key] = sha256.convert(bytes).toString();
  }
  return hashes;
}
