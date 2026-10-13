import 'dart:math';

import 'package:wenyousite_mobile/features/toolbox/application/historical_name_catalog.dart';
import 'package:wenyousite_mobile/features/toolbox/application/name_generator.dart';

class HistoricalNameOptions {
  const HistoricalNameOptions({
    required this.country,
    required this.profileId,
    this.role = 'period',
    this.familyId = '',
    this.sex = 'any',
    this.count = 10,
    this.includePatronymic = false,
  });
  final String country;
  final String profileId;
  final String role;
  final String familyId;
  final String sex;
  final num count;
  final bool includePatronymic;
}

class GeneratedHistoricalName extends GeneratedName {
  const GeneratedHistoricalName({
    required super.original,
    required super.zh,
    required this.profileId,
    required this.sex,
    required this.familyId,
    required this.givenId,
    this.patronymicId,
  });
  final String profileId;
  final String sex;
  final String familyId;
  final String givenId;
  final String? patronymicId;
  Map<String, Object?> toJson() => {
    'original': original,
    'zh': zh,
    'profileId': profileId,
    'sex': sex,
    'familyId': familyId,
    'givenId': givenId,
    if (patronymicId != null) 'patronymicId': patronymicId,
  };
}

class HistoricalNameGenerator {
  HistoricalNameGenerator({HistoricalNameCatalog? catalog})
    : catalog = catalog ?? HistoricalNameCatalog();
  final HistoricalNameCatalog catalog;

  List<GeneratedHistoricalName> generate(
    HistoricalNameOptions options, {
    double Function()? random,
  }) {
    if (!options.count.isFinite ||
        options.count < 1 ||
        options.count > 50 ||
        options.count != options.count.truncate()) {
      throw const FormatException('生成数量须为 1–50 的整数');
    }
    if (!const ['any', 'female', 'male'].contains(options.sex)) {
      throw const FormatException('请选择有效的名字性别倾向');
    }
    final profile = catalog.profile(options.profileId);
    if (profile == null || profile.country != options.country) {
      throw const FormatException('请选择有效的时代与地区');
    }
    final role = profile.role(options.role);
    if (role == null) throw const FormatException('该时代没有此类姓名');
    if (options.familyId.isNotEmpty &&
        !role.familyIds.contains(options.familyId)) {
      throw const FormatException('请选择当前时代收录的姓氏');
    }
    if (options.includePatronymic && profile.patronymics.isEmpty) {
      throw const FormatException('该时代不支持父称');
    }
    final families = profile.familiesFor(role);
    final next = random ?? Random().nextDouble;
    T pick<T>(List<T> items) => items[(next() * items.length).floor()];
    final results = <String, GeneratedHistoricalName>{};
    for (
      var attempt = 0;
      results.length < options.count && attempt < options.count * 40;
      attempt++
    ) {
      final sex = options.sex == 'any'
          ? (next() < 0.5 ? 'female' : 'male')
          : options.sex;
      final family = options.familyId.isEmpty
          ? pick(families)
          : families.firstWhere((family) => family.id == options.familyId);
      final given = pick(profile.given[sex]!);
      final patronymic = options.includePatronymic
          ? pick(profile.patronymics)
          : null;
      final parts = <String, GeneratedName>{
        'family': family.forSex(sex),
        'given': given,
        if (patronymic != null) 'patronymic': patronymic.forSex(sex),
      };
      final ordered = [
        for (final key in profile.namePattern)
          if (parts[key] != null) parts[key]!,
      ];
      final name = GeneratedHistoricalName(
        original: ordered
            .map((part) => part.original)
            .join(profile.originalSeparator),
        zh: ordered.map((part) => part.zh).join(profile.zhSeparator),
        profileId: profile.id,
        sex: sex,
        familyId: family.id,
        givenId: given.id,
        patronymicId: patronymic?.id,
      );
      // 同名保留首次抽中的家系、性别和父称元数据。
      results.putIfAbsent(name.original, () => name);
    }
    return results.values.toList();
  }
}
