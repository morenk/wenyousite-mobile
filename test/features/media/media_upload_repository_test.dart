import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      CreateUploadUrlDto(
        (builder) => builder
          ..filename = 'fallback.png'
          ..contentType = CreateUploadUrlDtoContentTypeEnum.imageSlashPng
          ..size = 1,
      ),
    );
    registerFallbackValue(
      ConfirmUploadDto((builder) => builder.mediaId = 'fallback'),
    );
  });

  test('预签名 PUT、确认与状态轮询完成后才返回公开原图地址', () async {
    final api = _MockMediaApi();
    final uploadDio = Dio();
    addTearDown(uploadDio.close);
    RequestOptions? putRequest;
    uploadDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          putRequest = options;
          handler.resolve(
            Response<void>(requestOptions: options, statusCode: 200),
          );
        },
      ),
    );
    when(
      () => api.mediaGetUploadUrl(
        createUploadUrlDto: any(named: 'createUploadUrlDto'),
        cancelToken: null,
      ),
    ).thenAnswer((_) async => _uploadUrlResponse());
    when(
      () => api.mediaConfirmUpload(
        confirmUploadDto: any(named: 'confirmUploadDto'),
        cancelToken: null,
      ),
    ).thenAnswer(
      (_) async => _confirmResponse(MediaResponseDtoStatusEnum.PROCESSING),
    );
    when(
      () => api.mediaGetMedia(id: 'media-one', cancelToken: null),
    ).thenAnswer(
      (_) async => _statusResponse(MediaResponseDtoStatusEnum.COMPLETED),
    );
    final progress = <MediaUploadStage>[];
    final repository = ApiMediaUploadRepository(
      api,
      uploadDio,
      delay: (_) async {},
      maxPollAttempts: 2,
    );

    final result = await repository.uploadImage(
      MediaUploadInput(
        filename: 'scene.png',
        declaredContentType: 'image/png',
        bytes: _pngBytes(),
      ),
      onProgress: (value) => progress.add(value.stage),
    );

    expect(result.mediaId, 'media-one');
    expect(result.url, 'https://cdn.example.com/scene.png');
    expect(result.thumbnailUrl, 'https://cdn.example.com/scene-thumb.webp');
    expect(result.feedUrl, 'https://cdn.example.com/scene-feed.webp');
    expect(result.mediumUrl, 'https://cdn.example.com/scene-medium.webp');
    expect(result.animated, isFalse);
    expect(result.width, 1200);
    final uploadRequest =
        verify(
              () => api.mediaGetUploadUrl(
                createUploadUrlDto: captureAny(named: 'createUploadUrlDto'),
                cancelToken: null,
              ),
            ).captured.single
            as CreateUploadUrlDto;
    expect(uploadRequest.purpose, CreateUploadUrlDtoPurposeEnum.RICH_CONTENT);
    expect(putRequest?.method, 'PUT');
    expect(
      putRequest?.uri.toString(),
      'https://s3.example.com/presigned?secret=value',
    );
    expect(putRequest?.contentType, 'image/png');
    expect(putRequest?.headers['Authorization'], isNull);
    expect(
      progress,
      containsAllInOrder([
        MediaUploadStage.preparing,
        MediaUploadStage.uploading,
        MediaUploadStage.confirming,
        MediaUploadStage.processing,
      ]),
    );
  });

  final purposeCases =
      <
        ({
          MediaUploadPurpose input,
          CreateUploadUrlDtoPurposeEnum request,
          MediaResponseDtoPurposeEnum response,
        })
      >[
        (
          input: MediaUploadPurpose.avatar,
          request: CreateUploadUrlDtoPurposeEnum.AVATAR,
          response: MediaResponseDtoPurposeEnum.AVATAR,
        ),
        (
          input: MediaUploadPurpose.profileCover,
          request: CreateUploadUrlDtoPurposeEnum.PROFILE_COVER,
          response: MediaResponseDtoPurposeEnum.PROFILE_COVER,
        ),
        (
          input: MediaUploadPurpose.directMessage,
          request: CreateUploadUrlDtoPurposeEnum.DIRECT_MESSAGE,
          response: MediaResponseDtoPurposeEnum.DIRECT_MESSAGE,
        ),
        (
          input: MediaUploadPurpose.moment,
          request: CreateUploadUrlDtoPurposeEnum.MOMENT,
          response: MediaResponseDtoPurposeEnum.MOMENT,
        ),
        (
          input: MediaUploadPurpose.momentComment,
          request: CreateUploadUrlDtoPurposeEnum.MOMENT_COMMENT,
          response: MediaResponseDtoPurposeEnum.MOMENT_COMMENT,
        ),
        (
          input: MediaUploadPurpose.richContent,
          request: CreateUploadUrlDtoPurposeEnum.RICH_CONTENT,
          response: MediaResponseDtoPurposeEnum.RICH_CONTENT,
        ),
        (
          input: MediaUploadPurpose.stickerSource,
          request: CreateUploadUrlDtoPurposeEnum.STICKER_SOURCE,
          response: MediaResponseDtoPurposeEnum.STICKER_SOURCE,
        ),
      ];
  for (final purposeCase in purposeCases) {
    test('${purposeCase.input.name} 用途在申请和完成响应中保持一致', () async {
      final api = _MockMediaApi();
      final uploadDio = _successfulUploadDio();
      addTearDown(uploadDio.close);
      when(
        () => api.mediaGetUploadUrl(
          createUploadUrlDto: any(named: 'createUploadUrlDto'),
          cancelToken: null,
        ),
      ).thenAnswer((_) async => _uploadUrlResponse());
      when(
        () => api.mediaConfirmUpload(
          confirmUploadDto: any(named: 'confirmUploadDto'),
          cancelToken: null,
        ),
      ).thenAnswer(
        (_) async => _confirmResponse(
          MediaResponseDtoStatusEnum.COMPLETED,
          purpose: purposeCase.response,
        ),
      );
      final repository = ApiMediaUploadRepository(api, uploadDio);

      final result = await repository.uploadImage(
        MediaUploadInput(
          filename: 'purpose.png',
          declaredContentType: 'image/png',
          bytes: _pngBytes(),
          purpose: purposeCase.input,
        ),
      );

      expect(result.mediaId, 'media-one');
      final request =
          verify(
                () => api.mediaGetUploadUrl(
                  createUploadUrlDto: captureAny(named: 'createUploadUrlDto'),
                  cancelToken: null,
                ),
              ).captured.single
              as CreateUploadUrlDto;
      expect(request.purpose, purposeCase.request);
    });
  }

  test('确认完成时用途错配会拒绝结果', () async {
    final api = _MockMediaApi();
    final uploadDio = _successfulUploadDio();
    addTearDown(uploadDio.close);
    when(
      () => api.mediaGetUploadUrl(
        createUploadUrlDto: any(named: 'createUploadUrlDto'),
        cancelToken: null,
      ),
    ).thenAnswer((_) async => _uploadUrlResponse());
    when(
      () => api.mediaConfirmUpload(
        confirmUploadDto: any(named: 'confirmUploadDto'),
        cancelToken: null,
      ),
    ).thenAnswer(
      (_) async => _confirmResponse(MediaResponseDtoStatusEnum.COMPLETED),
    );
    final repository = ApiMediaUploadRepository(api, uploadDio);

    await expectLater(
      repository.uploadImage(
        MediaUploadInput(
          filename: 'message.png',
          declaredContentType: 'image/png',
          bytes: _pngBytes(),
          purpose: MediaUploadPurpose.directMessage,
        ),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('用途'),
        ),
      ),
    );
  });

  test('轮询完成时用途错配会拒绝结果', () async {
    final api = _MockMediaApi();
    final uploadDio = _successfulUploadDio();
    addTearDown(uploadDio.close);
    when(
      () => api.mediaGetUploadUrl(
        createUploadUrlDto: any(named: 'createUploadUrlDto'),
        cancelToken: null,
      ),
    ).thenAnswer((_) async => _uploadUrlResponse());
    when(
      () => api.mediaConfirmUpload(
        confirmUploadDto: any(named: 'confirmUploadDto'),
        cancelToken: null,
      ),
    ).thenAnswer(
      (_) async => _confirmResponse(
        MediaResponseDtoStatusEnum.PROCESSING,
        purpose: MediaResponseDtoPurposeEnum.DIRECT_MESSAGE,
      ),
    );
    when(
      () => api.mediaGetMedia(id: 'media-one', cancelToken: null),
    ).thenAnswer(
      (_) async => _statusResponse(MediaResponseDtoStatusEnum.COMPLETED),
    );
    final repository = ApiMediaUploadRepository(
      api,
      uploadDio,
      delay: (_) async {},
      maxPollAttempts: 1,
    );

    await expectLater(
      repository.uploadImage(
        MediaUploadInput(
          filename: 'message.png',
          declaredContentType: 'image/png',
          bytes: _pngBytes(),
          purpose: MediaUploadPurpose.directMessage,
        ),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('用途'),
        ),
      ),
    );
  });

  test('声明类型与真实头字节冲突时在网络请求前拒绝', () async {
    final api = _MockMediaApi();
    final dio = Dio();
    addTearDown(dio.close);
    final repository = ApiMediaUploadRepository(api, dio);

    await expectLater(
      repository.uploadImage(
        MediaUploadInput(
          filename: 'mismatch.png',
          declaredContentType: 'image/png',
          bytes: _jpegBytes(),
        ),
      ),
      throwsA(isA<ApiFailure>()),
    );
    verifyNever(
      () => api.mediaGetUploadUrl(
        createUploadUrlDto: any(named: 'createUploadUrlDto'),
        cancelToken: any(named: 'cancelToken'),
      ),
    );
  });

  test('空文件、超限和未知类型在申请预签名地址前拒绝', () async {
    final api = _MockMediaApi();
    final dio = Dio();
    addTearDown(dio.close);
    final repository = ApiMediaUploadRepository(api, dio);

    await expectLater(
      repository.uploadImage(
        MediaUploadInput(filename: 'empty.png', bytes: Uint8List(0)),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('不能为空'),
        ),
      ),
    );
    await expectLater(
      repository.uploadImage(
        MediaUploadInput(
          filename: 'too-large.png',
          bytes: Uint8List(ApiMediaUploadRepository.maxImageBytes + 1),
        ),
      ),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(
      repository.uploadImage(
        MediaUploadInput(
          filename: 'document.txt',
          bytes: Uint8List.fromList(const [1, 2, 3]),
        ),
      ),
      throwsA(isA<ApiFailure>()),
    );
    verifyNever(
      () => api.mediaGetUploadUrl(
        createUploadUrlDto: any(named: 'createUploadUrlDto'),
        cancelToken: any(named: 'cancelToken'),
      ),
    );
  });

  test('对象存储失败不调用确认端点且不暴露预签名查询参数', () async {
    final api = _MockMediaApi();
    final uploadDio = Dio();
    addTearDown(uploadDio.close);
    uploadDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.sendTimeout,
            ),
          );
        },
      ),
    );
    when(
      () => api.mediaGetUploadUrl(
        createUploadUrlDto: any(named: 'createUploadUrlDto'),
        cancelToken: null,
      ),
    ).thenAnswer((_) async => _uploadUrlResponse());
    final repository = ApiMediaUploadRepository(api, uploadDio);

    await expectLater(
      repository.uploadImage(
        MediaUploadInput(
          filename: 'scene.png',
          declaredContentType: 'image/png',
          bytes: _pngBytes(),
        ),
      ),
      throwsA(
        isA<ApiFailure>()
            .having(
              (failure) => failure.userMessage,
              'message',
              '图片直传失败，请检查网络后重试。',
            )
            .having(
              (failure) => failure.toString(),
              'safe string',
              isNot(contains('secret=value')),
            ),
      ),
    );
    verifyNever(
      () => api.mediaConfirmUpload(
        confirmUploadDto: any(named: 'confirmUploadDto'),
        cancelToken: any(named: 'cancelToken'),
      ),
    );
  });

  test('非本机 HTTP 上传地址在对象存储请求前拒绝', () async {
    final api = _MockMediaApi();
    final uploadDio = _successfulUploadDio();
    addTearDown(uploadDio.close);
    when(
      () => api.mediaGetUploadUrl(
        createUploadUrlDto: any(named: 'createUploadUrlDto'),
        cancelToken: null,
      ),
    ).thenAnswer(
      (_) async => _uploadUrlResponse(
        uploadUrl: 'http://storage.example.com/presigned?secret=value',
      ),
    );
    final repository = ApiMediaUploadRepository(api, uploadDio);

    await expectLater(
      repository.uploadImage(
        MediaUploadInput(
          filename: 'scene.png',
          declaredContentType: 'image/png',
          bytes: _pngBytes(),
        ),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('上传地址'),
        ),
      ),
    );
    verifyNever(
      () => api.mediaConfirmUpload(
        confirmUploadDto: any(named: 'confirmUploadDto'),
        cancelToken: any(named: 'cancelToken'),
      ),
    );
  });

  test('公网结果及任一派生地址使用非本机 HTTP 时拒绝', () async {
    final unsafeCases =
        <
          ({
            String name,
            String url,
            String thumbnail,
            String feed,
            String medium,
          })
        >[
          (
            name: 'original',
            url: 'http://cdn.example.com/scene.png',
            thumbnail: 'https://cdn.example.com/scene-thumb.webp',
            feed: 'https://cdn.example.com/scene-feed.webp',
            medium: 'https://cdn.example.com/scene-medium.webp',
          ),
          (
            name: 'thumbnail',
            url: 'https://cdn.example.com/scene.png',
            thumbnail: 'http://cdn.example.com/scene-thumb.webp',
            feed: 'https://cdn.example.com/scene-feed.webp',
            medium: 'https://cdn.example.com/scene-medium.webp',
          ),
          (
            name: 'feed',
            url: 'https://cdn.example.com/scene.png',
            thumbnail: 'https://cdn.example.com/scene-thumb.webp',
            feed: 'http://cdn.example.com/scene-feed.webp',
            medium: 'https://cdn.example.com/scene-medium.webp',
          ),
          (
            name: 'medium',
            url: 'https://cdn.example.com/scene.png',
            thumbnail: 'https://cdn.example.com/scene-thumb.webp',
            feed: 'https://cdn.example.com/scene-feed.webp',
            medium: 'http://cdn.example.com/scene-medium.webp',
          ),
        ];
    for (final unsafeCase in unsafeCases) {
      final api = _MockMediaApi();
      final uploadDio = _successfulUploadDio();
      addTearDown(uploadDio.close);
      when(
        () => api.mediaGetUploadUrl(
          createUploadUrlDto: any(named: 'createUploadUrlDto'),
          cancelToken: null,
        ),
      ).thenAnswer((_) async => _uploadUrlResponse());
      when(
        () => api.mediaConfirmUpload(
          confirmUploadDto: any(named: 'confirmUploadDto'),
          cancelToken: null,
        ),
      ).thenAnswer(
        (_) async => _confirmResponse(
          MediaResponseDtoStatusEnum.COMPLETED,
          url: unsafeCase.url,
          thumbnailUrl: unsafeCase.thumbnail,
          feedUrl: unsafeCase.feed,
          mediumUrl: unsafeCase.medium,
        ),
      );
      final repository = ApiMediaUploadRepository(api, uploadDio);

      await expectLater(
        repository.uploadImage(
          MediaUploadInput(
            filename: '${unsafeCase.name}.png',
            declaredContentType: 'image/png',
            bytes: _pngBytes(),
          ),
        ),
        throwsA(
          isA<ApiFailure>().having(
            (failure) => failure.userMessage,
            'message',
            contains('公开地址不安全'),
          ),
        ),
        reason: unsafeCase.name,
      );
    }
  });

  test('模拟器回环 HTTP 上传与公开地址保持可用', () async {
    final api = _MockMediaApi();
    final uploadDio = _successfulUploadDio();
    addTearDown(uploadDio.close);
    when(
      () => api.mediaGetUploadUrl(
        createUploadUrlDto: any(named: 'createUploadUrlDto'),
        cancelToken: null,
      ),
    ).thenAnswer(
      (_) async => _uploadUrlResponse(
        uploadUrl: 'http://10.0.2.2:3000/upload/media-one',
      ),
    );
    when(
      () => api.mediaConfirmUpload(
        confirmUploadDto: any(named: 'confirmUploadDto'),
        cancelToken: null,
      ),
    ).thenAnswer(
      (_) async => _confirmResponse(
        MediaResponseDtoStatusEnum.COMPLETED,
        url: 'http://10.0.2.2:3000/media/scene.png',
        thumbnailUrl: 'http://10.0.2.2:3000/media/scene-thumb.webp',
        feedUrl: 'http://10.0.2.2:3000/media/scene-feed.webp',
        mediumUrl: 'http://10.0.2.2:3000/media/scene-medium.webp',
      ),
    );
    final repository = ApiMediaUploadRepository(api, uploadDio);

    final result = await repository.uploadImage(
      MediaUploadInput(
        filename: 'loopback.png',
        declaredContentType: 'image/png',
        bytes: _pngBytes(),
      ),
    );

    expect(result.url, 'http://10.0.2.2:3000/media/scene.png');
  });

  test('application gateway 透传进度并幂等取消 data 操作', () async {
    final repository = _RecordingMediaUploadRepository();
    final gateway = RepositoryMediaUploadGateway(repository);
    final input = MediaUploadInput(
      filename: 'adapter.png',
      declaredContentType: 'image/png',
      bytes: Uint8List.fromList(const [0x89, 0x50, 0x4e, 0x47]),
    );
    final progress = <MediaUploadProgress>[];

    final operation = gateway.startImageUpload(input, onProgress: progress.add);
    await Future<void>.delayed(Duration.zero);
    repository.emit(
      const MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: 2,
        totalBytes: 4,
      ),
    );
    operation.cancel();
    operation.cancel();

    expect(repository.input, same(input));
    expect(repository.cancelToken?.isCancelled, isTrue);
    expect(progress.last.fraction, .5);

    const image = UploadedEditorImage(
      mediaId: 'adapter-image',
      url: 'https://cdn.example.com/adapter.png',
    );
    repository.complete(image);
    expect(await operation.result, same(image));
  });
}

