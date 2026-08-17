import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('用户可见文案不回退到开发者视角', () {
    const forbiddenPhrases = [
      '请求 ID：',
      '没有加载完成',
      '没有完成',
      '尚未确认',
      '暂未确认',
      '不完整',
      '服务端草稿',
      '服务端暂未启用此能力',
      '同一份实时余额',
      '直接显示在这里',
      '集中显示在这里',
      '我的内容',
      "closed('已关闭')",
    ];
    final violations = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final phrase in forbiddenPhrases) {
        if (source.contains(phrase)) {
          violations.add('${entity.path}: $phrase');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          '请将以下文案改为用户可理解的对象、动作或失败结果：\n'
          '${violations.join('\n')}',
    );
  });
}
