import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'font_format_probe.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('离线后端字体产物真实引擎加载与绘制', () async {
    const root = String.fromEnvironment('FONT_PROBE_ROOT');
    const manifestPath = String.fromEnvironment('FONT_PROBE_MANIFEST');
    const manifestSha = String.fromEnvironment('FONT_PROBE_MANIFEST_SHA256');
    const revision = String.fromEnvironment('FONT_PROBE_BACKEND_SHA');
    const output = String.fromEnvironment('FONT_PROBE_OUTPUT');
    if (root.isEmpty ||
        output.isEmpty ||
        !RegExp(r'^[a-f0-9]{40}$').hasMatch(revision)) {
      throw const FormatException('必须指定输入目录、输出目录和完整 Backend SHA');
    }
    final bytes = await readLockedFontFile(root, manifestPath, manifestSha);
    final manifest = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    expect(manifest['schemaVersion'], 1);
    expect(manifest['backendRevision'], revision);
    expect(
      manifest['evidenceKind'],
      isIn(['backend-artifacts', 'harness-self-check']),
    );
    final samples = (manifest['samples'] as List).cast<Map<String, dynamic>>();
    expect(samples, isNotEmpty);
    final controls = await loadProbeControls();
    final results = <Map<String, Object?>>[];
    final ids = <String>{};
    final destination = Directory(output);
    if (destination.existsSync() && destination.listSync().isNotEmpty) {
      throw const FormatException('输出目录必须为空，避免旧证据混入本轮结果');
    }
    await destination.create(recursive: true);
    try {
      for (final sample in samples) {
        final id = sample['id'] as String;
        if (!RegExp(r'^[a-z0-9-]{1,80}$').hasMatch(id) || !ids.add(id)) {
          throw const FormatException('样本 ID 非法或重复');
        }
        final font = await readLockedFontFile(
          root,
          sample['file'] as String,
          sample['sha256'] as String,
        );
        final tables = inspectFontTables(
          font,
          outline: sample['outline'] as String,
          defaultInstance: sample['defaultInstance'] as bool,
        );
        final family = 'WenyouProbe-$id-${sample['sha256']}';
        await loadProbeFont(family, font);
        final rendered = await verifyProbeRendering(
          family: family,
          text: sample['text'] as String,
          fallbackA: controls.keys.first,
          fallbackB: controls.keys.last,
        );
        await File(p.join(output, '$id.png')).writeAsBytes(rendered.png);
        results.add({
          ...sample,
          'status': 'passed',
          'tables': tables.toList()..sort(),
          'pngSha256': sha256.convert(rendered.png).toString(),
          'pixelSha256': rendered.pixelSha,
          'inkPixels': rendered.inkPixels,
          'lineWidth': rendered.width,
        });
      }
    } finally {
      await File(p.join(destination.path, 'result.json')).writeAsString(
        const JsonEncoder.withIndent('  ').convert({
          'backendRevision': revision,
          'evidenceKind': manifest['evidenceKind'],
          'manifestSha256': manifestSha,
          'engineExecutable': Platform.resolvedExecutable,
          'controls': controls,
          'complete': results.length == samples.length,
          'samples': results,
        }),
      );
    }
  }, timeout: const Timeout(Duration(minutes: 10)));
}
