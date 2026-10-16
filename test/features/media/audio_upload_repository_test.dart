import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/data/audio_transfer_timing.dart';
import 'package:wenyousite_mobile/features/media/data/audio_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_work_coordinator.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_models.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_policy.dart';

final audioPolicy = AudioUploadPolicy.parse({
  'version': 1,
  'maxBytes': 31457280,
  'maxDurationMs': 600000,
  'contentTypes': ['audio/mpeg'],
  'outputContentType': 'audio/mpeg',
})!;

void main() {
  late Directory directory;
  late AudioUploadInput input;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('wenyou-audio-test-');
    final file = await File(
      '${directory.path}/source.mp3',
    ).writeAsBytes(List.filled(80000, 7));
    input = AudioUploadInput(
      filename: 'source.mp3',
      path: file.path,
      size: 80000,
      contentType: 'audio/mpeg',
    );
  });
  tearDown(() => directory.delete(recursive: true));

  test('流式 PUT 前保存身份，确认后查询播放投影，存储请求无账号头', () async {
    final server = _Server();
    addTearDown(server.dispose);
    final saved = <PendingAudioUpload>[];
    server.storage.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) async {
          expect(saved.single.mediaId, 'audio-one');
          expect(request.data, isA<Stream<List<int>>>());
          expect(
            request.headers.keys.map((k) => k.toLowerCase()),
            isNot(contains('authorization')),
          );
          expect(request.headers['Content-Length'], 80000);
          expect(
            await (request.data as Stream<List<int>>).fold<int>(
              0,
              (n, bytes) => n + bytes.length,
            ),
            80000,
          );
          handler.resolve(Response(requestOptions: request, statusCode: 200));
        },
      ),
    );
    final audio = await server.repository.upload(
      input,
      audioPolicy,
      cancelToken: CancelToken(),
      savePending: (p) async => saved.add(p),
    );
    expect(audio.mediaId, 'audio-one');
    expect(saved.map((p) => p.stage), [
      AudioUploadStage.uploading,
      AudioUploadStage.confirming,
      AudioUploadStage.processing,
    ]);
    expect(server.paths, [
      '/api/v1/media/upload-url',
      '/api/v1/media/upload-done',
      '/api/v1/media/audio-one',
    ]);
  });

  test('已完成身份在能力关闭且本机文件缺失时只读恢复', () async {
    final server = _Server();
    addTearDown(server.dispose);
    final result = await server.repository.upload(
      null,
      null,
      pending: const PendingAudioUpload(
        'audio-one',
        AudioUploadStage.processing,
      ),
      cancelToken: CancelToken(),
      savePending: (_) async => fail('完成不需要保存新身份'),
    );
    expect(result.sourceUrl, 'https://storage.example/audio.mp3');
    expect(server.paths, ['/api/v1/media/audio-one']);
  });

  test('FAILED 是可识别终态，不继续轮询或重新创建', () async {
    final server = _Server(status: 'FAILED');
    addTearDown(server.dispose);
    await expectLater(
      server.repository.upload(
        input,
        audioPolicy,
        pending: const PendingAudioUpload(
          'audio-one',
          AudioUploadStage.processing,
        ),
        cancelToken: CancelToken(),
        savePending: (_) async {},
      ),
      throwsA(isA<AudioProcessingFailed>()),
    );
    expect(server.paths, ['/api/v1/media/audio-one']);
  });

  test('身份或 purpose 不匹配拒绝恢复', () async {
    final server = _Server(purpose: 'RICH_CONTENT');
    addTearDown(server.dispose);
    await expectLater(
      server.repository.upload(
        input,
        audioPolicy,
        pending: const PendingAudioUpload(
          'audio-one',
          AudioUploadStage.processing,
        ),
        cancelToken: CancelToken(),
        savePending: (_) async {},
      ),
      throwsA(isA<ApiFailure>()),
    );
    expect(server.paths, ['/api/v1/media/audio-one']);
  });

  test('轮询等待可取消，取消后无额外查询', () async {
    final polling = Completer<void>();
    final server = _Server(
      status: 'PROCESSING',
      delay: (duration, cancel) {
        polling.complete();
        return waitForAudioProcessing(duration, cancel);
      },
    );
    addTearDown(server.dispose);
    final cancel = CancelToken();
    final result = server.repository.upload(
      input,
      audioPolicy,
      pending: const PendingAudioUpload(
        'audio-one',
        AudioUploadStage.processing,
      ),
      cancelToken: cancel,
      savePending: (_) async {},
    );
    final checked = expectLater(
      result,
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    await polling.future;
    cancel.cancel();
    await checked;
    expect(server.paths, ['/api/v1/media/audio-one']);
  });

  test('持续处理超过旧60次仍等原身份，递增间隔封顶10秒', () async {
    final intervals = <int>[];
    late final _Server server;
    server = _Server(
      status: 'PROCESSING',
      delay: (duration, _) async {
        intervals.add(duration.inSeconds);
        if (intervals.length == 75) server.status = 'COMPLETED';
      },
    );
    addTearDown(server.dispose);
    final result = await server.repository.upload(
      null,
      null,
      pending: const PendingAudioUpload(
        'audio-one',
        AudioUploadStage.processing,
      ),
      cancelToken: CancelToken(),
      savePending: (_) async {},
    );
    expect(result.mediaId, 'audio-one');
    expect(intervals.take(5), [1, 2, 4, 8, 10]);
    expect(intervals.skip(4), everyElement(10));
    expect(server.paths, hasLength(76));
    expect(server.paths, everyElement('/api/v1/media/audio-one'));
  });

  test('PUT无进展超时是可重试失败，保留身份且不取消队列token', () async {
    final server = _Server(
      timing: const AudioTransferTiming(idle: Duration(milliseconds: 30)),
    );
    addTearDown(server.dispose);
    final saved = <PendingAudioUpload>[];
    final cancel = CancelToken();
    CancelToken? requestCancel;
    server.storage.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          requestCancel = request.cancelToken;
          request.cancelToken!.whenCancel.then(handler.reject);
        },
      ),
    );
    await expectLater(
      server.repository.upload(
        input,
        audioPolicy,
        cancelToken: cancel,
        savePending: (p) async => saved.add(p),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (e) => e.reason,
          '失败原因',
          FailureReason.timeout,
        ),
      ),
    );
    expect(cancel.isCancelled, isFalse);
    expect(requestCancel!.isCancelled, isTrue);
    expect(saved.single.mediaId, 'audio-one');
    expect(saved.single.stage, AudioUploadStage.uploading);
    expect(server.paths, ['/api/v1/media/upload-url']);
  });

  for (final stage in [
    null,
    AudioUploadStage.uploading,
    AudioUploadStage.confirming,
  ]) {
    test('预算在${stage?.name ?? '新签发'}失败保留身份，不自动新建或重复传输', () async {
      final code = stage == null ? 42902 : 42901;
      final path = switch (stage) {
        null => '/api/v1/media/upload-url',
        AudioUploadStage.uploading => '/api/v1/media/audio-one/upload-url',
        _ => '/api/v1/media/upload-done',
      };
      final server = _Server(
        status: 'UPLOADING',
        errorCode: code,
        errorPath: path,
      );
      addTearDown(server.dispose);
      final original = stage == null
          ? null
          : PendingAudioUpload('audio-one', stage);
      await expectLater(
        server.repository.upload(
          input,
          audioPolicy,
          pending: original,
          cancelToken: CancelToken(),
          savePending: (_) async => fail('失败不改已有身份'),
        ),
        throwsA(isA<ApiFailure>().having((e) => e.businessCode, '预算码', code)),
      );
      expect(server.paths, [
        if (stage != null) '/api/v1/media/audio-one',
        path,
      ]);
      expect(await File(input.path).exists(), isTrue);
    });
  }

  test('身份持久化失败不能开始 PUT', () async {
    final server = _Server();
    addTearDown(server.dispose);
    server.storage.interceptors.add(
      InterceptorsWrapper(onRequest: (_, _) => fail('不得 PUT')),
    );
    await expectLater(
      server.repository.upload(
        input,
        audioPolicy,
        cancelToken: CancelToken(),
        savePending: (_) async => throw StateError('disk full'),
      ),
      throwsStateError,
    );
    expect(server.paths, ['/api/v1/media/upload-url']);
  });
}

