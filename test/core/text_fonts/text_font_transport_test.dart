import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transfer_failure.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';

import 'font_test_fixture.dart';

void main() {
  test('超长响应体未EOF也立即拒绝，不等待底层流关闭', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    Future<void>? handler;
    Future<void> respond(HttpRequest request) async {
      try {
        request.response.bufferOutput = false;
        request.response.headers.contentType = ContentType.json;
        request.response.add(List.filled(65537, 65));
        await request.response.flush();
        await Future<void>.delayed(const Duration(seconds: 3));
        await request.response.close();
      } on HttpException {
        // 客户端主动取消超限流。
      } on SocketException {
        // 同上。
      }
    }

    server.listen((request) => handler = respond(request));
    try {
      final watch = Stopwatch()..start();
      await expectLater(
        TextFontTransport().fetch(
          Uri.parse('http://127.0.0.1:${server.port}/'),
          65536,
          'application/json',
          CancelToken(),
        ),
        throwsFormatException,
      );
      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
    } finally {
      await handler;
      await server.close(force: true);
    }
  });

  for (final slowMetadata in [true, false]) {
    test(
      '生产service/queue持续慢流超过15秒，元数据=$slowMetadata',
      () async {
        final f = FontTestFixture(jsonNotice: true);
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final registered = <String>[];
        final handlers = <Future<void>>[];
        Future<void> respond(HttpRequest request) async {
          final path = request.uri.path;
          final bytes = path.endsWith('/text-fonts')
              ? f.envelope(f.catalog())
              : path.endsWith('runtime-policy')
              ? f.envelope(f.policy())
              : f.data[path.split('/').last.split('.').first]!;
          final slow = slowMetadata
              ? path.endsWith('/text-fonts')
              : path == '/${f.a.path}';
          try {
            request.response.bufferOutput = false;
            request.response.headers.contentType = ContentType.parse(
              path.endsWith('.ttf') ? 'font/ttf' : 'application/json',
            );
            if (slow) {
              final step = (bytes.length / 3).ceil();
              for (var i = 0; i < bytes.length; i += step) {
                if (i > 0) {
                  await Future<void>.delayed(const Duration(seconds: 8));
                }
                final end = i + step < bytes.length ? i + step : bytes.length;
                request.response.add(bytes.sublist(i, end));
                await request.response.flush();
              }
            } else {
              request.response.add(bytes);
            }
            await request.response.close();
          } on HttpException {
            // 旧总超时实现的回归运行会主动断开测试连接。
          } on SocketException {
            // 同上，保留旧实现失败证据时允许服务端结束。
          }
        }

        server.listen((request) => handlers.add(respond(request)));
        final transport = TextFontTransport(
          maximumDuration: const Duration(minutes: 10),
        );
        final service = TextFontService(
          WenyouApi(basePathOverride: 'https://api.example'),
          cache: MemoryFontCache(),
          observePlatform: false,
          register: (family, _) async => registered.add(family),
          fetch: (uri, limit, mime, cancel) => transport.fetch(
            uri.replace(scheme: 'http', host: '127.0.0.1', port: server.port),
            limit,
            mime,
            cancel,
          ),
        );
        try {
          final runtime = await service.retain('body', {'wenkai': 'AB'});
          expect(runtime.demandQueue, isNotNull);
          await runtime.demandQueue!.settle();
          expect(registered, ['WYF1-abc-a', 'WYF1-abc-b']);
        } finally {
          service.dispose();
          await Future.wait(handlers);
          await server.close(force: true);
        }
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );
  }

  test(
    '真实HTTP持续进度超过15秒仍完成，停流可取消且外部取消不记超时',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final handlers = <Future<void>>[];
      Future<void> respond(HttpRequest request) async {
        try {
          request.response.bufferOutput = false;
          request.response.headers.contentType = ContentType.parse('font/ttf');
          request.response.add([65]);
          await request.response.flush();
          if (request.uri.path == '/slow') {
            for (var i = 0; i < 16; i++) {
              await Future<void>.delayed(const Duration(seconds: 1));
              request.response.add([65]);
              await request.response.flush();
            }
          } else {
            await Future<void>.delayed(const Duration(seconds: 1));
          }
          await request.response.close();
        } on HttpException {
          // 停流和外部取消用例主动终止客户端连接。
        } on SocketException {
          // 同上，平台可能在flush时报告连接已经关闭。
        }
      }

      server.listen((request) => handlers.add(respond(request)));
      final uri = Uri.parse('http://127.0.0.1:${server.port}/slow');
      try {
        final transport = TextFontTransport(
          maximumDuration: const Duration(minutes: 10),
        );
        final watch = Stopwatch()..start();
        final cancel = CancelToken();
        expect(
          await transport.fetch(uri, 17, 'font/ttf', cancel),
          hasLength(17),
        );
        expect(watch.elapsed, greaterThan(const Duration(seconds: 15)));
        expect(cancel.isCancelled, isFalse);
        final short = TextFontTransport(
          progressTimeout: const Duration(milliseconds: 200),
          maximumDuration: const Duration(seconds: 5),
        );
        await expectLater(
          short.fetch(
            uri.replace(path: '/stall'),
            17,
            'font/ttf',
            CancelToken(),
          ),
          throwsA(
            isA<TextFontTransferFailure>().having(
              (e) => e.kind,
              'kind',
              TextFontTransferFailureKind.temporary,
            ),
          ),
        );
        final external = CancelToken();
        final timer = Timer(
          const Duration(milliseconds: 100),
          () => external.cancel('background'),
        );
        try {
          await expectLater(
            transport.fetch(
              uri.replace(path: '/cancel'),
              17,
              'font/ttf',
              external,
            ),
            throwsA(
              isA<TextFontTransferFailure>().having(
                (e) => e.kind,
                'kind',
                TextFontTransferFailureKind.cancelled,
              ),
            ),
          );
        } finally {
          timer.cancel();
        }
      } finally {
        await Future.wait(handlers);
        await server.close(force: true);
      }
    },
    timeout: const Timeout(Duration(seconds: 40)),
  );

  test('HTML 502/503先按HTTP暂时错误和Retry-After分类，200错误MIME仍隔离', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response.statusCode = int.parse(request.uri.path.substring(1));
      request.response.headers.contentType = ContentType.html;
      request.response.headers.set('Retry-After', '120');
      request.response.write('<html>gateway temporarily unavailable</html>');
      await request.response.close();
    });
    try {
      final transport = TextFontTransport();
      for (final status in [502, 503]) {
        await expectLater(
          transport.fetch(
            Uri.parse('http://127.0.0.1:${server.port}/$status'),
            65536,
            'application/json',
            CancelToken(),
          ),
          throwsA(
            isA<TextFontTransferFailure>()
                .having(
                  (e) => e.kind,
                  'kind',
                  TextFontTransferFailureKind.temporary,
                )
                .having(
                  (e) => e.retryAfter,
                  'Retry-After',
                  const Duration(seconds: 120),
                ),
          ),
        );
      }
      await expectLater(
        transport.fetch(
          Uri.parse('http://127.0.0.1:${server.port}/200'),
          65536,
          'application/json',
          CancelToken(),
        ),
        throwsFormatException,
      );
    } finally {
      await server.close(force: true);
    }
  });
  test('真实流式HTTP严格MIME：JSON归属声明通过service映射后可注册', () async {
    final f = FontTestFixture(jsonNotice: true);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final directory = await Directory.systemTemp.createTemp('font-http-test-');
    final paths = <String>[], registered = <String>[];
    server.listen((request) async {
      paths.add(request.uri.path);
      expect(request.headers.value('authorization'), isNull);
      expect(
        request.headers.value('x-request-id'),
        matches(RegExp(r'^[a-f0-9-]{36}$')),
      );
      final path = request.uri.path;
      request.response.headers.contentType = ContentType.parse(
        path.endsWith('.ttf') ? 'font/ttf' : 'application/json',
      );
      request.response.add(
        path.endsWith('/text-fonts')
            ? f.envelope(f.catalog())
            : path.endsWith('runtime-policy')
            ? f.envelope(f.policy())
            : f.data[path.split('/').last.split('.').first]!,
      );
      await request.response.close();
    });
    final transport = TextFontTransport();
    final service = TextFontService(
      WenyouApi(basePathOverride: 'https://api.example'),
      cache: MemoryFontCache(directory),
      observePlatform: false,
      register: (family, _) async => registered.add(family),
      fetch: (uri, limit, mime, cancel) => transport.fetch(
        uri.replace(scheme: 'http', host: '127.0.0.1', port: server.port),
        limit,
        mime,
        cancel,
      ),
    );
    try {
      final runtime = await service.retain('body', {'wenkai': 'AB'});
      await runtime.demandQueue!.settle();
      expect(registered, ['WYF1-abc-a', 'WYF1-abc-b']);
      expect(paths.where((p) => p == '/${f.notice.path}').length, 1);
      expect(paths.length, 6);
    } finally {
      service.dispose();
      await server.close(force: true);
      await directory.delete(recursive: true);
    }
  });

  test('响应头MIME错误和流式超过64KiB均拒绝', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response.headers.contentType = ContentType.parse(
        request.uri.path == '/wrong' ? 'text/plain' : 'application/json',
      );
      request.response.add(
        List.filled(request.uri.path == '/wrong' ? 3 : 65537, 65),
      );
      await request.response.close();
    });
    try {
      final transport = TextFontTransport();
      for (final path in ['wrong', 'large']) {
        await expectLater(
          transport.fetch(
            Uri.parse('http://127.0.0.1:${server.port}/$path'),
            65536,
            'application/json',
            CancelToken(),
          ),
          throwsFormatException,
        );
      }
    } finally {
      await server.close(force: true);
    }
  });
}
