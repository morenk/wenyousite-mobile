import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';

void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/admin-font-management-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final cases = (fixture['jobRecoveryCases'] as List)
      .cast<Map<String, dynamic>>();
  Map<String, Object?> job() => {
    'jobId': 'tfj_00000000000000000000000000000001',
    'familyId': 'tff_00000000000000000000000000000001',
    'status': 'queued',
    'sourceSha256': List.filled(64, 'a').join(),
    'sourceBytes': 12,
  };

  test('旧任务省略 submissionId 仍可解码', () {
    final result = standardSerializers.deserializeWith(
      FontJobDto.serializer,
      job(),
    )!;
    expect(result.submissionId, isNull);
    expect(result.sourceBytes, 12);
  });

  for (final row in cases.where((row) => row.containsKey('submissionId'))) {
    test('正式恢复夹具 ${row['id']} 保留任务准确绑定', () {
      final result = standardSerializers.deserializeWith(
        FontJobDto.serializer,
        {...job(), 'submissionId': row['submissionId']},
      )!;
      expect(result.submissionId, row['submissionId']);
      final encoded =
          standardSerializers.serializeWith(FontJobDto.serializer, result)
              as Map<String, dynamic>;
      expect(encoded['submissionId'], row['submissionId']);
      if (row.containsKey('expectedProcessSubmissionId')) {
        expect(result.submissionId, row['expectedProcessSubmissionId']);
        expect(result.submissionId, isNot(row['latestSubmissionId']));
      }
    });
  }
}
