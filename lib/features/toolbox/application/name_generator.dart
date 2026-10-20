import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/features/toolbox/application/toolbox_data.g.dart';

const nameCountries = {
  'cn': '中国',
  'jp': '日本',
  'gb': '英国',
  'de': '德国',
  'fr': '法国',
  'ru': '俄国',
  'us': '美国',
  'it': '意大利',
  'es': '西班牙',
  'kr': '韩国',
  'br': '巴西',
};

enum NameSex { any, female, male }

enum NameStyle { common, classical, fantasy }

class NameOptions {
  const NameOptions({
    this.country = 'cn',
    this.sex = NameSex.any,
    this.style = NameStyle.common,
    this.surname = '',
    this.surnameZh = '',
    this.count = 10,
  });
  final String country;
  final NameSex sex;
  final NameStyle style;
  final String surname;
  final String surnameZh;
  final int count;
}

class GeneratedName {
  const GeneratedName({required this.original, required this.zh});
  factory GeneratedName.fromJson(Map<String, Object?> value) => GeneratedName(
    original: value['original']! as String,
    zh: value['zh']! as String,
  );
  final String original;
  final String zh;
  String get bilingual => original == zh ? original : '$original（$zh）';
}

class _CountryNames {
  _CountryNames(Map<String, Object?> data)
    : order = data['order']! as String,
      originalSeparator = data['originalSeparator']! as String,
      zhSeparator = data['zhSeparator']! as String,
      given = _readNames(data['given']! as Map<String, Object?>),
      family = _readNames(data['family']! as Map<String, Object?>);
  final String order;
  final String originalSeparator;
  final String zhSeparator;
  final Map<String, List<GeneratedName>> given;
  final Map<String, List<GeneratedName>> family;
  static Map<String, List<GeneratedName>> _readNames(
    Map<String, Object?> values,
  ) => {
    for (final entry in values.entries)
      entry.key: (entry.value! as List<Object?>)
          .map((item) => GeneratedName.fromJson(item! as Map<String, Object?>))
          .toList(),
  };
}

class LocalNameGenerator {
  LocalNameGenerator() {
    final bilingual = jsonDecode(bilingualNamesJson) as Map<String, Object?>;
    _countries = {
      for (final item
          in (bilingual['countries']! as Map<String, Object?>).entries)
        item.key: _CountryNames(item.value! as Map<String, Object?>),
    };
    _chinese = jsonDecode(chineseNamesJson) as Map<String, Object?>;
    _inspiration =
        (jsonDecode(nameInspirationJson) as Map<String, Object?>)['styles']!
            as Map<String, Object?>;
    _registerLicenses();
  }
  late final Map<String, _CountryNames> _countries;
  late final Map<String, Object?> _chinese;
  late final Map<String, Object?> _inspiration;
  static bool _licensesRegistered = false;

  static void _registerLicenses() {
    if (_licensesRegistered) return;
    _licensesRegistered = true;
    LicenseRegistry.addLicense(() async* {
      yield const LicenseEntryWithLineBreaks([
        '@faker-js/faker (中文姓名词库)',
      ], fakerNamesLicense);
      yield const LicenseEntryWithLineBreaks([
        '温油常用双语姓名词库',
      ], wenyouNamesLicense);
    });
  }

  String? knownSurnameZh(String country, String surname) {
    final normalized = surname.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (country == 'cn') return surname.trim();
    final data = _countries[country];
    if (data == null) return null;
    for (final names in data.family.values) {
      for (final name in names) {
        if (name.original.toLowerCase() == normalized) return name.zh;
      }
    }
    return _hanSurname.hasMatch(surname.trim()) ? surname.trim() : null;
  }

  bool needsSurnameZh(String country, String surname) =>
      country != 'cn' &&
      surname.trim().isNotEmpty &&
      knownSurnameZh(country, surname) == null;

  List<GeneratedName> generate(
    NameOptions options, {
    double Function()? random,
  }) {
    if (!nameCountries.containsKey(options.country)) {
      throw const FormatException('请选择有效的国家');
    }
    if (options.count < 1 || options.count > 50) {
      throw const FormatException('生成数量须为 1–50 的整数');
    }
    for (final (label, text) in [
      ('固定姓氏', options.surname),
      ('姓氏中文写法', options.surnameZh),
    ]) {
      if (text.length > 40 || RegExp(r'[\r\n\t]').hasMatch(text)) {
        throw FormatException('$label须为 40 字以内的单行文字');
      }
    }
    if (options.country != 'cn' && options.style != NameStyle.common) {
      throw const FormatException('古风与幻想风首版仅支持中文');
    }
    final surname = options.surname.trim();
    final known = knownSurnameZh(options.country, surname);
    final surnameZh = known ?? options.surnameZh.trim();
    if (needsSurnameZh(options.country, surname) && surnameZh.isEmpty) {
      throw const FormatException('请填写姓氏中文写法');
    }
    if (needsSurnameZh(options.country, surname) &&
        (!_chineseWriting.hasMatch(surnameZh) ||
            !_chineseSurnameCharacters.hasMatch(surnameZh))) {
      throw const FormatException('姓氏中文写法须使用汉字');
    }
    final next = random ?? Random().nextDouble;
    T pick<T>(List<T> items) => items[(next() * items.length).floor()];
    final results = <String, GeneratedName>{};
    for (
      var attempt = 0;
      results.length < options.count && attempt < options.count * 40;
      attempt++
    ) {
      final sex = options.sex == NameSex.any
          ? (next() < 0.5 ? NameSex.female : NameSex.male)
          : options.sex;
      if (options.country == 'cn') {
        final family = surname.isNotEmpty
            ? surname
            : pick(_chinesePool('family', sex));
        String given;
        if (options.style == NameStyle.common) {
          given = pick(_chinesePool('given', sex));
        } else {
          final style =
              _inspiration[options.style.name]! as Map<String, Object?>;
          given =
              pick((style['starts']! as List<Object?>).cast<String>()) +
              pick((style[sex.name]! as List<Object?>).cast<String>());
        }
        final name = '$family$given';
        results[name] = GeneratedName(original: name, zh: name);
      } else {
        final data = _countries[options.country]!;
        final family = surname.isNotEmpty
            ? GeneratedName(original: surname, zh: surnameZh)
            : pick(data.family[sex.name] ?? data.family['generic']!);
        final given = pick(data.given[sex.name] ?? data.given['generic']!);
        final parts = data.order == 'family-given'
            ? [family, given]
            : [given, family];
        final name = GeneratedName(
          original: parts
              .map((part) => part.original)
              .join(data.originalSeparator),
          zh: parts.map((part) => part.zh).join(data.zhSeparator),
        );
        results[name.original] = name;
      }
    }
    return results.values.toList();
  }

  List<String> _chinesePool(String key, NameSex sex) {
    final pool = _chinese[key]! as Map<String, Object?>;
    return ((pool[sex.name] ?? pool['generic'])! as List<Object?>)
        .cast<String>();
  }
}

final _hanSurname = RegExp(r'^\p{Script=Han}+$', unicode: true);
final _chineseWriting = RegExp(r'\p{Script=Han}', unicode: true);
final _chineseSurnameCharacters = RegExp(
  r'^[\p{Script=Han}·・\- ]+$',
  unicode: true,
);
