import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/font_format_probe.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final file = File('test/support/fonts/WenyouGoldenText-Variable.ttf');

  test('锁定输入 SHA 且拒绝越界路径', () async {
    final bytes = await file.readAsBytes();
    final hash = sha256.convert(bytes).toString();
    expect(
      await readLockedFontFile(
        file.parent.path,
        file.uri.pathSegments.last,
        hash,
      ),
      bytes,
    );
    await expectLater(
      readLockedFontFile(
        file.parent.path,
        file.uri.pathSegments.last,
        '0' * 64,
      ),
      throwsFormatException,
    );
    await expectLater(
      readLockedFontFile(
        file.parent.path,
        '../deterministic_test_fonts.dart',
        hash,
      ),
      throwsFormatException,
    );
    expect(
      () => inspectFontTables(bytes, outline: 'CFF ', defaultInstance: false),
      throwsFormatException,
    );
    expect(
      () => inspectFontTables(bytes, outline: 'glyf', defaultInstance: true),
      throwsFormatException,
    );
  });

  test('真实引擎接受已知字形，未注册字体不能伪装为加载成功', () async {
    final controls = await loadProbeControls();
    await loadProbeFont('WenyouProbeSelfTest', await file.readAsBytes());
    final result = await verifyProbeRendering(
      family: 'WenyouProbeSelfTest',
      text: 'Wenyou Aa 0123',
      fallbackA: controls.keys.first,
      fallbackB: controls.keys.last,
    );
    expect(result.inkPixels, greaterThan(0));
    await expectLater(
      verifyProbeRendering(
        family: 'WenyouProbeMissingFont',
        text: 'Wenyou Aa 0123',
        fallbackA: controls.keys.first,
        fallbackB: controls.keys.last,
      ),
      throwsFormatException,
    );
    await loadProbeFont(
      'WenyouProbeLatinOnly',
      await File('test/support/fonts/WenyouGoldenLatin.ttf').readAsBytes(),
    );
    await expectLater(
      verifyProbeRendering(
        family: 'WenyouProbeLatinOnly',
        text: 'A温',
        fallbackA: controls.keys.first,
        fallbackB: controls.keys.last,
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          '缺字位置',
          contains('U+6e29'),
        ),
      ),
    );
  });
}
