import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/toolbox/application/name_generator.dart';

void main() {
  final shared =
      jsonDecode(
            File('contracts/toolbox/name-fixtures.json').readAsStringSync(),
          )
          as Map<String, Object?>;
  for (final item
      in (shared['cases']! as List<Object?>).cast<Map<String, Object?>>()) {
    test('Web已提交双语固定向量 ${item['id']}', () {
      final json = item['options']! as Map<String, Object?>;
      final options = NameOptions(
        country: json['country']! as String,
        sex: NameSex.values.byName(json['sex']! as String),
        style: NameStyle.values.byName(json['style']! as String),
        surname: json['surname']! as String,
        surnameZh: json['surnameZh']! as String,
        count: json['count']! as int,
      );
      final randomValues = (item['randomValues']! as List<Object?>).cast<num>();
      var index = 0;
      double random() => randomValues[index++ % randomValues.length].toDouble();
      List<GeneratedName> generate() =>
          LocalNameGenerator().generate(options, random: random);
      if (item['error'] case final String error) {
        expect(
          generate,
          throwsA(
            isA<FormatException>().having(
              (exception) => exception.message,
              'message',
              error,
            ),
          ),
        );
      } else {
        expect(
          generate()
              .map((name) => {'original': name.original, 'zh': name.zh})
              .toList(),
          item['expected'],
        );
      }
    });
  }
  test('词库仅本地解析，首个结果计时记录（非真机性能结论）', () {
    final watch = Stopwatch()..start();
    final generator = LocalNameGenerator();
    final parsed = watch.elapsedMicroseconds;
    final results = generator.generate(
      const NameOptions(country: 'gb', count: 10),
      random: Random(3).nextDouble,
    );
    final total = watch.elapsedMicroseconds;
    stdout.writeln('本机 Flutter test：词库解析 $parsed µs；解析+首次10名 $total µs');
    expect(results, hasLength(10));
  });

  test('十一国三性别均返回完整双语，无未知姓占位或重复', () {
    final generator = LocalNameGenerator();
    for (final country in nameCountries.keys) {
      for (final sex in NameSex.values) {
        final names = generator.generate(
          NameOptions(country: country, sex: sex, count: 50),
          random: Random(42).nextDouble,
        );
        expect(names, hasLength(50), reason: '$country $sex');
        expect(names.map((name) => name.original).toSet(), hasLength(50));
        for (final name in names) {
          expect(name.original.trim(), isNotEmpty);
          expect(
            RegExp(r'\p{Script=Han}', unicode: true).hasMatch(name.zh),
            isTrue,
          );
          expect(RegExp('[a-zA-Z]').hasMatch(name.zh), isFalse);
        }
      }
    }
  });

  test('日本已知汉字姓优先词库中文，未知汉字姓原样保留', () {
    final generator = LocalNameGenerator();
    expect(generator.knownSurnameZh('jp', '鈴木'), '铃木');
    expect(generator.needsSurnameZh('jp', '鈴木'), isFalse);
    final result = generator
        .generate(
          const NameOptions(
            country: 'jp',
            surname: '鈴木',
            sex: NameSex.male,
            count: 1,
          ),
          random: () => 0,
        )
        .single;
    expect(result.original.startsWith('鈴木'), isTrue);
    expect(result.zh.startsWith('铃木'), isTrue);
    expect(generator.knownSurnameZh('gb', '王'), '王');
  });

  test('自定义译姓校验与查找语义', () {
    final generator = LocalNameGenerator();
    expect(generator.knownSurnameZh('gb', ' SMITH '), '史密斯');
    for (final invalid in ['', '---', '··', 'Smith', '王Smith', '王🙂']) {
      expect(
        () => generator.generate(
          NameOptions(
            country: 'gb',
            surname: 'Unknown',
            surnameZh: invalid,
            count: 1,
          ),
        ),
        throwsFormatException,
      );
    }
    final name = generator
        .generate(
          const NameOptions(
            country: 'gb',
            surname: 'Custom',
            surnameZh: '卡斯特姆',
            count: 1,
          ),
          random: () => 0,
        )
        .single;
    expect(name.original.endsWith(' Custom'), isTrue);
    expect(name.zh.endsWith('·卡斯特姆'), isTrue);
    expect(name.bilingual, '${name.original}（${name.zh}）');
    expect(
      () => generator.generate(
        const NameOptions(country: 'gb', style: NameStyle.fantasy),
      ),
      throwsFormatException,
    );
    expect(
      () => generator.generate(const NameOptions(count: 0)),
      throwsFormatException,
    );
    expect(
      () => generator.generate(const NameOptions(count: 51)),
      throwsFormatException,
    );
  });

  test('Faker 与双语词库许可证随运行代码可访问', () async {
    LocalNameGenerator();
    final licenses = await LicenseRegistry.licenses.toList();
    expect(
      licenses.any(
        (entry) => entry.packages.contains('@faker-js/faker (中文姓名词库)'),
      ),
      isTrue,
    );
    expect(
      licenses.any((entry) => entry.packages.contains('温油常用双语姓名词库')),
      isTrue,
    );
  });

  test('源文件版本可追溯', () {
    final manifest =
        jsonDecode(File('contracts/toolbox/source.json').readAsStringSync())
            as Map<String, Object?>;
    expect(manifest['revision'], matches(RegExp(r'^[0-9a-f]{40}$')));
    expect(
      (manifest['files']! as Map<String, Object?>).keys,
      containsAll([
        'cn.json',
        'bilingual-name-data.json',
        'name-fixtures.json',
        'LICENSE.faker.txt',
      ]),
    );
  });
}
