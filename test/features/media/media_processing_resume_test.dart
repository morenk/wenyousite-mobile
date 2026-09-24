import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_pending_media.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  test('确认未成功时只对同一媒体重试确认，不重复直传', () async {
    final fixture = _ApiFixture()
      ..confirmStatus = 503
      ..status = 'UPLOADING';
    addTearDown(fixture.close);
    final container = ProviderContainer(
      overrides: [
        mediaUploadGatewayPortProvider.overrideWithValue(fixture.gateway),
      ],
    );
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final controller = container.read(provider.notifier);
    await controller.uploadInput(fixture.input);
    fixture.confirmStatus = 200;
    await controller.retryUpload();
    expect(fixture.postCount, 3);
    expect(fixture.putCount, 1);
    expect(container.read(provider).pendingUpload?.needsConfirmation, isFalse);
    fixture.status = 'COMPLETED';
    expect((await controller.retryUpload())?.mediaId, 'media-one');
    expect(fixture.postCount, 3);
    expect(fixture.putCount, 1);
  });

  test('初次确认的媒体身份错配不会进入处理查询', () async {
    final fixture = _ApiFixture()..confirmId = 'different-media';
    addTearDown(fixture.close);
    await expectLater(
      fixture.gateway.startImageUpload(fixture.input).result,
      throwsA(_invalidResponse('media_confirmation_identity_mismatch')),
    );
    expect(fixture.getCount, 0);
  });

  test('轮询退避不占查询名额，第三张可查询', () async {
    final delays = <Completer<void>>[];
    final fixture = _ApiFixture(
      delay: (duration) async {
        if (duration == const Duration(seconds: 1)) {
          final wait = Completer<void>();
          delays.add(wait);
          await wait.future;
        }
      },
    );
    addTearDown(fixture.close);
    final operations = List.generate(
      3,
      (_) => fixture.gateway.startImageUpload(fixture.input),
    );
    for (var i = 0; i < 30; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(fixture.getCount, 3);
    expect(delays, hasLength(3));
    fixture.status = 'COMPLETED';
    for (final delay in delays) {
      delay.complete();
    }
    expect(await Future.wait(operations.map((o) => o.result)), hasLength(3));
  });

  test('取消排队中的第三张后不请求上传地址或执行 PUT', () async {
    final wait = Completer<void>();
    final fixture = _ApiFixture()..confirmPause = wait;
    addTearDown(fixture.close);
    final first = fixture.gateway.startImageUpload(fixture.input);
    final second = fixture.gateway.startImageUpload(fixture.input);
    final third = fixture.gateway.startImageUpload(fixture.input);
    final cancelled = expectLater(third.result, throwsA(isA<ApiFailure>()));
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(fixture.putCount, 2);
    third.cancel();
    fixture.status = 'COMPLETED';
    wait.complete();
    await Future.wait([first.result, second.result]);
    await cancelled;
    expect(fixture.putCount, 2);
    expect(fixture.postCount, 4);
  });

  test('前两张处理查询未返回时第三张仍完成传输，查询最多两路', () async {
    final wait = Completer<void>();
    final fixture = _ApiFixture()..getPause = wait;
    addTearDown(fixture.close);
    final operations = List.generate(
      3,
      (_) => fixture.gateway.startImageUpload(fixture.input),
    );
    await fixture.firstQuery.future;
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(fixture.putCount, 3);
    expect(fixture.postCount, 6);
    expect(fixture.getCount, 2);
    fixture.status = 'COMPLETED';
    wait.complete();
    expect(await Future.wait(operations.map((o) => o.result)), hasLength(3));
    expect(fixture.getCount, 3);
  });

  test('确认响应丢失后用已知身份恢复，文件丢失也不重传', () async {
    final fixture = _ApiFixture()..confirmStatus = 503;
    addTearDown(fixture.close);
    final container = ProviderContainer(
      overrides: [
        mediaUploadGatewayPortProvider.overrideWithValue(fixture.gateway),
      ],
    );
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final controller = container.read(provider.notifier);
    expect(await controller.uploadInput(fixture.input), isNull);
    final pending = container.read(provider).pendingUpload!;
    expect(pending.needsConfirmation, isTrue);
    expect(container.read(provider).failure?.canRetry, isTrue);
    fixture.status = 'COMPLETED';
    fixture.confirmStatus = 200;
    final missing = MediaUploadInput.fromPickedSource(
      const PickedMediaSource.file(
        filename: 'missing.gif',
        path: 'missing-private-file.gif',
        length: 10,
      ),
    );
    final image = await controller.resumeUpload(missing, pending);
    expect(image?.mediaId, 'media-one');
    expect(fixture.postCount, 2);
    expect(fixture.putCount, 1);
    expect(fixture.getCount, 1);
  });

  test('离页暂停保留处理中身份，迟到结果不能恢复旧操作', () async {
    final wait = Completer<void>();
    final fixture = _ApiFixture()..getPause = wait;
    addTearDown(fixture.close);
    final container = ProviderContainer(
      overrides: [
        mediaUploadGatewayPortProvider.overrideWithValue(fixture.gateway),
      ],
    );
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final controller = container.read(provider.notifier);
    final upload = controller.uploadInput(fixture.input);
    await fixture.firstQuery.future;
    expect(container.read(provider).pendingUpload?.mediaId, 'media-one');
    controller.pause();
    expect(await upload, isNull);
    expect(container.read(provider).isBusy, isFalse);
    final pending = container.read(provider).pendingUpload!;
    fixture.status = 'COMPLETED';
    wait.complete();
    await Future<void>.delayed(Duration.zero);
    expect(container.read(provider).pendingUpload, same(pending));
    expect(
      (await controller.resumeUpload(fixture.input, pending))?.mediaId,
      'media-one',
    );
    expect(fixture.postCount, 2);
    expect(fixture.putCount, 1);
  });

  for (final url in [
    'http://cdn.example/full.webp',
    'https://cdn.example/full.webp',
    'http://localhost/full.webp',
    'http://127.0.0.1/full.webp',
    'http://[::1]/full.webp',
    'http://10.0.2.2/full.webp',
  ]) {
    test('完整展示上传结果沿用安全 URL 规则：$url', () async {
      final fixture = _ApiFixture()
        ..status = 'COMPLETED'
        ..displayUrl = url;
      addTearDown(fixture.close);
      final task = fixture.gateway.startImageUpload(fixture.input);
      if (url.startsWith('http://cdn.')) {
        await expectLater(
          task.result,
          throwsA(_invalidResponse('media_url_unsafe')),
        );
      } else {
        expect((await task.result).display?.url, url);
      }
    });
  }
  for (final missing in [true, false]) {
    test('查询响应${missing ? '缺少媒体' : '身份不匹配'}使用内容失败展示映射', () async {
      final fixture = _ApiFixture()
        ..missingQueryData = missing
        ..queryId = 'another-media';
      addTearDown(fixture.close);
      final task = fixture.gateway.startImageUpload(fixture.input);
      final matcher = _invalidResponse(
        missing ? 'media_query_missing_data' : 'media_query_identity_mismatch',
      );
      await expectLater(
        task.result,
        throwsA(
          missing
              ? isA<MediaProcessingLookupFailure>().having(
                  (e) => e.cause,
                  'cause',
                  matcher,
                )
              : matcher,
        ),
      );
      expect(fixture.postCount, 2);
      expect(fixture.putCount, 1);
    });
  }
  test('账号切换取消处理中查询，迟到响应不能恢复旧任务', () async {
    final wait = Completer<void>();
    final fixture = _ApiFixture()..getPause = wait;
    addTearDown(fixture.close);
    final account = StateProvider<int>((ref) => 0);
    final container = ProviderContainer(
      overrides: [
        mediaUploadGatewayPortProvider.overrideWithValue(fixture.gateway),
        mediaUploadSessionScopePortProvider.overrideWith(
          (ref) => ref.watch(account),
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final upload = container.read(provider.notifier).uploadInput(fixture.input);
    await fixture.firstQuery.future;
    container.read(account.notifier).state++;
    expect(container.read(provider).phase, MediaUploadTaskPhase.idle);
    expect(await upload, isNull);
    wait.complete();
    await Future<void>.delayed(Duration.zero);
    expect(container.read(provider).pendingUpload, isNull);
    expect(await container.read(provider.notifier).retryUpload(), isNull);
    expect(fixture.getCount, 1);
    expect(fixture.postCount, 2);
    expect(fixture.putCount, 1);
  });
  test('账号代次切换清理旧待查询身份，不把旧媒体续查带给新账号', () async {
    final fixture = _ApiFixture();
    addTearDown(fixture.close);
    final account = StateProvider<int>((ref) => 0);
    final container = ProviderContainer(
      overrides: [
        mediaUploadGatewayPortProvider.overrideWithValue(fixture.gateway),
        mediaUploadSessionScopePortProvider.overrideWith(
          (ref) => ref.watch(account),
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(provider.notifier).uploadInput(fixture.input);
    expect(container.read(provider).pendingUpload?.mediaId, 'media-one');
    final queries = fixture.getCount;
    container.read(account.notifier).state++;
    expect(container.read(provider).pendingUpload, isNull);
    expect(container.read(provider).phase, MediaUploadTaskPhase.idle);
    expect(await container.read(provider.notifier).retryUpload(), isNull);
    expect(fixture.getCount, queries);
    expect(fixture.postCount, 2);
    expect(fixture.putCount, 1);
  });
  test('长处理保留媒体身份，继续查询只增加 GET 不再 POST/PUT', () async {
    final fixture = _ApiFixture();
    addTearDown(fixture.close);
    final container = ProviderContainer(
      overrides: [
        mediaUploadGatewayPortProvider.overrideWithValue(fixture.gateway),
      ],
    );
    addTearDown(container.dispose);
    final provider = mediaUploadTaskControllerProvider(Object());
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final controller = container.read(provider.notifier);
    expect(await controller.uploadInput(fixture.input), isNull);
    expect(
      container.read(provider).phase,
      MediaUploadTaskPhase.processingPending,
    );
    expect(container.read(provider).pendingUpload?.mediaId, 'media-one');
    expect(container.read(provider).isBusy, isFalse);
    fixture.status = 'COMPLETED';
    final image = await controller.retryUpload();
    expect(image?.mediaId, 'media-one');
    expect(image?.display?.url, 'https://cdn.example/full.webp');
    expect(fixture.postCount, 2);
    expect(fixture.putCount, 1);
    expect(fixture.getCount, 3);
  });
  for (final status in [401, 403, 404, 503]) {
    test('查询 $status 不伪装处理中且不重复上传', () async {
      final fixture = _ApiFixture()..getStatus = status;
      addTearDown(fixture.close);
      final container = ProviderContainer(
        overrides: [
          mediaUploadGatewayPortProvider.overrideWithValue(fixture.gateway),
        ],
      );
      addTearDown(container.dispose);
      final provider = mediaUploadTaskControllerProvider(Object());
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      final controller = container.read(provider.notifier);
      expect(await controller.uploadInput(fixture.input), isNull);
      final state = container.read(provider);
      expect(state.phase, MediaUploadTaskPhase.failed);
      expect(state.pendingUpload?.mediaId, 'media-one');
      expect(state.failure?.failure.httpStatus, status);
      expect(state.failure?.canRetry, status == 503);
      fixture.getStatus = 200;
      fixture.status = 'COMPLETED';
      final result = await controller.retryUpload();
      expect(result?.mediaId, status == 503 ? 'media-one' : null);
      expect(fixture.postCount, 2);
      expect(fixture.putCount, 1);
      controller.reset();
      expect(container.read(provider).pendingUpload, isNull);
    });
  }
  test('私聊独立队列保留 PROCESSING 和查询失败身份，完成后才可发送', () async {
    final fixture = _ApiFixture();
    addTearDown(fixture.close);
    final jobs = DirectMessagePendingMediaJobs(fixture.gateway);
    addTearDown(jobs.dispose);
    jobs.register('message-one', fixture.input);
    await expectLater(
      jobs.resolveMediaId('message-one', onProgress: (_) {}),
      throwsA(isA<MediaProcessingPending>()),
    );
    fixture.getStatus = 403;
    await expectLater(
      jobs.resolveMediaId('message-one', onProgress: (_) {}),
      throwsA(
        isA<MediaProcessingLookupFailure>().having(
          (error) => (error.cause as ApiFailure).httpStatus,
          'status',
          403,
        ),
      ),
    );
    fixture.getStatus = 200;
    fixture.status = 'COMPLETED';
    expect(
      await jobs.resolveMediaId('message-one', onProgress: (_) {}),
      'media-one',
    );
    expect(fixture.postCount, 2);
    expect(fixture.putCount, 1);
    expect(
      await jobs.resolveMediaId('message-one', onProgress: (_) {}),
      'media-one',
    );
    jobs.remove('message-one');
    expect(jobs.contains('message-one'), isFalse);
  });
}

Matcher _invalidResponse(String code) => isA<ApiFailure>()
    .having((e) => e.reason, 'reason', FailureReason.contractViolation)
    .having((e) => e.diagnosticCode, 'diagnostic', code)
    .having((e) => e.legacyUserMessage, 'legacy copy', isNull)
    .having(
      (e) => UserFacingFailure.fromApi(e).message,
      'presentation',
      '当前内容暂时无法显示，请重新加载。',
    );

class _ApiFixture {
  _ApiFixture({MediaUploadDelay? delay}) {
    apiDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) async {
          Object? data;
          if (request.method == 'POST') {
            postCount++;
            if (!request.path.endsWith('/upload-url')) {
              await confirmPause?.future;
            }
            if (!request.path.endsWith('/upload-url') && confirmStatus != 200) {
              handler.reject(
                DioException(
                  requestOptions: request,
                  type: DioExceptionType.badResponse,
                  response: Response<Object>(
                    requestOptions: request,
                    statusCode: confirmStatus,
                    data: {'code': confirmStatus * 100, 'message': 'failure'},
                  ),
                ),
              );
              return;
            }
            data = request.path.endsWith('/upload-url')
                ? {
                    'uploadUrl': 'https://s3.example/upload',
                    'mediaId': 'media-one',
                    'objectKey': 'original.gif',
                    'publicUrl': 'https://cdn.example/original.gif',
                  }
                : {
                    'processing': status != 'COMPLETED',
                    'media': {...media, 'id': confirmId},
                  };
          } else {
            getCount++;
            if (!firstQuery.isCompleted) firstQuery.complete();
            await getPause?.future;
            if (getStatus != 200) {
              handler.reject(
                DioException(
                  requestOptions: request,
                  type: DioExceptionType.badResponse,
                  response: Response<Object>(
                    requestOptions: request,
                    statusCode: getStatus,
                    data: {'code': getStatus * 100, 'message': 'failure'},
                  ),
                ),
              );
              return;
            }
            data = missingQueryData ? null : {...media, 'id': queryId};
          }
          handler.resolve(
            Response<Object>(
              requestOptions: request,
              statusCode: 200,
              data: request.method == 'GET' && missingQueryData
                  ? null
                  : {'code': 0, 'message': 'ok', 'data': data},
            ),
          );
        },
      ),
    );
    putDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          putCount++;
          handler.resolve(
            Response<Object>(requestOptions: request, statusCode: 200),
          );
        },
      ),
    );
    gateway = RepositoryMediaUploadGateway(
      ApiMediaUploadRepository(
        WenyouApi(dio: apiDio).getMediaApi(),
        putDio,
        maxPollAttempts: 2,
        delay: delay ?? (_) async {},
      ),
    );
  }
  final apiDio = Dio();
  final firstQuery = Completer<void>();
  Completer<void>? getPause;
  Completer<void>? confirmPause;
  final putDio = Dio();
  late final RepositoryMediaUploadGateway gateway;
  var postCount = 0, putCount = 0, getCount = 0, getStatus = 200;
  var confirmStatus = 200;
  var confirmId = 'media-one';
  var status = 'PROCESSING';
  var displayUrl = 'https://cdn.example/full.webp';
  var queryId = 'media-one';
  var missingQueryData = false;
  MediaUploadInput get input => MediaUploadInput(
    filename: 'original.gif',
    declaredContentType: 'image/gif',
    bytes: File(
      'test/fixtures/animation-webp-all-surfaces/original.gif',
    ).readAsBytesSync(),
  );
  Map<String, Object?> get media => {
    'id': 'media-one',
    'userId': 'user-one',
    'url': 'https://cdn.example/original.gif',
    'key': 'original.gif',
    'contentType': 'image/gif',
    'size': 1383,
    'width': 320,
    'height': 180,
    'purpose': 'RICH_CONTENT',
    'animated': true,
    'status': status,
    'createdAt': '2026-09-12T00:00:00Z',
    if (status == 'COMPLETED')
      'display': {
        'url': displayUrl,
        'contentType': 'image/webp',
        'width': 320,
        'height': 180,
        'bytes': 180,
        'animated': true,
        'frameCount': 2,
        'durationMs': 360,
        'loopCount': 2,
      },
  };
  void close() {
    apiDio.close();
    putDio.close();
  }
}
