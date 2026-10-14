import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/features/toolbox/application/advanced_name_data.g.dart';
import 'package:wenyousite_mobile/features/toolbox/application/historical_name_catalog.dart';

class AdvancedNameStructure {
  AdvancedNameStructure(Map<String, Object?> json)
    : id = json['id']! as String,
      label = json['label']! as String,
      originalTemplate = json['originalTemplate']! as String,
      zhTemplate = json['zhTemplate']! as String;

  final String id;
  final String label;
  final String originalTemplate;
  final String zhTemplate;

  bool uses(String part) =>
      originalTemplate.contains('{$part}') || zhTemplate.contains('{$part}');
}

class AdvancedNameStyle {
  AdvancedNameStyle(Map<String, Object?> json)
    : id = json['id']! as String,
      country = json['country']! as String,
      mode = json['mode']! as String,
      label = json['label']! as String,
      defaultStructureId = json['defaultStructureId']! as String,
      structures = (json['structures']! as List<Object?>)
          .map((item) => AdvancedNameStructure(item! as Map<String, Object?>))
          .toList(),
      given = _parts(json['given']! as Map<String, Object?>),
      families = (json['families']! as List<Object?>)
          .map((item) => HistoricalFamily(item! as Map<String, Object?>))
          .toList(),
      patronymics = ((json['patronymics'] ?? []) as List<Object?>)
          .map((item) => HistoricalPatronymic(item! as Map<String, Object?>))
          .toList(),
      bynames = _parts((json['bynames'] as Map<String, Object?>?) ?? const {});

  final String id;
  final String country;
  final String mode;
  final String label;
  final String defaultStructureId;
  final List<AdvancedNameStructure> structures;
  final Map<String, List<HistoricalPart>> given;
  final List<HistoricalFamily> families;
  final List<HistoricalPatronymic> patronymics;
  final Map<String, List<HistoricalPart>> bynames;

  static Map<String, List<HistoricalPart>> _parts(Map<String, Object?> data) =>
      {
        for (final entry in data.entries)
          entry.key: (entry.value! as List<Object?>)
              .map((part) => HistoricalPart(part! as Map<String, Object?>))
              .toList(),
      };

  AdvancedNameStructure? structure(String id) =>
      structures.where((structure) => structure.id == id).firstOrNull;
}

class AdvancedNameCatalog {
  AdvancedNameCatalog() {
    final data = jsonDecode(advancedNamesJson) as Map<String, Object?>;
    styles = (data['styles']! as List<Object?>)
        .map((item) => AdvancedNameStyle(item! as Map<String, Object?>))
        .toList();
    if (!_licenseRegistered) {
      _licenseRegistered = true;
      LicenseRegistry.addLicense(() async* {
        yield const LicenseEntryWithLineBreaks([
          '温油进阶姓名参考与创作数据',
        ], advancedNamesLicense);
      });
    }
  }

  static bool _licenseRegistered = false;
  late final List<AdvancedNameStyle> styles;
  List<AdvancedNameStyle> forCountry(String country, String mode) => styles
      .where((style) => style.country == country && style.mode == mode)
      .toList();
  AdvancedNameStyle? style(String id) =>
      styles.where((style) => style.id == id).firstOrNull;
}