class _Server {
  _Server({
    this.status = 'COMPLETED',
    this.purpose = 'RICH_CONTENT_AUDIO',
    Future<void> Function(Duration, CancelToken)? delay,
    AudioTransferTiming timing = const AudioTransferTiming(),
    int? errorCode,
    String? errorPath,
  }) {
    apiDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          paths.add(request.path);
          if (errorCode != null && request.path == errorPath) {
            handler.reject(
              DioException(
                requestOptions: request,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: request,
                  statusCode: 429,
                  data: {'code': errorCode, 'message': '音频操作暂不可用，请稍后重试。'},
                ),
              ),
            );
            return;
          }
          final Object data = switch (request.path) {
            '/api/v1/media/upload-url' => {
              'uploadUrl': 'https://storage.example/put',
              'mediaId': 'audio-one',
              'objectKey': 'audio-one',
              'publicUrl': 'https://storage.example/audio.mp3',
            },
            '/api/v1/media/upload-done' => {
              'processing': true,
              'media': media('PROCESSING'),
            },
            '/api/v1/media/audio-one' => media(status),
            _ => throw StateError('Unexpected ${request.path}'),
          };
          handler.resolve(
            Response(
              requestOptions: request,
              statusCode: 200,
              data: {'code': 0, 'message': 'ok', 'data': data},
            ),
          );
        },
      ),
    );
    repository = ApiAudioUploadRepository(
      WenyouApi(dio: apiDio).getMediaApi(),
      storage,
      coordinator: MediaUploadWorkCoordinator(),
      timing: timing,
      delay: delay ?? (_, _) async {},
    );
  }
  String status;
  final String purpose;
  final apiDio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api/v1'));
  final storage = Dio();
  final paths = <String>[];
  late final ApiAudioUploadRepository repository;
  Map<String, Object?> media(String state) => {
    'id': 'audio-one',
    'userId': 'user',
    'url': 'https://storage.example/audio.mp3',
    'key': 'audio-one',
    'contentType': 'audio/mpeg',
    'size': 16000,
    'durationMs': 1000,
    'purpose': purpose,
    'animated': false,
    'status': state,
    'failureCode': state == 'FAILED' ? 'AUDIO_INVALID' : null,
    'createdAt': '2026-10-16T00:00:00.000Z',
  };
  void dispose() {
    apiDio.close();
    storage.close();
  }
}
