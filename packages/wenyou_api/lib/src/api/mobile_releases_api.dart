//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:wenyou_api/src/api_util.dart';
import 'package:wenyou_api/src/model/api_error_envelope.dart';
import 'package:wenyou_api/src/model/mobile_releases_detail200_response.dart';
import 'package:wenyou_api/src/model/mobile_releases_list200_response.dart';

class MobileReleasesApi {

  final Dio _dio;

  final Serializers _serializers;

  const MobileReleasesApi(this._dio, this._serializers);

  /// 读取已发布版本说明；不存在或未发布均为 404
  ///
  ///
  /// Parameters:
  /// * [platform]
  /// * [buildNumber]
  /// * [xMarkdownContractVersion] - 声明 6 以读取原始角色提及源和稳定目标投影；省略/低版本安全降级响应副本，不能回写 v6 正文。服务端全局 Markdown 仍为 5
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MobileReleasesDetail200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MobileReleasesDetail200Response>> mobileReleasesDetail({
    required String platform,
    required num buildNumber,
    int? xMarkdownContractVersion,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/mobile-releases/{platform}/{buildNumber}'.replaceAll('{' r'platform' '}', encodeQueryParameter(_serializers, platform, const FullType(String)).toString()).replaceAll('{' r'buildNumber' '}', encodeQueryParameter(_serializers, buildNumber, const FullType(num)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    MobileReleasesDetail200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MobileReleasesDetail200Response),
      ) as MobileReleasesDetail200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MobileReleasesDetail200Response>(
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

  /// 已发布版本历史，按构建号倒序；仅返回公开快照
  ///
  ///
  /// Parameters:
  /// * [platform]
  /// * [cursor] - 服务端返回的不透明分页游标；首次请求不传，后续必须原样回传
  /// * [limit] - 每页条数（默认 20，最大 50）
  /// * [xMarkdownContractVersion] - 声明 6 以读取原始角色提及源和稳定目标投影；省略/低版本安全降级响应副本，不能回写 v6 正文。服务端全局 Markdown 仍为 5
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MobileReleasesList200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MobileReleasesList200Response>> mobileReleasesList({
    required String platform,
    String? cursor,
    num? limit = 20,
    int? xMarkdownContractVersion,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/mobile-releases';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (cursor != null) r'cursor': encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(num)),
      r'platform': encodeQueryParameter(_serializers, platform, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    MobileReleasesList200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MobileReleasesList200Response),
      ) as MobileReleasesList200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MobileReleasesList200Response>(
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