class _MockMediaApi extends Mock implements MediaApi {}

class _RecordingMediaUploadRepository implements MediaUploadRepository {
  final _completer = Completer<UploadedEditorImage>();
  MediaUploadInput? input;
  CancelToken? cancelToken;
  void Function(MediaUploadProgress progress)? onProgress;

  @override
  Future<UploadedEditorImage> uploadImage(
    MediaUploadInput input, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    this.input = input;
    this.cancelToken = cancelToken;
    this.onProgress = onProgress;
    return _completer.future;
  }

  void emit(MediaUploadProgress progress) => onProgress?.call(progress);

  void complete(UploadedEditorImage image) => _completer.complete(image);
}

Response<MediaGetUploadUrl201Response> _uploadUrlResponse({
  String uploadUrl = 'https://s3.example.com/presigned?secret=value',
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/media/upload-url'),
    data: MediaGetUploadUrl201Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..uploadUrl = uploadUrl
            ..mediaId = 'media-one'
            ..objectKey = 'uploads/scene.png'
            ..publicUrl = 'https://cdn.example.com/scene.png',
        ),
    ),
  );
}

Response<MediaConfirmUpload200Response> _confirmResponse(
  MediaResponseDtoStatusEnum status, {
  MediaResponseDtoPurposeEnum purpose =
      MediaResponseDtoPurposeEnum.RICH_CONTENT,
  String url = 'https://cdn.example.com/scene.png',
  String thumbnailUrl = 'https://cdn.example.com/scene-thumb.webp',
  String feedUrl = 'https://cdn.example.com/scene-feed.webp',
  String mediumUrl = 'https://cdn.example.com/scene-medium.webp',
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/media/upload-done'),
    data: MediaConfirmUpload200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..processing = status != MediaResponseDtoStatusEnum.COMPLETED
            ..media.replace(
              _media(
                status,
                purpose: purpose,
                url: url,
                thumbnailUrl: thumbnailUrl,
                feedUrl: feedUrl,
                mediumUrl: mediumUrl,
              ),
            ),
        ),
    ),
  );
}

