import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'rich_text_behavior_projection.dart';

/// 仅显式指定已提交源码时导出回执；各测试文件独立写分片，避免并行覆盖。
class RichTextBehaviorReport {
  RichTextBehaviorReport(this.group) {
    tearDownAll(_write);
  }

  final String group;
  final observations = <BehaviorJson>[];

  void observe(
    String caseId,
    String stepId,
    String stage,
    BehaviorJson actual,
  ) {
    observations.add({
      'caseId': caseId,
      'stepId': stepId,
      'stage': stage,
      'status': 'passed',
      'actual': jsonDecode(jsonEncode(actual)),
    });
  }

  void unavailable(String caseId, String stepId, String stage, String reason) {
    observations.add({
      'caseId': caseId,
      'stepId': stepId,
      'stage': stage,
      'status': 'not-run',
      'reason': reason,
    });
  }

  void state(String caseId, String stepId, BehaviorJson actual) {
    observe(caseId, stepId, stepId == 'initial' ? 'decoded' : 'edited', actual);
    observe(caseId, stepId, 'serialized', actual);
    if (actual.containsKey('selection')) {
      observe(caseId, stepId, 'selection', actual);
    }
    if (actual.containsKey('save')) observe(caseId, stepId, 'save', actual);
  }

  void _write() {
    const revision = String.fromEnvironment('RICH_TEXT_SOURCE_REVISION');
    if (revision.isEmpty) return;
    if (!RegExp(r'^[0-9a-f]{40}$').hasMatch(revision)) {
      throw StateError('报告必须绑定完整源码提交');
    }
    final fixture = File('contracts/rich-text-behavior-v1-fixtures.json');
    final directory = Directory('.dart_tool/rich-text-behavior')
      ..createSync(recursive: true);
    File('${directory.path}/$group.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'contract': 'wenyousite-rich-text-behavior-results',
        'version': 1,
        'fixtureSha256': sha256.convert(fixture.readAsBytesSync()).toString(),
        'sourceRevision': revision,
        'platform': 'flutter',
        'environment': 'unit-editor',
        'observations': observations,
      }),
    );
  }
}
