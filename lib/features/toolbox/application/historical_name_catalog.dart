import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/features/toolbox/application/historical_name_data.g.dart';
import 'package:wenyousite_mobile/features/toolbox/application/name_generator.dart';

class HistoricalPeriod {
  HistoricalPeriod(Map<String, Object?> json)
    : from = json['from']! as int,
      to = json['to']! as int;
  final int from;
  final int to;
  String get label => '$from–$to';
}

class HistoricalRole {
  HistoricalRole(Map<String, Object?> json)
    : id = json['id']! as String,
      label = json['label']! as String,
      familyIds = (json['familyIds']! as List<Object?>).cast<String>(),
      period = json['period'] == null
          ? null
          : HistoricalPeriod(json['period']! as Map<String, Object?>);
  final String id;
  final String label;
  final List<String> familyIds;
  final HistoricalPeriod? period;
  String get displayLabel => period == null
      ? label
      : '${label.replaceFirst(RegExp(r'（[^）]+）$'), '')}（${period!.label}）';
}

class HistoricalPart extends GeneratedName {
  HistoricalPart(Map<String, Object?> json)
    : id = json['id']! as String,
      super(original: json['original']! as String, zh: json['zh']! as String);
  final String id;
}

class HistoricalFamily {
  HistoricalFamily(Map<String, Object?> json)
    : id = json['id']! as String,
      forms = {
        for (final entry in (json['forms']! as Map<String, Object?>).entries)
          entry.key: GeneratedName.fromJson(
            entry.value! as Map<String, Object?>,
          ),
      },
      lineageLabel =
          (json['lineage'] as Map<String, Object?>?)?['label'] as String?;
  final String id;
  final Map<String, GeneratedName> forms;
  final String? lineageLabel;
  GeneratedName forSex(String sex) => forms[sex] ?? forms['generic']!;

  String displayLabel(NameSex sex, {required bool lineage}) {
    if (lineage) return lineageLabel!;
    if (sex == NameSex.any && forms['generic'] == null) {
      return '${forms['male']!.zh} / ${forms['female']!.zh}';
    }
    return forSex(sex.name).bilingual;
  }
}

class HistoricalPatronymic {
  HistoricalPatronymic(Map<String, Object?> json)
    : id = json['id']! as String,
      male = GeneratedName.fromJson(json['male']! as Map<String, Object?>),
      female = GeneratedName.fromJson(json['female']! as Map<String, Object?>);
  final String id;
  final GeneratedName male;
  final GeneratedName female;
  GeneratedName forSex(String sex) => sex == 'female' ? female : male;
}

class HistoricalProfile {
  HistoricalProfile(Map<String, Object?> json)
    : id = json['id']! as String,
      country = json['country']! as String,
      label = json['label']! as String,
      region = json['region']! as String,
      period = HistoricalPeriod(json['period']! as Map<String, Object?>),
      namePattern = (json['namePattern']! as List<Object?>).cast<String>(),
      originalSeparator = json['originalSeparator']! as String,
      zhSeparator = json['zhSeparator']! as String,
      given = {
        for (final entry in (json['given']! as Map<String, Object?>).entries)
          entry.key: (entry.value! as List<Object?>)
              .map((part) => HistoricalPart(part! as Map<String, Object?>))
              .toList(),
      },
      families = (json['families']! as List<Object?>)
          .map((item) => HistoricalFamily(item! as Map<String, Object?>))
          .toList(),
      roles = (json['roles']! as List<Object?>)
          .map((item) => HistoricalRole(item! as Map<String, Object?>))
          .toList(),
      patronymics = ((json['patronymics'] ?? []) as List<Object?>)
          .map((item) => HistoricalPatronymic(item! as Map<String, Object?>))
          .toList();
  final String id;
  final String country;
  final String label;
  final String region;
  final HistoricalPeriod period;
  final List<String> namePattern;
  final String originalSeparator;
  final String zhSeparator;
  final Map<String, List<HistoricalPart>> given;
  final List<HistoricalFamily> families;
  final List<HistoricalRole> roles;
  final List<HistoricalPatronymic> patronymics;

  HistoricalRole? role(String id) =>
      roles.where((role) => role.id == id).firstOrNull;
  List<HistoricalFamily> familiesFor(HistoricalRole role) => [
    for (final id in role.familyIds)
      families.firstWhere((family) => family.id == id),
  ];

  String activeSummary(HistoricalRole role) {
    // 家系的确证年代可能比整包更窄，不能沿用标题中的完整时段。
    final title = label.replaceFirst(RegExp(r'（[^）]+）$'), '');
    final roleTitle = role.label.replaceFirst(RegExp(r'（[^）]+）$'), '');
    return '$title · $roleTitle（${(role.period ?? period).label}）';
  }
}

class HistoricalNameCatalog {
  HistoricalNameCatalog() {
    final data = jsonDecode(historicalNamesJson) as Map<String, Object?>;
    profiles = (data['profiles']! as List<Object?>)
        .map((item) => HistoricalProfile(item! as Map<String, Object?>))
        .toList();
    if (!_licenseRegistered) {
      _licenseRegistered = true;
      LicenseRegistry.addLicense(() async* {
        yield const LicenseEntryWithLineBreaks([
          '温油历史姓名参考数据',
        ], historicalNamesLicense);
      });
    }
  }
  static bool _licenseRegistered = false;
  late final List<HistoricalProfile> profiles;
  List<HistoricalProfile> forCountry(String country) =>
      profiles.where((profile) => profile.country == country).toList();
  HistoricalProfile? profile(String id) =>
      profiles.where((profile) => profile.id == id).firstOrNull;
}