Response<MediaGetMedia200Response> _statusResponse(
  MediaResponseDtoStatusEnum status, {
  MediaResponseDtoPurposeEnum purpose =
      MediaResponseDtoPurposeEnum.RICH_CONTENT,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/media/media-one'),
    data: MediaGetMedia200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(_media(status, purpose: purpose)),
    ),
  );
}

MediaResponseDto _media(
  MediaResponseDtoStatusEnum status, {
  MediaResponseDtoPurposeEnum purpose =
      MediaResponseDtoPurposeEnum.RICH_CONTENT,
  String url = 'https://cdn.example.com/scene.png',
  String thumbnailUrl = 'https://cdn.example.com/scene-thumb.webp',
  String feedUrl = 'https://cdn.example.com/scene-feed.webp',
  String mediumUrl = 'https://cdn.example.com/scene-medium.webp',
}) {
  return MediaResponseDto(
    (builder) => builder
      ..id = 'media-one'
      ..userId = 'user-one'
      ..url = url
      ..thumbnailUrl = thumbnailUrl
      ..feedUrl = feedUrl
      ..mediumUrl = mediumUrl
      ..key = 'uploads/scene.png'
      ..contentType = 'image/png'
      ..size = 5
      ..width = 1200
      ..height = 800
      ..purpose = purpose
      ..animated = false
      ..status = status
      ..createdAt = DateTime.utc(2026, 8, 10),
  );
}

Dio _successfulUploadDio() {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response<void>(requestOptions: options, statusCode: 200),
        );
      },
    ),
  );
  return dio;
}

Uint8List _pngBytes() =>
    Uint8List.fromList(const [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

Uint8List _jpegBytes() => Uint8List.fromList(const [0xff, 0xd8, 0xff]);
