import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/toolbox/application/historical_name_data.g.dart';
import 'package:wenyousite_mobile/features/toolbox/application/historical_name_generator.dart';

void main() {
  final generator = HistoricalNameGenerator();
  final fixtures =
      jsonDecode(
            File(
              'contracts/toolbox/historical-name-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  for (final item
      in (fixtures['cases']! as List<Object?>).cast<Map<String, Object?>>()) {
    test('历史跨端固定向量 ${item['id']}', () {
      final data = item['options']! as Map<String, Object?>;
      final options = HistoricalNameOptions(
        country: data['country']! as String,
        profileId: data['profileId']! as String,
        role: data['role']! as String,
        familyId: data['familyId']! as String,
        sex: data['sex']! as String,
        count: data['count']! as num,
        includePatronymic: data['includePatronymic']! as bool,
      );
      final values = (item['randomValues']! as List<Object?>).cast<num>();
      var index = 0;
      List<GeneratedHistoricalName> generate() => generator.generate(
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
    });
  }

  test('六国十二个时期及所有角色组合有双语、按性别姓形及有限去重', () {
    expect(historicalNameCountries, {'cn', 'jp', 'gb', 'fr', 'de', 'ru'});
    expect(generator.catalog.profiles, hasLength(12));
    for (final profile in generator.catalog.profiles) {
      for (final role in profile.roles) {
        for (final sex in ['female', 'male', 'any']) {
          final names = generator.generate(
            HistoricalNameOptions(
              country: profile.country,
              profileId: profile.id,
              role: role.id,
              sex: sex,
              count: 50,
              includePatronymic: profile.patronymics.isNotEmpty,
            ),
            random: Random(42).nextDouble,
          );
          expect(names, isNotEmpty, reason: '${profile.id} ${role.id} $sex');
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
            expect(role.familyIds, contains(name.familyId));
            final family = profile.families.firstWhere(
              (item) => item.id == name.familyId,
            );
            expect(name.original, contains(family.forSex(name.sex).original));
            expect(name.zh, contains(family.forSex(name.sex).zh));
            if (name.patronymicId != null) {
              final patronymic = profile.patronymics.firstWhere(
                (item) => item.id == name.patronymicId,
              );
              expect(
                name.original,
                contains(patronymic.forSex(name.sex).original),
              );
              expect(name.zh, contains(patronymic.forSex(name.sex).zh));
            }
          }
        }
      }
    }
  });

  test('中国不开放家族模式，明治家系摘要仅显示确证的1884年后', () {
    for (final profile in generator.catalog.forCountry('cn')) {
      expect(profile.roles.map((role) => role.id), ['period']);
    }
    final meiji = generator.catalog.profile('jp-meiji')!;
    final lineage = meiji.role('lineage')!;
    expect(lineage.displayLabel, '华族家系（1884–1912）');
    expect(meiji.activeSummary(lineage), contains('1884–1912'));
    expect(meiji.activeSummary(lineage), isNot(contains('1868')));
  });

  test('随机源耗尽到有限重试后返回实际数量，不用重复凑数', () {
    var calls = 0;
    final names = generator.generate(
      const HistoricalNameOptions(
        country: 'gb',
        profileId: 'gb-tudor-england',
        sex: 'male',
        familyId: 'f6',
        count: 50,
      ),
      random: () {
        calls++;
        return 0;
      },
    );
    expect(names, hasLength(1));
    expect(calls, 2000);
  });

  test('历史词库来源署名与许可随运行代码提供', () async {
    final licenses = await LicenseRegistry.licenses.toList();
    final license = licenses.singleWhere(
      (entry) => entry.packages.contains('温油历史姓名参考数据'),
    );
    final text = license.paragraphs
        .map((paragraph) => paragraph.text)
        .join('\n');
    expect(text, contains('CC BY 4.0'));
    expect(text, contains('国立国会图书馆'));
    expect(text, contains('国立故宫博物院'));
  });
}
