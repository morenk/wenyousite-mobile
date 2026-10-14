import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show StringCharacters;

import 'fancy_data.g.dart';

final _catalog = _FancyCatalog();

class _FancyCatalog {
  _FancyCatalog() {
    final data = jsonDecode(fancyDataJson) as Map<String, Object?>;
    styles = List.unmodifiable(
      (data['styles']! as List<Object?>).map(
        (style) => FancyStyle._(style! as Map<String, Object?>),
      ),
    );
    categories = Map.unmodifiable({
      for (final category
          in (data['categories']! as List<Object?>)
              .cast<Map<String, Object?>>())
        category['id']! as String: category['label']! as String,
    });
    blankLineCodePoints = (data['blankLineCodePoints']! as List<Object?>)
        .cast<int>()
        .toSet();
    outputLimit = data['outputLimit']! as int;
    markLimit = data['maxMarksPerCharacter']! as int;
    LicenseRegistry.addLicense(() async* {
      yield const LicenseEntryWithLineBreaks(['温油花体字数据'], fancyDataLicense);
    });
  }

  late final List<FancyStyle> styles;
  late final Map<String, String> categories;
  late final Set<int> blankLineCodePoints;
  late final int outputLimit;
  late final int markLimit;
}

Map<String, String> get fancyCategories => _catalog.categories;

class FancyStyle {
  FancyStyle._(Map<String, Object?> data)
    : id = data['id']! as String,
      label = data['label']! as String,
      category = data['category']! as String,
      preview = data['preview']! as String,
      previewInput = data['previewInput']! as String,
      _kind = data['kind']! as String,
      _mapping = (data['mapping'] as Map<String, Object?>? ?? const {})
          .cast<String, String>(),
      _reverse = data['reverse'] as bool? ?? false,
      _mark = data['mark'] as String? ?? '',
      _markPatterns = (data['markPatterns'] as List<Object?>? ?? const [])
          .cast<String>(),
      _prefix = data['prefix'] as String? ?? '',
      _suffix = data['suffix'] as String? ?? '';

  final String id;
  final String label;
  final String category;
  final String preview;
  final String previewInput;
  final String _kind;
  final Map<String, String> _mapping;
  final bool _reverse;
  final String _mark;
  final List<String> _markPatterns;
  final String _prefix;
  final String _suffix;

  static List<FancyStyle> get values => _catalog.styles;
  static FancyStyle get bold => byId('bold');

  static FancyStyle byId(String id) {
    // 保留历史 Flutter 向量中的枚举名称，不改变已提交旧样例。
    final stableId = id == 'doubleLine' ? 'double' : id;
    final style = values.where((style) => style.id == stableId).firstOrNull;
    if (style == null) throw const FormatException('请选择有效的文字样式');
    return style;
  }

  static final _ascii = RegExp(r'^[A-Za-z0-9]$');
  static final _accentedAscii = RegExp(r'^[A-Za-z]\p{M}+$', unicode: true);
  static final _line = RegExp(r'[^\r\n]+');

  String _mapGrapheme(String grapheme) {
    final mapped = _mapping[grapheme];
    if (mapped != null) return mapped;
    if (_accentedAscii.hasMatch(grapheme)) {
      return (_mapping[grapheme[0]] ?? grapheme[0]) + grapheme.substring(1);
    }
    return grapheme;
  }

  /// 输入上限由统一文字工具入口校验；每行保留原换行符与完整字符。
  String convert(String text) {
    final output = text.replaceAllMapped(_line, (match) {
      final line = match[0]!;
      if (_kind == 'wrap') {
        return line.runes.every(_catalog.blankLineCodePoints.contains)
            ? line
            : '$_prefix$line$_suffix';
      }
      var graphemes = line.characters.toList();
      if (_reverse) graphemes = graphemes.reversed.toList();
      if (_kind == 'mark') {
        return graphemes.map((char) {
          if (!_ascii.hasMatch(char)) return char;
          final mark = _markPatterns.isEmpty
              ? _mark
              : _markPatterns[char.codeUnitAt(0) % _markPatterns.length];
          return char +
              String.fromCharCodes(mark.runes.take(_catalog.markLimit));
        }).join();
      }
      return graphemes.map(_mapGrapheme).join();
    });
    if (output.length > _catalog.outputLimit) {
      throw const FormatException('生成结果超过长度上限，请缩短输入');
    }
    return output;
  }
}
