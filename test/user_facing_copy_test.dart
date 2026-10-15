import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/legacy_failure_copy_audit.dart';

void main() {
  test('用户可见文案不回退到开发者视角', () {
    const forbiddenPhrases = [
      '请求 ID：',
      '没有加载完成',
      '没有完成',
      '尚未确认',
      '暂未确认',
      '不完整',
      '结果暂时无法确定',
      '结果不明确',
      '缺少管理 ID',
      '缺少记录 ID',
      '缺少主题上下文',
      '格式异常',
      '请求已经发生变化',
      '无法安全恢复',
      '联系维护者',
      '服务端草稿',
      '服务端暂未启用此能力',
      '同一份实时余额',
      '直接显示在这里',
      '集中显示在这里',
      '动态正文是纯文本，不解析 Markdown',
      '封面仅影响信息流展示',
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

  test('展示层旧失败文案访问与网络层文案构造只能收敛', () {
    var presentationUserMessageUses = 0;
    var legacyApiFailureConstructors = 0;

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      legacyApiFailureConstructors += countLegacyApiFailureCopy(source);
      final isPresentation = entity.path.contains(
        '${Platform.pathSeparator}presentation${Platform.pathSeparator}',
      );
      final isCoreWidget = entity.path.contains(
        '${Platform.pathSeparator}core${Platform.pathSeparator}'
        'widgets${Platform.pathSeparator}',
      );
      if (isPresentation || isCoreWidget) {
        presentationUserMessageUses += RegExp(
          r'\.userMessage\b',
        ).allMatches(source).length;
      }
    }

    expect(
      presentationUserMessageUses,
      lessThanOrEqualTo(105),
      reason: '展示层不得新增 ApiFailure.userMessage；请改用 UserFacingFailure。',
    );
    expect(
      legacyApiFailureConstructors,
      // d7168b61 的实际 userMessage 调用基线，包含命名工厂，禁止增长。
      lessThanOrEqualTo(418),
      reason: '不得新增带展示文案的网络失败；请改用 FailureReason 与展示映射。',
    );
  });

  test('旧失败文案审计识别普通、const、命名工厂与前缀调用', () {
    const calls = [
      "ApiFailure(userMessage: '失败')",
      "const ApiFailure(userMessage: '失败')",
      "new ApiFailure(userMessage: '失败')",
      'ApiFailure.contractViolation(userMessage: message)',
      'api.ApiFailure(userMessage: message)',
      'api.ApiFailure.contractViolation(userMessage: message)',
      "const api.ApiFailure(userMessage: '失败')",
      "const api.ApiFailure.legacy(userMessage: '失败')",
    ];
    for (final call in calls) {
      expect(countLegacyApiFailureCopy('final failure = $call;'), 1);
    }
    expect(
      countLegacyApiFailureCopy('''
class ApiFailure {
  const ApiFailure({String? userMessage});
  const ApiFailure.legacy() : this(userMessage: '失败');
}
'''),
      1,
    );
  });

  test('旧失败文案审计排除类型化错误、声明、模式、注释和字符串', () {
    expect(
      countLegacyApiFailureCopy('''
class ApiFailure {
  const ApiFailure({String? userMessage});
  const ApiFailure.typed() : this();
}
// ApiFailure(userMessage: '注释');
final text = "ApiFailure(userMessage: '字符串')";
final typed = ApiFailure(reason: FailureReason.cancelled);
final named = ApiFailure.invalidResponse(diagnosticCode: 'test');
String? read(Object failure) => switch (failure) {
  ApiFailure(userMessage: final message) => message,
  _ => null,
};
'''),
      0,
    );
  });

  test('动态发布页不回退到旧的开发提示', () {
    final source = File(
      'lib/features/moments/presentation/moment_compose_page.dart',
    ).readAsStringSync();
    for (final phrase in ['动态正文是纯文本，不解析 Markdown', '封面仅影响信息流展示', '读取最新版']) {
      expect(source, isNot(contains(phrase)));
    }
  });

  test('展示层禁止把存储标识与线上值当作用户 label', () {
    final forbiddenSinks = <RegExp>[
      RegExp(r'categoryName\s*:'),
      RegExp(
        r'(?:Text\s*\(|label\s*:|title\s*:|message\s*:|tooltip\s*:|semanticsLabel\s*:)[^\r\n;,]*(?:\.categorySlug|\.wireValue|\.slug|\.code)\b',
      ),
      RegExp(r'\$\{[^}]*\.(?:categorySlug|wireValue|slug|code)\}'),
    ];
    final violations = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File ||
          !entity.path.endsWith('.dart') ||
          (!entity.path.contains(
                '${Platform.pathSeparator}presentation${Platform.pathSeparator}',
              ) &&
              !entity.path.contains(
                '${Platform.pathSeparator}widgets${Platform.pathSeparator}',
              ))) {
        continue;
      }
      final lines = entity.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        if (forbiddenSinks.any((pattern) => pattern.hasMatch(lines[index]))) {
          violations.add('${entity.path}:${index + 1}: ${lines[index].trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          '展示文案必须使用产品 label，不得直接渲染 slug/wireValue/code：\n'
          '${violations.join('\n')}',
    );
  });
}
