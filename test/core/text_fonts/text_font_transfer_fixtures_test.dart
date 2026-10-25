import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transfer_deadline.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transfer_failure.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';

void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/thread-font-runtime-policy-v2-fixtures.json',
            ).readAsStringSync(),
          )
          as Map;
  for (final entry in fixture['transferCases'] as List) {
    test('正式传输轨迹经过生产Dio流读取：${entry['id']}', () async {
      final time = FakeAsync();
      String? outcome;
      int? finishedAt, completeBytes;
      late Dio dio;
      late CancelToken cancel;
      final events = <Map<String, Object?>>[];
      time.run((_) {
        final start = entry['startedAtMs'] as int;
        time.elapse(Duration(milliseconds: start));
        for (final event in entry['events'] as List) {
          for (var i = 0; i < (event['repeat'] as int? ?? 1); i++) {
            events.add({
              ...Map<String, Object?>.from(event as Map),
              'atMs':
                  (event['atMs'] as int) + i * (event['everyMs'] as int? ?? 0),
            });
          }
        }
        cancel = CancelToken();
        final adapter = _TraceAdapter(start, events, cancel);
        dio = Dio()..httpClientAdapter = adapter;
        final transport = TextFontTransport(
          dio: dio,
          elapsed: () => time.elapsed,
        );
        unawaited(
          transport
              .fetch(
                Uri.parse('https://fixture.invalid/font.ttf'),
                entry['byteLimit'] as int,
                'font/ttf',
                cancel,
              )
              .then(
                (bytes) {
                  outcome = 'complete';
                  completeBytes = bytes.length;
                  finishedAt = time.elapsed.inMilliseconds;
                },
                onError: (Object error) {
                  finishedAt = time.elapsed.inMilliseconds;
                  outcome = switch (error) {
                    FormatException() => 'length-rejected',
                    TextFontTransferFailure(
                      kind: TextFontTransferFailureKind.cancelled,
                    ) =>
                      'cancelled',
                    TextFontTransferFailure(
                      kind: TextFontTransferFailureKind.temporary,
                    ) =>
                      cancel.cancelError?.error == TextFontDeadlineReason.total
                          ? 'total-timeout'
                          : 'idle-timeout',
                    _ => 'unexpected-$error',
                  };
                },
              ),
        );
        time.flushMicrotasks();
      });
      final expected = entry['expected'] as Map;
      final instants = {
        ...events.map((e) => e['atMs'] as int),
        expected['atMs'] as int,
      }.toList()..sort();
      for (final at in instants) {
        time.elapse(Duration(milliseconds: at) - time.elapsed);
        // Stream取消可能使用真实事件队列；不能先把模拟时钟推过截止再等待。
        await Future<void>.delayed(Duration.zero);
        time.flushMicrotasks();
        if (outcome != null) break;
      }
      expect(
        outcome,
        expected['outcome'],
        reason:
            'cancelled=${cancel.isCancelled}, reason=${cancel.cancelError?.error}, pending=${time.pendingTimers.length}',
      );
      expect(finishedAt, expected['atMs']);
      if (outcome == 'complete') {
        expect(completeBytes, expected['acceptedBytes']);
      }
      dio.close(force: true);
      time.flushMicrotasks();
      expect(time.pendingTimers, isEmpty);
    });
  }
}

class _TraceAdapter implements HttpClientAdapter {
  _TraceAdapter(this.start, this.events, this.cancel);
  final int start;
  final List<Map<String, Object?>> events;
  final CancelToken cancel;
  final _timers = <Timer>[];
  StreamController<Uint8List>? _body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final response = Completer<ResponseBody>();
    final controller = _body = StreamController<Uint8List>(onCancel: close);
    final headers = events.where((e) => e['kind'] == 'headers').firstOrNull;
    final firstData = events.where((e) => e['kind'] == 'data').firstOrNull;
    final headerAt = (headers ?? firstData)?['atMs'] as int?;
    if (headerAt != null) {
      _timers.add(
        Timer(Duration(milliseconds: headerAt - start), () {
          response.complete(
            ResponseBody(
              controller.stream,
              200,
              headers: {
                'content-type': ['font/ttf'],
              },
              onClose: close,
            ),
          );
        }),
      );
    }
    for (final event in events) {
      _timers.add(
        Timer(Duration(milliseconds: (event['atMs'] as int) - start), () {
          switch (event['kind']) {
            case 'data':
              controller.add(Uint8List(event['bytes'] as int));
            case 'end':
              unawaited(controller.close());
            case 'cancel':
              cancel.cancel(event['reason']);
          }
        }),
      );
    }
    unawaited(
      cancelFuture?.then((_) {
        close();
        if (!response.isCompleted) {
          response.completeError(
            DioException.requestCancelled(
              requestOptions: options,
              reason: cancel.cancelError?.error,
            ),
          );
        }
      }),
    );
    return response.future;
  }

  @override
  void close({bool force = false}) {
    for (final timer in _timers) {
      timer.cancel();
    }
    final body = _body;
    if (body != null && !body.isClosed) unawaited(body.close());
  }
}
