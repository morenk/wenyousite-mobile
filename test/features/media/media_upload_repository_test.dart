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
        bytes: Uint8List.fromList(const [0x89, 0x50, 0x4e, 0x47, 1]),
      ),
      onProgress: (value) => progress.add(value.stage),
    );

    expect(result.mediaId, 'media-one');
    expect(result.url, 'https://cdn.example.com/scene.png');
    expect(result.width, 1200);
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
          bytes: Uint8List.fromList(const [0x89, 0x50, 0x4e, 0x47]),
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
}

class _MockMediaApi extends Mock implements MediaApi {}

Response<MediaGetUploadUrl201Response> _uploadUrlResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/media/upload-url'),
    data: MediaGetUploadUrl201Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..uploadUrl = 'https://s3.example.com/presigned?secret=value'
            ..mediaId = 'media-one'
            ..objectKey = 'uploads/scene.png'
            ..publicUrl = 'https://cdn.example.com/scene.png',
        ),
    ),
  );
}

Response<MediaConfirmUpload200Response> _confirmResponse(
  MediaResponseDtoStatusEnum status,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/media/upload-done'),
    data: MediaConfirmUpload200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..processing = status != MediaResponseDtoStatusEnum.COMPLETED
            ..media.replace(_media(status)),
        ),
    ),
  );
}

Response<MediaGetMedia200Response> _statusResponse(
  MediaResponseDtoStatusEnum status,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/media/media-one'),
    data: MediaGetMedia200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(_media(status)),
    ),
  );
}

MediaResponseDto _media(MediaResponseDtoStatusEnum status) {
  return MediaResponseDto(
    (builder) => builder
      ..id = 'media-one'
      ..userId = 'user-one'
      ..url = 'https://cdn.example.com/scene.png'
      ..key = 'uploads/scene.png'
      ..contentType = 'image/png'
      ..size = 5
      ..width = 1200
      ..height = 800
      ..status = status
      ..createdAt = DateTime.utc(2026, 8, 10),
  );
}
