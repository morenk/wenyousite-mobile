// 手动生产service/scope离线验证。夹具传输和单调时钟可控，FontLoader真实。
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_retry_ledger.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transfer_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

void main() {
  const root = String.fromEnvironment('FONT_ASSET_ROOT');
  const sourceSha = String.fromEnvironment('FONT_SOURCE_SHA');
  const onlyFont = String.fromEnvironment('FONT_ONLY');
  const outputPath = String.fromEnvironment(
    'FONT_CONTINUOUS_OUTPUT',
    defaultValue: '.dart_tool/thread-font-product-flow-r5/continuous',
  );
  const sample = '温油站 春风 あいうえお アイウエオ Hello 123 é 😀';
  testWidgets(
    '生产service/scope同进程当前目录、五轮返回、冷启动自动恢复与默认入口零下载',
    (tester) async {
      if (root.isEmpty || sourceSha.isEmpty) throw StateError('必须固定资产和源码摘要');
      final output = Directory(outputPath)..createSync(recursive: true);
      final manifestBytes = File(
        'contracts/thread-font-manifest-v1.json',
      ).readAsBytesSync();
      final manifest = TextFontManifest(manifestBytes);
      final manifestJson = jsonDecode(utf8.decode(manifestBytes)) as Map;
      final backendRevision = File('contracts/backend-contract.properties')
          .readAsLinesSync()
          .singleWhere((line) => line.startsWith('backendRevision='))
          .split('=')[1];
      final policy =
          jsonDecode(
                File(
                  'contracts/thread-font-runtime-policy-v2.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final hash = policy['manifestSha256'] as String;
      final cache = TextFontCache(Directory('${output.path}/cache-$pid'));
      final clock = Stopwatch()..start();
      final requests = <Map<String, Object?>>[];
      final failed = <String>{};
      Uint8List envelope(Object value) => Uint8List.fromList(
        utf8.encode(jsonEncode({'code': 0, 'message': 'OK', 'data': value})),
      );
      final service = TextFontService(
        WenyouApi(basePathOverride: 'https://api.example'),
        cache: cache,
        observePlatform: false,
        elapsed: () => clock.elapsed,
        retries: TextFontRetryLedger(random: () => 0.5),
        fetch: (uri, limit, mime, cancel) async {
          final kind = uri.path.endsWith('runtime-policy')
              ? 'policy'
              : uri.path.endsWith('/text-fonts')
              ? 'catalog'
              : uri.path == '/fonts/v1/$hash.json'
              ? 'manifest'
              : 'asset';
          final request = <String, Object?>{
            'kind': kind,
            'path': uri.path,
            'limit': limit,
            'mime': mime,
            'atMs': clock.elapsedMilliseconds,
          };
          requests.add(request);
          try {
            if (kind != 'asset' && failed.add(kind)) {
              throw const TextFontTransferFailure(
                TextFontTransferFailureKind.temporary,
              );
            }
            final Uint8List result;
            if (kind == 'catalog') {
              result = envelope({
                'fontVersion': 1,
                'catalogVersion': manifestJson['catalogVersion'],
                'fonts': [],
                'assetBaseUrl': 'https://assets.example/',
                'manifest': {
                  'path': 'fonts/v1/$hash.json',
                  'sha256': hash,
                  'bytes': manifestBytes.length,
                },
              });
            } else if (kind == 'policy') {
              result = envelope(policy);
            } else if (kind == 'manifest') {
              result = manifestBytes;
            } else {
              result = await File('$root${uri.path}').readAsBytes();
            }
            request['completedBytes'] = result.length;
            return result;
          } finally {
            request['finishedAtMs'] = clock.elapsedMilliseconds;
          }
        },
      );
      service.setOnline(false);
      // flutter_tester缺少Android系统中文字体；仅截图底字使用明确的本地替身。
      final fallback = manifest.fonts['source-han-sans']!.shards.firstWhere(
        (s) => s.id == 'core',
      );
      await tester.runAsync(() async {
        final bytes = await File('$root/${fallback.asset.path}').readAsBytes();
        await (FontLoader(
          'FontPreviewSystemFallback',
        )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      });
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      final boundary = GlobalKey();
      final selected = ValueNotifier(('wenkai', false));
      final theme = AppTheme.light;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [textFontServiceProvider.overrideWithValue(service)],
          child: RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme.copyWith(
                textTheme: theme.textTheme.apply(
                  fontFamily: 'FontPreviewSystemFallback',
                ),
              ),
              home: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ValueListenableBuilder(
                    valueListenable: selected,
                    builder: (context, value, _) => WenyouMarkdown(
                      enableTextFonts: value.$2,
                      data:
                          '**${manifest.fonts[value.$1]!.name}**\n\n<span data-wenyou-font-v1="${value.$1}">$sample</span>',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      Future<void> tick() async {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 20));
      }

      Future<void> capture(String name) async {
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '${output.path}/$name.png',
          ).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      await tick();
      expect(requests, isEmpty);
      await capture('default-zero-requests');
      selected.value = ('wenkai', true);
      await tester.pump();
      await tick();
      final runtime = (await tester.runAsync(service.load))!;
      expect(runtime.manifest, isNull);
      expect(requests, isEmpty);
      await capture('cold-no-metadata');
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      Future<void> awaitFont(String id) async {
        final needed = manifest.fonts[id]!.shards
            .where((s) => sample.runes.any(s.contains))
            .length;
        final deadline = clock.elapsed + const Duration(minutes: 2);
        while (clock.elapsed < deadline &&
            runtime.loadedFamilies(id).length < needed) {
          await tick();
        }
        if (runtime.loadedFamilies(id).length != needed) {
          await tester.runAsync(
            () => File('${output.path}/failure-$id.json').writeAsString(
              const JsonEncoder.withIndent('  ').convert({
                'id': id,
                'sourceSha256': sourceSha,
                'elapsed': clock.elapsedMilliseconds,
                'pending': runtime.demandQueue?.pendingCount,
                'timer': runtime.demandQueue?.hasTimer,
                'requests': requests,
                'shards': [
                  for (final s in manifest.fonts[id]!.shards.where(
                    (s) => sample.runes.any(s.contains),
                  ))
                    {
                      'family': s.family,
                      'hash': s.asset.hash,
                      'attempted': runtime.demandQueue?.snapshot.attempted(s),
                      'loaded': runtime.demandQueue?.snapshot.loadedFamily(s),
                      'quarantined': runtime.demandQueue?.retries.isTerminal(
                        s.asset.hash,
                      ),
                    },
                ],
              }),
            ),
          );
        }
        expect(
          runtime.loadedFamilies(id),
          hasLength(needed),
          reason: '$id 未自动完成',
        );
      }

      await awaitFont('wenkai');
      await capture('recovered-same-body');
      final rows = <Map<String, Object?>>[];
      for (final font in manifest.fonts.values) {
        if (onlyFont.isNotEmpty && font.id != onlyFont) continue;
        selected.value = (font.id, true);
        await tester.pump();
        await awaitFont(font.id);
        await capture(font.id);
        rows.add({
          'id': font.id,
          'completedAtMs': clock.elapsedMilliseconds,
          'pendingAfterLoad': runtime.demandQueue!.pendingCount,
          'loadedFamilies': runtime.loadedFamilies(font.id),
          'registeredCount': runtime.demandQueue!.snapshot.attemptedCount,
          'inputBytes':
              runtime.demandQueue!.snapshot.possiblyRetainedInputBytes,
        });
      }
      final registrations = runtime.demandQueue!.snapshot.attemptedCount;
      final assetRequests = requests.where((r) => r['kind'] == 'asset').length;
      for (var cycle = 0; cycle < 5; cycle++) {
        for (final font in manifest.fonts.values.toList().reversed) {
          if (onlyFont.isNotEmpty && font.id != onlyFont) continue;
          selected.value = (font.id, true);
          await tester.pump();
          await awaitFont(font.id);
        }
        expect(runtime.demandQueue!.snapshot.attemptedCount, registrations);
        expect(
          requests.where((r) => r['kind'] == 'asset').length,
          assetRequests,
        );
      }
      selected.value = ('wenkai', false);
      await tester.pump();
      await capture('returned-default');
      expect(requests.where((r) => r['kind'] == 'asset').length, assetRequests);
      expect(failed, {'catalog', 'manifest', 'policy'});
      if (onlyFont.isEmpty) expect(registrations, greaterThan(32));
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      service.dispose();
      selected.dispose();
      await tester.runAsync(
        () => File('${output.path}/evidence.json').writeAsString(
          const JsonEncoder.withIndent('  ').convert({
            'sourceSha256': sourceSha,
            'backendRevision': backendRevision,
            'manifestSha256': hash,
            'pid': pid,
            'device': 'Windows flutter_tester',
            'cache': cache.directory.absolute.path,
            'scope':
                '生产TextFontService/TextFontScope/FontLoader；本地正式字库；模拟传输失败，真实Stopwatch单调计时；无HTTP、账号或业务写入',
            'defaultGlyphFixture':
                '独立FontPreviewSystemFallback，只为Windows截图提供中文底字，不属于生产注册账本',
            'returnCycles': 5,
            'returnNewNativeRegistrations': 0,
            'returnNewAssetRequests': 0,
            'registeredCount': registrations,
            'requests': requests,
            'fonts': rows,
            'rss': ProcessInfo.currentRss,
            'peakRss': ProcessInfo.maxRss,
          }),
        ),
      );
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
    timeout: const Timeout(Duration(minutes: 12)),
  );
}
