//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:wenyou_api/src/model/api_error_envelope.dart';
import 'package:wenyou_api/src/model/meta_get_meta200_response.dart';
import 'package:wenyou_api/src/model/text_fonts_get_catalog200_response.dart';
import 'package:wenyou_api/src/model/text_fonts_get_runtime_policy200_response.dart';

class MetaApi {

  final Dio _dio;

  final Serializers _serializers;

  const MetaApi(this._dio, this._serializers);

  /// metaGetMeta
  ///
  ///
  /// Parameters:
  /// * [xMarkdownContractVersion] - 声明 6 以读取原始角色提及源和稳定目标投影；省略/低版本安全降级响应副本，不能回写 v6 正文。服务端全局 Markdown 仍为 5
  /// * [xTextColorVersion] - 声明 1 读取文本颜色原始源码；缺失只返回安全去色副本，不能覆盖彩色原文。
  /// * [xTextFontVersion] - 声明 1 读取字体原始源码；缺失只返回安全去字体副本，不能覆盖字体原文。颜色能力单独协商。
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MetaGetMeta200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MetaGetMeta200Response>> metaGetMeta({
    int? xMarkdownContractVersion,
    int? xTextColorVersion,
    int? xTextFontVersion,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/meta';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
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

    MetaGetMeta200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MetaGetMeta200Response),
      ) as MetaGetMeta200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MetaGetMeta200Response>(
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

  /// textFontsGetCatalog
  ///
  ///
  /// Parameters:
  /// * [xMarkdownContractVersion] - 声明 6 以读取原始角色提及源和稳定目标投影；省略/低版本安全降级响应副本，不能回写 v6 正文。服务端全局 Markdown 仍为 5
  /// * [xTextColorVersion] - 声明 1 读取文本颜色原始源码；缺失只返回安全去色副本，不能覆盖彩色原文。
  /// * [xTextFontVersion] - 声明 1 读取字体原始源码；缺失只返回安全去字体副本，不能覆盖字体原文。颜色能力单独协商。
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TextFontsGetCatalog200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TextFontsGetCatalog200Response>> textFontsGetCatalog({
    int? xMarkdownContractVersion,
    int? xTextColorVersion,
    int? xTextFontVersion,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/meta/text-fonts';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
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

    TextFontsGetCatalog200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TextFontsGetCatalog200Response),
      ) as TextFontsGetCatalog200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TextFontsGetCatalog200Response>(
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

  /// textFontsGetRuntimePolicy
  ///
  ///
  /// Parameters:
  /// * [xMarkdownContractVersion] - 声明 6 以读取原始角色提及源和稳定目标投影；省略/低版本安全降级响应副本，不能回写 v6 正文。服务端全局 Markdown 仍为 5
  /// * [xTextColorVersion] - 声明 1 读取文本颜色原始源码；缺失只返回安全去色副本，不能覆盖彩色原文。
  /// * [xTextFontVersion] - 声明 1 读取字体原始源码；缺失只返回安全去字体副本，不能覆盖字体原文。颜色能力单独协商。
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TextFontsGetRuntimePolicy200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TextFontsGetRuntimePolicy200Response>> textFontsGetRuntimePolicy({
    int? xMarkdownContractVersion,
    int? xTextColorVersion,
    int? xTextFontVersion,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/meta/text-fonts/runtime-policy';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
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

    TextFontsGetRuntimePolicy200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TextFontsGetRuntimePolicy200Response),
      ) as TextFontsGetRuntimePolicy200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TextFontsGetRuntimePolicy200Response>(
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
