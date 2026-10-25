// 独立生命周期实验：不使用应用旧累计预算，不属于候选运行时实现。
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';

import 'text_font_memory_vm.dart';

void main() {
  const assetRoot = String.fromEnvironment('FONT_ASSET_ROOT');
  const allAssets = bool.fromEnvironment('FONT_MEMORY_ALL');
  const coreOnly = bool.fromEnvironment('FONT_MEMORY_CORE');
  const sampleText = '温油站 春风 あいうえお アイウエオ Hello 123 é 😀';
  const mode = allAssets
      ? 'all-assets'
      : coreOnly
      ? 'core29'
      : 'typical29';
  testWidgets('固定目录同进程真实FontLoader注册、返回和销毁后的内存', (tester) async {
    if (assetRoot.isEmpty) throw StateError('必须指定已校验的本地正式资产');
    final output = Directory('.dart_tool/thread-font-native-memory')
      ..createSync(recursive: true);
    final manifest = TextFontManifest(
      File('contracts/thread-font-manifest-v1.json').readAsBytesSync(),
    );
    final registered = <String, String>{};
    var registeredBytes = 0;
    var reads = 0;
    final rows = <Map<String, Object?>>[];
    Future<void> sample(String stage) async {
      await tester.runAsync(() async {
        final vmMemory = await measureFontVmMemory();
        final process = await Process.run(
          '${Platform.environment['SystemRoot'] ?? r'C:\Windows'}/System32/WindowsPowerShell/v1.0/powershell.exe',
          [
            '-NoProfile',
            '-Command',
            'Get-Process -Id $pid | Select-Object WorkingSet64,PrivateMemorySize64,PeakWorkingSet64 | ConvertTo-Json -Compress',
          ],
        );
        if (process.exitCode != 0) throw StateError('进程内存采样失败');
        final vmInfo = await developer.Service.getInfo();
        rows.add({
          'stage': stage,
          'pid': pid,
          'rss': ProcessInfo.currentRss,
          'maxRss': ProcessInfo.maxRss,
          'os': jsonDecode(process.stdout as String),
          'registeredBytes': registeredBytes,
          'registeredAssets': registered.length,
          'reads': reads,
          'vmServiceAvailable': vmInfo.serverUri != null,
          'vmMemory': vmMemory,
        });
      });
    }

    Future<void> show(TextFontFamily font) async {
      final shards = allAssets
          ? font.shards
          : font.shards
                .where(
                  (s) =>
                      s.id == 'core' ||
                      s.id == 'original' ||
                      !coreOnly && sampleText.runes.any(s.contains),
                )
                .toList();
      for (final shard in shards) {
        if (registered.containsKey(shard.asset.hash)) continue;
        await tester.runAsync(() async {
          final data = await File(
            '$assetRoot/${shard.asset.path}',
          ).readAsBytes();
          expect(shard.asset.verifies(data), isTrue);
          final loader = FontLoader(shard.family)
            ..addFont(Future.value(ByteData.sublistView(data)));
          await loader.load();
          registered[shard.asset.hash] = shard.family;
          registeredBytes += data.length;
          reads++;
        });
      }
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              sampleText,
              style: TextStyle(
                fontFamily: registered[shards.first.asset.hash],
                fontFamilyFallback: [
                  for (final shard in shards.skip(1))
                    registered[shard.asset.hash]!,
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await tester.pumpWidget(const MaterialApp(home: Text('Warm up')));
    await tester.pumpAndSettle();
    await sample('baseline');
    for (final font in manifest.fonts.values) {
      await show(font);
      await sample('first-${font.id}');
    }
    final firstPassReads = reads;
    final firstPassBytes = registeredBytes;
    for (var cycle = 1; cycle <= 5; cycle++) {
      for (final font in manifest.fonts.values.toList().reversed) {
        await show(font);
      }
      await sample('return-all29-$cycle');
    }
    expect(reads, firstPassReads);
    expect(registeredBytes, firstPassBytes);
    await sample('return-all29');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    // 移除所有文本和Dart注册表，不能据此声称原生字体已经卸载。
    registered.clear();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await sample('widgets-and-dart-registry-dropped');
    await tester.runAsync(
      () => File('${output.path}/$mode-$pid.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert({
          'mode': mode,
          'engine': '0cd610717bde95fd88343c64f81c11ba4e5c0010',
          'platform': 'Windows flutter_tester; Android未验证',
          'nativeIsolation': '进程RSS与PrivateBytes包含Dart、引擎和字体，不单独冒充native字体分配量',
          'network': '0HTTP，本地正式资产逐个SHA校验',
          'rows': rows,
        }),
      ),
    );
  }, timeout: const Timeout(Duration(minutes: 8)));
}
