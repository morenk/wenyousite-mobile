import 'dart:convert';

import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_sentry_sender.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_structure.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

void main() {
  test('纯颜色文字计入样式数量但不采集颜色值或正文', () {
    final structure = MarkdownCodecStructure.inspect(
      Delta()
        ..insert('private-body', {'color': '#D14343'})
        ..insert('\n'),
    );
    final safe = sanitizeDiagnosticFields(structure.diagnosticFields);
    expect(safe['codecStyledRuns'], 1);
    expect(safe['codecLines'], 1);
    final serialized = jsonEncode(safe);
    expect(serialized, isNot(contains('private-body')));
    expect(serialized, isNot(contains('#D14343')));
  });

  test('无损失败只采集结构数量及固定差异类别，保留原堆栈', () async {
    final diagnostics = FailureDiagnostics();
    addTearDown(diagnostics.dispose);
    try {
      MarkdownDeltaCodec.encode(Delta()..insert('**private-body**\n'));
      fail('普通文本不能变成粗体后保存');
    } on MarkdownCodecException catch (error, stack) {
      diagnostics.capture(error, stackTrace: stack);
    }
    await diagnostics.settled;
    final fields = diagnostics.records.single.fields;
    expect(fields['diagnosticCode'], 'markdown.document_roundtrip');
    expect(fields['codecStructureVersion'], 1);
    expect(fields['codecTextUnits'], 16);
    expect(fields['codecLines'], 1);
    expect(fields['codecEmbeds'], 0);
    expect(fields['codecDifferenceLine'], 0);
    expect(fields['codecDifferenceKind'], 'inline');
    expect(fields['stackStatus'], 'captured');
    expect(diagnostics.export(), isNot(contains('private-body')));
  });

  test('分隔线混排诊断不保留节点载荷、URL、账户ID或任意属性', () async {
    final diagnostics = FailureDiagnostics();
    addTearDown(diagnostics.dispose);
    try {
      MarkdownDeltaCodec.encode(
        Delta()
          ..insert({
            MarkdownDeltaCodec.horizontalRuleEmbed: {'version': 1},
          })
          ..insert('private-body')
          ..insert({
            MarkdownDeltaCodec.imageEmbed: {
              'url': 'https://secret.invalid/?token=private-token',
              'alt': 'private-account',
            },
          })
          ..insert('\n'),
      );
      fail('分隔线必须独占一行');
    } on MarkdownCodecException catch (error, stack) {
      diagnostics.capture(error, stackTrace: stack);
    }
    await diagnostics.settled;
    final fields = diagnostics.records.single.fields;
    expect(fields['diagnosticCode'], 'markdown.divider_line');
    expect(fields['codecEmbeds'], 2);
    expect(fields['codecDividers'], 1);
    expect(fields['codecImages'], 1);
    final outgoing = jsonEncode(
      diagnosticSentryEvent(diagnostics.records.single).toJson(),
    );
    expect(outgoing, isNot(contains('private-')));
    expect(outgoing, isNot(contains('secret.invalid')));
  });

  test('已确认 Codec 类别按机器码分组，源码移动不拆分且原因不混合', () async {
    final diagnostics = FailureDiagnostics();
    addTearDown(diagnostics.dispose);
    for (final item in [
      ('分隔线必须独占一行', 100),
      ('分隔线必须独占一行', 200),
      ('正文无法安全保存，请撤销最近的格式操作', 100),
      ('未知错误', 100),
      ('未知错误', 200),
    ]) {
      diagnostics.capture(
        MarkdownCodecException(item.$1),
        stage: DiagnosticStage.encode,
        operation: DiagnosticOperation.editorEncode,
        stackTrace: StackTrace.fromString(
          '#0 x (package:wenyousite_mobile/main.dart:${item.$2}:1)',
        ),
      );
    }
    await diagnostics.settled;
    final events = diagnostics.records.reversed
        .map(diagnosticSentryEvent)
        .toList();
    expect(events[0].fingerprint, events[1].fingerprint);
    expect(events[0].fingerprint, isNot(events[2].fingerprint));
    expect(events[3].fingerprint, isNot(events[4].fingerprint));
    expect(events[0].exceptions!.single.stackTrace!.frames.single.lineNo, 100);
    expect(events[1].exceptions!.single.stackTrace!.frames.single.lineNo, 200);
  });

  test('结构诊断导入再次限制为整数与固定类别', () {
    final safe = sanitizeDiagnosticFields({
      'codecLines': 'private-body',
      'codecEmbeds': -1,
      'codecTextUnits': 100000001,
      'codecDifferenceKind': 'private-body',
      'codecDifferenceLine': 2,
      'codecDelta': {'insert': 'private-body'},
    });
    expect(safe, {'codecDifferenceLine': 2});
  });
}
