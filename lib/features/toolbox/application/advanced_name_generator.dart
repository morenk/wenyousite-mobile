import 'dart:math';

import 'package:wenyousite_mobile/features/toolbox/application/advanced_name_catalog.dart';
import 'package:wenyousite_mobile/features/toolbox/application/name_generator.dart';

class AdvancedNameOptions {
  const AdvancedNameOptions({
    required this.country,
    required this.mode,
    required this.styleId,
    required this.structureId,
    this.sex = 'any',
    this.count = 10,
  });

  final String country;
  final String mode;
  final String styleId;
  final String structureId;
  final String sex;
  final num count;
}

class GeneratedAdvancedName extends GeneratedName {
  const GeneratedAdvancedName({
    required super.original,
    required super.zh,
    required this.styleId,
    required this.structureId,
    required this.sex,
    required this.familyId,
    required this.givenId,
    this.secondGivenId,
    this.patronymicId,
    this.bynameId,
  });

  final String styleId;
  final String structureId;
  final String sex;
  final String familyId;
  final String givenId;
  final String? secondGivenId;
  final String? patronymicId;
  final String? bynameId;

  Map<String, Object?> toJson() => {
    'original': original,
    'zh': zh,
    'styleId': styleId,
    'structureId': structureId,
    'sex': sex,
    'familyId': familyId,
    'givenId': givenId,
    if (secondGivenId != null) 'secondGivenId': secondGivenId,
    if (patronymicId != null) 'patronymicId': patronymicId,
    if (bynameId != null) 'bynameId': bynameId,
  };
}

class AdvancedNameGenerator {
  AdvancedNameGenerator({AdvancedNameCatalog? catalog})
    : catalog = catalog ?? AdvancedNameCatalog();

  final AdvancedNameCatalog catalog;

  List<GeneratedAdvancedName> generate(
    AdvancedNameOptions options, {
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
    if (!const ['historical', 'literary'].contains(options.mode)) {
      throw const FormatException('请选择有效的起名类型');
    }
    final style = catalog.style(options.styleId);
    if (style == null ||
        style.country != options.country ||
        style.mode != options.mode) {
      throw const FormatException('请选择有效的起名风格');
    }
    final structure = style.structure(options.structureId);
    if (structure == null) {
      throw const FormatException('请选择当前风格支持的姓名结构');
    }
    final next = random ?? Random().nextDouble;
    T pick<T>(List<T> items) => items[(next() * items.length).floor()];
    final results = <String, GeneratedAdvancedName>{};
    for (
      var attempt = 0;
      results.length < options.count && attempt < options.count * 40;
      attempt++
    ) {
      final sex = options.sex == 'any'
          ? (next() < 0.5 ? 'female' : 'male')
          : options.sex;
      final family = pick(style.families);
      final givenPool = style.given[sex]!;
      final given = pick(givenPool);
      final secondGiven = structure.uses('secondGiven')
          ? pick(
              givenPool
                  .where((part) => part.original != given.original)
                  .toList(),
            )
          : null;
      final patronymic = structure.uses('patronymic')
          ? pick(style.patronymics)
          : null;
      final byname = structure.uses('byname')
          ? pick(style.bynames[sex]!)
          : null;
      final parts = <String, GeneratedName>{
        'family': family.forSex(sex),
        'given': given,
        'secondGiven': ?secondGiven,
        if (patronymic != null) 'patronymic': patronymic.forSex(sex),
        'byname': ?byname,
      };
      String render(String template, {required bool chinese}) =>
          template.replaceAllMapped(RegExp(r'\{(\w+)\}'), (match) {
            final part = parts[match[1]]!;
            return chinese ? part.zh : part.original;
          });
      final name = GeneratedAdvancedName(
        original: render(structure.originalTemplate, chinese: false),
        zh: render(structure.zhTemplate, chinese: true),
        styleId: style.id,
        structureId: structure.id,
        sex: sex,
        familyId: family.id,
        givenId: given.id,
        secondGivenId: secondGiven?.id,
        patronymicId: patronymic?.id,
        bynameId: byname?.id,
      );
      results.putIfAbsent(name.original, () => name);
    }
    return results.values.toList();
  }
}
