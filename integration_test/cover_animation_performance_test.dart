import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_source_ports.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cached_cover_animation_source.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cover_animation_disk_store.dart';
import 'package:wenyousite_mobile/features/thread_feed/domain/thread_feed_models.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/cover_playback_scope.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/thread_feed_cover.dart';

const _base = String.fromEnvironment(
  'COVER_BENCHMARK_BASE_URL',
  defaultValue: 'http://127.0.0.1:18764',
);
int _epoch() => DateTime.now().toUtc().millisecondsSinceEpoch;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('独立Profile合成列表多动画性能采样', (tester) async {
    expect(kProfileMode, isTrue, reason: '禁止使用Debug或正式App替代独立Profile性能样本');
    final control = Dio(BaseOptions(baseUrl: _base));
    final results = <Map<String, Object?>>[];
    final manifest = (await control.get<Object>('/manifest')).data;
    for (final kind in ['preview', 'original']) {
      for (final count in [1, 2, 4]) {
        final group = '${kind}_$count';
        final directory = await Directory.systemTemp.createTemp(
          'wenyou-cover-benchmark-',
        );
        final disk = CoverAnimationDiskStore(directory: () async => directory);
        final cached = CachedCoverAnimationSource(disk: disk);
        final source = _MeasuredSource(cached);
        final container = ProviderContainer(
          overrides: [coverAnimationSourceProvider.overrideWithValue(source)],
        );
        final scroll = ScrollController(keepScrollOffset: false);
        final width = math.min(
          260.0,
          tester.view.physicalSize.width / tester.view.devicePixelRatio - 24,
        );
        Widget app({
          required bool show,
          required String caseId,
          bool sameUrl = false,
        }) => UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (_, child) => CoverPlaybackScope(child: child!),
            home: Scaffold(
              body: Center(
                child: show
                    ? SizedBox(
                        width: width,
                        height: width * 9 / 16 * count,
                        child: ListView.builder(
                          key: ValueKey(caseId),
                          controller: scroll,
                          itemCount: 20,
                          itemExtent: width * 9 / 16,
                          itemBuilder: (_, index) {
                            final path =
                                '/assets/${sameUrl ? '${group}_shared' : group}/${sameUrl ? 0 : index}';
                            return ThreadFeedCover(
                              key: ValueKey(index),
                              posterUrl: '$_base$path/poster.png',
                              animationUrl: '$_base$path/original.gif',
                              previewVariants: kind == 'preview'
                                  ? [
                                      ThreadFeedCoverPreviewVariant(
                                        url: '$_base$path/preview.webp',
                                        width: 480,
                                        height: 270,
                                        bytes: 438916,
                                      ),
                                    ]
                                  : const [],
                              onFirstFrameDecoded: () =>
                                  source.event('decoded', index),
                              onFirstFramePainted: () =>
                                  source.event('painted', index),
                            );
                          },
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
          ),
        );
        await tester.pumpWidget(app(show: false, caseId: group));
        for (final mode in [
          'cold',
          'memory',
          'disk',
          if (count == 4) 'same_url',
          if (count >= 2) 'fast_scroll',
          if (count >= 2) 'sustained',
        ]) {
          if (mode == 'disk') cached.releaseMemory();
          final caseId = '${group}_$mode';
          source.events.clear();
          final before = (await control.get<Object>('/stats')).data;
          final started = _epoch();
          await control.post<Object>(
            '/phase',
            queryParameters: {'name': caseId},
          );
          await binding.watchPerformance(() async {
            await tester.pumpWidget(
              app(show: true, caseId: caseId, sameUrl: mode == 'same_url'),
            );
            // 真时钟采样；未等待pumpAndSettle，无限动画不会变成测试挂起条件。
            final until = DateTime.now().add(
              Duration(seconds: mode == 'sustained' ? 12 : 8),
            );
            var direction = 1;
            var nextScroll = DateTime.now().add(
              const Duration(milliseconds: 700),
            );
            while (DateTime.now().isBefore(until)) {
              await tester.pump(const Duration(milliseconds: 16));
              if ((mode == 'fast_scroll' || mode == 'sustained') &&
                  DateTime.now().isAfter(nextScroll) &&
                  scroll.hasClients) {
                final distance =
                    width * 9 / 16 * (mode == 'fast_scroll' ? 3 : 0.3);
                final target = (scroll.offset + direction * distance).clamp(
                  0.0,
                  scroll.position.maxScrollExtent,
                );
                if (target == 0 || target == scroll.position.maxScrollExtent) {
                  direction *= -1;
                }
                unawaited(
                  scroll.animateTo(
                    target,
                    duration: Duration(
                      milliseconds: mode == 'fast_scroll' ? 100 : 500,
                    ),
                    curve: Curves.linear,
                  ),
                );
                nextScroll = DateTime.now().add(
                  Duration(milliseconds: mode == 'fast_scroll' ? 150 : 650),
                );
              }
            }
          }, reportKey: caseId);
          final ended = _epoch();
          await tester.pumpWidget(app(show: false, caseId: caseId));
          await tester.pump();
          await disk.flush();
          final deadline = DateTime.now().add(const Duration(seconds: 3));
          var after = (await control.get<Object>('/stats')).data;
          while (!_requestsSettled(after) &&
              DateTime.now().isBefore(deadline)) {
            await tester.pump(const Duration(milliseconds: 50));
            after = (await control.get<Object>('/stats')).data;
          }
          results.add({
            'caseId': caseId,
            'group': group,
            'mode': mode,
            'format': kind,
            'visibleCount': count,
            'logicalCoverWidth': width,
            'devicePixelRatio': tester.view.devicePixelRatio,
            'startedEpochMs': started,
            'endedEpochMs': ended,
            'events': List<Map<String, Object?>>.from(source.events),
            'httpBefore': before,
            'httpAfter': after,
            'httpSettled': _requestsSettled(after),
          });
          expect(
            source.events.any((event) => event['stage'] == 'painted'),
            isTrue,
            reason: '$caseId必须实际绘制动画',
          );
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        cached.dispose();
        await disk.flush();
        container.dispose();
        scroll.dispose();
        // directory由本fixture创建，绝不引用用户动画缓存目录。
        await directory.delete(recursive: true);
      }
    }
    binding.reportData ??= {};
    binding.reportData!['coverCases'] = results;
    binding.reportData!['coverManifest'] = manifest;
    binding.reportData!['schemaVersion'] = 1;
    control.close();
  }, timeout: const Timeout(Duration(minutes: 10)));
}

bool _requestsSettled(Object? stats) {
  if (stats is! Map || stats['assets'] is! Map) return false;
  final assets = stats['assets'] as Map;
  return assets.values.every(
    (asset) =>
        asset is Map &&
        asset['requests'] ==
            (asset['completed'] as num) + (asset['aborted'] as num),
  );
}

class _MeasuredSource implements CoverAnimationSource {
  _MeasuredSource(this.delegate);
  final CoverAnimationSource delegate;
  final events = <Map<String, Object?>>[];
  void event(String stage, int card) =>
      events.add({'stage': stage, 'card': card, 'epochMs': _epoch()});
  @override
  Future<CoverAnimationData> load(String url, CancelToken cancel) async {
    final item = <String, Object?>{
      'stage': 'load',
      'url': url,
      'epochMs': _epoch(),
    };
    events.add(item);
    try {
      final data = await delegate.load(url, cancel);
      events.add({
        'stage': 'bytes',
        'url': url,
        'epochMs': _epoch(),
        'bytes': data.bytes.length,
        'fromCache': data.fromCache,
      });
      return data;
    } on Object {
      events.add({
        'stage': 'cancelOrFailure',
        'url': url,
        'epochMs': _epoch(),
        'cancelled': cancel.isCancelled,
      });
      rethrow;
    }
  }

  @override
  Future<void> invalidate(String url) => delegate.invalidate(url);
  @override
  void changeViewer(String? accountId, {required bool purge}) =>
      delegate.changeViewer(accountId, purge: purge);
  @override
  void releaseMemory() => delegate.releaseMemory();
  @override
  void dispose() => delegate.dispose();
}
