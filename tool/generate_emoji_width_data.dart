import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// 固定 Unicode 属性，避免分析器与运行时内置属性版本影响竖排宽度。
void main(List<String> args) {
  final source = Directory('contracts/toolbox');
  final manifest =
      jsonDecode(
            File('${source.path}/source-unicode-emoji.json').readAsStringSync(),
          )
          as Map<String, Object?>;
  final files = <String, String>{};
  for (final entry in (manifest['files']! as Map<String, Object?>).entries) {
    final file = File('${source.path}/${entry.key}');
    final record = entry.value! as Map<String, Object?>;
    if (sha256.convert(file.readAsBytesSync()).toString() != record['sha256']) {
      throw StateError('Unicode 数据摘要不符：${entry.key}');
    }
    files[entry.key] = file.readAsStringSync();
  }
  final ranges = <(int, int)>[];
  for (final line in const LineSplitter().convert(
    files['unicode-16.0-emoji-data.txt']!,
  )) {
    final fields = line.split('#').first.split(';');
    if (fields.length != 2 || fields[1].trim() != manifest['property']) {
      continue;
    }
    final endpoints = fields.first.trim().split('..');
    final start = int.parse(endpoints.first, radix: 16);
    final end = int.parse(endpoints.last, radix: 16);
    if (start > end || start < 0 || end > 0x10ffff) {
      throw StateError('Unicode 区间无效');
    }
    ranges.add((start, end));
  }
  ranges.sort((left, right) => left.$1.compareTo(right.$1));
  final merged = <(int, int)>[];
  for (final range in ranges) {
    if (merged.isNotEmpty && range.$1 <= merged.last.$2) {
      throw StateError('Unicode 区间重叠');
    }
    if (merged.isNotEmpty && range.$1 == merged.last.$2 + 1) {
      merged[merged.length - 1] = (merged.last.$1, range.$2);
    } else {
      merged.add(range);
    }
  }
  final count = merged.fold(0, (sum, range) => sum + range.$2 - range.$1 + 1);
  if (count != manifest['codePointCount']) {
    throw StateError('Unicode 属性码点数量不符');
  }
  final buffer = StringBuffer(
    '// GENERATED CODE - DO NOT MODIFY BY HAND.\n'
    '// Unicode ${manifest['unicodeVersion']} Extended_Pictographic ($count 码点)。\n'
    '// 来源及摘要：contracts/toolbox/source-unicode-emoji.json。\n'
    '// 由 tool/generate_emoji_width_data.dart 生成，许可随常量保留。\n\n'
    'const extendedPictographicRanges = <(int, int)>[\n',
  );
  for (final (start, end) in merged) {
    buffer.writeln(
      '  (0x${start.toRadixString(16)}, 0x${end.toRadixString(16)}),',
    );
  }
  buffer.writeln('];');
  buffer.writeln(
    "const unicodeEmojiLicense = r'''${files['LICENSE.unicode.txt']}''';",
  );
  final output = File(
    'lib/features/toolbox/application/emoji_width_data.g.dart',
  );
  final temporary = File(
    '${Directory.systemTemp.path}/wenyou-emoji-width-$pid.dart',
  )..writeAsStringSync(buffer.toString());
  try {
    final format = Process.runSync(Platform.resolvedExecutable, [
      'format',
      temporary.path,
    ]);
    if (format.exitCode != 0) throw StateError('Unicode 数据格式化失败');
    final contents = temporary.readAsStringSync();
    if (args.contains('--check')) {
      if (!output.existsSync() || output.readAsStringSync() != contents) {
        throw StateError('Unicode 宽度生成产物不同步');
      }
    } else {
      output.writeAsStringSync(contents);
    }
  } finally {
    temporary.deleteSync();
  }
  stdout.writeln(
    'Unicode ${manifest['unicodeVersion']}：$count 码点／${merged.length} 区间及许可摘要通过',
  );
}
