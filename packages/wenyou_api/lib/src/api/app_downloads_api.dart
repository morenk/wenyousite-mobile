//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'dart:typed_data';
import 'package:wenyou_api/src/api_util.dart';
import 'package:wenyou_api/src/model/api_error_envelope.dart';
import 'package:wenyou_api/src/model/app_downloads_info200_response.dart';

class AppDownloadsApi {

  final Dio _dio;

  final Serializers _serializers;

  const AppDownloadsApi(this._dio, this._serializers);

  /// appDownloadsFile
  ///
  ///
  /// Parameters:
  /// * [buildNumber]
  /// * [range] - 仅单段 bytes=start-end、start- 或 -suffix；非法/多段为 416
  /// * [ifRange] - 匹配 ETag 或 Last-Modified 才应用 Range；不匹配发送完整文件
  /// * [xMarkdownContractVersion] - 声明 6 以读取原始角色提及源和稳定目标投影；省略/低版本安全降级响应副本，不能回写 v6 正文。服务端全局 Markdown 仍为 5
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Uint8List] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Uint8List>> appDownloadsFile({
    required int buildNumber,
    String? range,
    String? ifRange,
    int? xMarkdownContractVersion,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/app-downloads/android/{buildNumber}/file'.replaceAll('{' r'buildNumber' '}', encodeQueryParameter(_serializers, buildNumber, const FullType(int)).toString());
    final _options = Options(
      method: r'GET',
      responseType: ResponseType.bytes,
      headers: <String, dynamic>{
        if (range != null) r'Range': range,
        if (ifRange != null) r'If-Range': ifRange,
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

    Uint8List? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : rawResponse as Uint8List;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Uint8List>(
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

  /// appDownloadsHead
  ///
  ///
  /// Parameters:
  /// * [buildNumber]
  /// * [range] - 仅单段 bytes=start-end、start- 或 -suffix；非法/多段为 416
  /// * [ifRange] - 匹配 ETag 或 Last-Modified 才应用 Range；不匹配发送完整文件
  /// * [xMarkdownContractVersion] - 声明 6 以读取原始角色提及源和稳定目标投影；省略/低版本安全降级响应副本，不能回写 v6 正文。服务端全局 Markdown 仍为 5
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Uint8List] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Uint8List>> appDownloadsHead({
    required int buildNumber,
    String? range,
    String? ifRange,
    int? xMarkdownContractVersion,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/app-downloads/android/{buildNumber}/file'.replaceAll('{' r'buildNumber' '}', encodeQueryParameter(_serializers, buildNumber, const FullType(int)).toString());
    final _options = Options(
      method: r'HEAD',
      responseType: ResponseType.bytes,
      headers: <String, dynamic>{
        if (range != null) r'Range': range,
        if (ifRange != null) r'If-Range': ifRange,
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

    Uint8List? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : rawResponse as Uint8List;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Uint8List>(
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

  /// 匿名读取当前 Android 下载信息；仅 JSON，不预取 APK
  /// release/status 表示全局发布及缓存可用性，不因当前访客次数耗尽改为 paused；不扣下载次数。可签发/续签随机浏览器 Cookie，需同源携带；客户端不自行生成标识。旧 APP 无需新增此调用，直接 HEAD/GET 保持兼容。
  ///
  /// Parameters:
  /// * [xMarkdownContractVersion] - 声明 6 以读取原始角色提及源和稳定目标投影；省略/低版本安全降级响应副本，不能回写 v6 正文。服务端全局 Markdown 仍为 5
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [AppDownloadsInfo200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AppDownloadsInfo200Response>> appDownloadsInfo({
    int? xMarkdownContractVersion,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/app-downloads/android';
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

    AppDownloadsInfo200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AppDownloadsInfo200Response),
      ) as AppDownloadsInfo200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AppDownloadsInfo200Response>(
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
