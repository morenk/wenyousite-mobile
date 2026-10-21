import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class MediaRecoveryApiFixture {
  MediaRecoveryApiFixture({MediaUploadDelay? delay}) {
    apiDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) async {
          Object? data;
          if (request.method == 'POST') {
            postCount++;
            if (request.path.endsWith('/media/upload-url')) {
              allocateCount++;
            } else if (request.path.endsWith('/upload-url')) {
              reissueCount++;
            } else {
              confirmCount++;
            }
            final uploadStatus = request.path.endsWith('/media/upload-url')
                ? allocateStatus
                : request.path.endsWith('/upload-url')
                ? reissueStatus
                : 200;
            if (uploadStatus != 200) {
              handler.reject(
                DioException(
                  requestOptions: request,
                  type: DioExceptionType.badResponse,
                  response: Response<Object>(
                    requestOptions: request,
                    statusCode: uploadStatus,
                    data: {'code': uploadStatus * 100, 'message': 'failure'},
                  ),
                ),
              );
              return;
            }
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
                    data: {
                      'code': confirmCode ?? confirmStatus * 100,
                      'message': 'failure',
                    },
                  ),
                ),
              );
              return;
            }
            data = request.path.endsWith('/upload-url')
                ? {
                    'uploadUrl': uploadUrl,
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
          if (putStatus != 200) {
            handler.reject(
              DioException(
                requestOptions: request,
                type: DioExceptionType.badResponse,
                response: Response<Object>(
                  requestOptions: request,
                  statusCode: putStatus,
                ),
              ),
            );
            return;
          }
          if (putFails) {
            handler.reject(
              DioException(
                requestOptions: request,
                type: DioExceptionType.connectionTimeout,
              ),
            );
            return;
          }
          if (completeAfterPut) status = 'COMPLETED';
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
  var uploadUrl = 'https://s3.example/upload';
  int? confirmCode;
  var allocateStatus = 200, reissueStatus = 200;
  var allocateCount = 0, reissueCount = 0, confirmCount = 0;
  var putFails = false, completeAfterPut = false;
  var putStatus = 200;
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

class MediaRecoveryTaskHarness {
  MediaRecoveryTaskHarness(MediaRecoveryApiFixture fixture)
    : container = ProviderContainer(
        overrides: [
          mediaUploadGatewayPortProvider.overrideWithValue(fixture.gateway),
        ],
      ) {
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(() {
      subscription.close();
      container.dispose();
    });
  }
  final ProviderContainer container;
  final provider = mediaUploadTaskControllerProvider(Object());
  MediaUploadTaskController get controller => container.read(provider.notifier);
  MediaUploadTaskState get state => container.read(provider);
}
