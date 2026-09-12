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
  _ApiFixture() {
    apiDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) async {
          Object? data;
          if (request.method == 'POST') {
            postCount++;
            data = request.path.endsWith('/upload-url')
                ? {
                    'uploadUrl': 'https://s3.example/upload',
                    'mediaId': 'media-one',
                    'objectKey': 'original.gif',
                    'publicUrl': 'https://cdn.example/original.gif',
                  }
                : {'processing': status != 'COMPLETED', 'media': media};
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
        delay: (_) async {},
      ),
    );
  }
  final apiDio = Dio();
  final firstQuery = Completer<void>();
  Completer<void>? getPause;
  final putDio = Dio();
  late final RepositoryMediaUploadGateway gateway;
  var postCount = 0, putCount = 0, getCount = 0, getStatus = 200;
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
