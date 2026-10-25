import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/toolbox/application/advanced_name_data.g.dart';
import 'package:wenyousite_mobile/features/toolbox/application/advanced_name_generator.dart';

void main() {
  final generator = AdvancedNameGenerator();
  final fixtures =
      jsonDecode(
            File(
              'contracts/toolbox/advanced-name-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  for (final item
      in (fixtures['cases']! as List<Object?>).cast<Map<String, Object?>>()) {
    test('进阶v2跨端固定向量 ${item['id']}', () {
      final json = item['options']! as Map<String, Object?>;
      final options = AdvancedNameOptions(
        country: json['country']! as String,
        mode: json['mode']! as String,
        styleId: json['styleId']! as String,
        structureId: json['structureId']! as String,
        sex: json['sex']! as String,
        count: json['count']! as num,
      );
      final values = (item['randomValues']! as List<Object?>).cast<num>();
      var index = 0;
      List<GeneratedAdvancedName> generate() => generator.generate(
        options,
        random: () => values[index++ % values.length].toDouble(),
      );
      if (item['error'] case final String error) {
        expect(
          generate,
          throwsA(
            isA<FormatException>().having(
              (value) => value.message,
              'message',
              error,
            ),
          ),
        );
      } else {
        expect(
          generate().map((name) => name.toJson()).toList(),
          item['expected'],
        );
      }
      expect(index, item['expectedRandomCalls']);
    });
  }

  test('六国两类风格的每种结构与性别均生成完整双语且不混结构', () {
    expect(advancedNameCountries, {'cn', 'jp', 'gb', 'fr', 'de', 'ru'});
    for (final country in advancedNameCountries) {
      for (final mode in ['historical', 'literary']) {
        final styles = generator.catalog.forCountry(country, mode);
        expect(styles, isNotEmpty, reason: '$country $mode');
        for (final style in styles) {
          expect(style.structure(style.defaultStructureId), isNotNull);
          for (final structure in style.structures) {
            for (final sex in ['female', 'male', 'any']) {
              final names = generator.generate(
                AdvancedNameOptions(
                  country: country,
                  mode: mode,
                  styleId: style.id,
                  structureId: structure.id,
                  sex: sex,
                  count: 50,
                ),
                random: Random(49).nextDouble,
              );
              expect(
                names,
                isNotEmpty,
                reason: '${style.id} ${structure.id} $sex',
              );
              expect(names.length, lessThanOrEqualTo(50));
              expect(
                names.map((name) => name.original).toSet().length,
                names.length,
              );
              for (final name in names) {
                expect(name.original.trim(), name.original);
                expect(
                  RegExp(r'\p{Script=Han}', unicode: true).hasMatch(name.zh),
                  isTrue,
                );
                expect(name.styleId, style.id);
                expect(name.structureId, structure.id);
                expect(
                  name.secondGivenId != null,
                  structure.uses('secondGiven'),
                );
                expect(name.patronymicId != null, structure.uses('patronymic'));
                expect(name.bynameId != null, structure.uses('byname'));
                final family = style.families
                    .firstWhere((part) => part.id == name.familyId)
                    .forSex(name.sex);
                expect(name.original, contains(family.original));
                expect(name.zh, contains(family.zh));
                if (name.secondGivenId != null) {
                  final pool = style.given[name.sex]!;
                  final first = pool.firstWhere(
                    (part) => part.id == name.givenId,
                  );
                  final second = pool.firstWhere(
                    (part) => part.id == name.secondGivenId,
                  );
                  expect(second.original, isNot(first.original));
                }
                if (name.patronymicId != null) {
                  final patronymic = style.patronymics
                      .firstWhere((part) => part.id == name.patronymicId)
                      .forSex(name.sex);
                  expect(name.original, contains(patronymic.original));
                  expect(name.zh, contains(patronymic.zh));
                }
              }
            }
          }
        }
      }
    }
  });

  test('最小结构只消费性别、姓、名随机值，不抽隐藏的称号或第二名', () {
    final style = generator.catalog.styles.firstWhere(
      (style) => style.structures.any(
        (structure) =>
            !structure.uses('secondGiven') &&
            !structure.uses('patronymic') &&
            !structure.uses('byname'),
      ),
    );
    final structure = style.structures.firstWhere(
      (structure) =>
          !structure.uses('secondGiven') &&
          !structure.uses('patronymic') &&
          !structure.uses('byname'),
    );
    var calls = 0;
    final names = generator.generate(
      AdvancedNameOptions(
        country: style.country,
        mode: style.mode,
        styleId: style.id,
        structureId: structure.id,
        count: 1,
      ),
      random: () {
        calls++;
        return 0;
      },
    );
    expect(names, hasLength(1));
    expect(calls, 3);
  });

  test('有限重试返回真实数量，不重复凑数', () {
    final style = generator.catalog.styles.first;
    var calls = 0;
    final names = generator.generate(
      AdvancedNameOptions(
        country: style.country,
        mode: style.mode,
        styleId: style.id,
        structureId: style.defaultStructureId,
        sex: 'male',
        count: 50,
      ),
      random: () {
        calls++;
        return 0;
      },
    );
    expect(names, hasLength(1));
    expect(calls, lessThanOrEqualTo(10000));
  });

  test('进阶参考与创作数据保留独立来源许可', () async {
    final licenses = await LicenseRegistry.licenses.toList();
    final license = licenses.singleWhere(
      (entry) => entry.packages.contains('温油进阶姓名参考与创作数据'),
    );
    final text = license.paragraphs
        .map((paragraph) => paragraph.text)
        .join('\n');
    expect(text, contains('MIT'));
    expect(text, contains('国立国会图书馆'));
    expect(text, contains('国立故宫博物院'));
  });
}
