//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:wenyou_api/src/api_util.dart';
import 'package:wenyou_api/src/model/api_error_envelope.dart';
import 'package:wenyou_api/src/model/gallery_list200_response.dart';

class ImageGalleryApi {

  final Dio _dio;

  final Serializers _serializers;

  const ImageGalleryApi(this._dio, this._serializers);

  /// 从点击图片锚点双向浏览当前阅读范围的普通图片
  ///
  ///
  /// Parameters:
  /// * [scope]
  /// * [scopeId]
  /// * [anchorId]
  /// * [anchorIndex]
  /// * [anchorVersion]
  /// * [order]
  /// * [authorId]
  /// * [cursor]
  /// * [limit]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GalleryList200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GalleryList200Response>> galleryList({
    required String scope,
    required String scopeId,
    String? anchorId,
    num? anchorIndex,
    num? anchorVersion,
    String? order,
    String? authorId,
    String? cursor,
    num? limit = 20,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/image-gallery';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearer',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      r'scope': encodeQueryParameter(_serializers, scope, const FullType(String)),
      r'scopeId': encodeQueryParameter(_serializers, scopeId, const FullType(String)),
      if (anchorId != null) r'anchorId': encodeQueryParameter(_serializers, anchorId, const FullType(String)),
      if (anchorIndex != null) r'anchorIndex': encodeQueryParameter(_serializers, anchorIndex, const FullType(num)),
      if (anchorVersion != null) r'anchorVersion': encodeQueryParameter(_serializers, anchorVersion, const FullType(num)),
      if (order != null) r'order': encodeQueryParameter(_serializers, order, const FullType(String)),
      if (authorId != null) r'authorId': encodeQueryParameter(_serializers, authorId, const FullType(String)),
      if (cursor != null) r'cursor': encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(num)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GalleryList200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(GalleryList200Response),
      ) as GalleryList200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GalleryList200Response>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

}
