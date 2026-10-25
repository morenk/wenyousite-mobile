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
import 'package:wenyou_api/src/model/meta_get_meta200_response.dart';
import 'package:wenyou_api/src/model/text_fonts_get_catalog200_response.dart';
import 'package:wenyou_api/src/model/text_fonts_get_runtime_policy200_response.dart';
import 'package:wenyou_api/src/model/text_fonts_v2_get_catalog200_response.dart';
import 'package:wenyou_api/src/model/text_fonts_v2_get_runtime_policy200_response.dart';
import 'package:wenyou_api/src/model/text_fonts_v2_get_version200_response.dart';

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
  /// * [xTextFontVersion] - 声明 2 读取 v1/v2 混合字体源；1 仅保留 v1，缺失去除两版字体。降级副本不能覆盖未支持字体的原文。颜色能力单独协商。
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
  /// * [xTextFontVersion] - 声明 2 读取 v1/v2 混合字体源；1 仅保留 v1，缺失去除两版字体。降级副本不能覆盖未支持字体的原文。颜色能力单独协商。
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
  /// * [xTextFontVersion] - 声明 2 读取 v1/v2 混合字体源；1 仅保留 v1，缺失去除两版字体。降级副本不能覆盖未支持字体的原文。颜色能力单独协商。
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

  /// textFontsV2GetAsset
  ///
  ///
  /// Parameters:
  /// * [versionId]
  /// * [asset]
  /// * [xMarkdownContractVersion] - 声明 6 以读取原始角色提及源和稳定目标投影；省略/低版本安全降级响应副本，不能回写 v6 正文。服务端全局 Markdown 仍为 5
  /// * [xTextColorVersion] - 声明 1 读取文本颜色原始源码；缺失只返回安全去色副本，不能覆盖彩色原文。
  /// * [xTextFontVersion] - 声明 2 读取 v1/v2 混合字体源；1 仅保留 v1，缺失去除两版字体。降级副本不能覆盖未支持字体的原文。颜色能力单独协商。
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Uint8List] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Uint8List>> textFontsV2GetAsset({
    required String versionId,
    required String asset,
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
    final _path = r'/api/v1/meta/text-fonts/v2/versions/{versionId}/assets/{asset}'.replaceAll('{' r'versionId' '}', encodeQueryParameter(_serializers, versionId, const FullType(String)).toString()).replaceAll('{' r'asset' '}', encodeQueryParameter(_serializers, asset, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      responseType: ResponseType.bytes,
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

  /// textFontsV2GetCatalog
  ///
  ///
  /// Parameters:
  /// * [limit] - 最多项数；服务端按完整 UTF-8 JSON 信封 65536 字节上限提前截页，必须跟随 nextCursor。
  /// * [cursor] - 服务端不透明游标，绑定 releaseId、revision、limit；目录变化返回 409/40927，清空游标重取。
  /// * [xMarkdownContractVersion] - 声明 6 以读取原始角色提及源和稳定目标投影；省略/低版本安全降级响应副本，不能回写 v6 正文。服务端全局 Markdown 仍为 5
  /// * [xTextColorVersion] - 声明 1 读取文本颜色原始源码；缺失只返回安全去色副本，不能覆盖彩色原文。
  /// * [xTextFontVersion] - 声明 2 读取 v1/v2 混合字体源；1 仅保留 v1，缺失去除两版字体。降级副本不能覆盖未支持字体的原文。颜色能力单独协商。
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TextFontsV2GetCatalog200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TextFontsV2GetCatalog200Response>> textFontsV2GetCatalog({
    int? limit = 100,
    String? cursor,
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
    final _path = r'/api/v1/meta/text-fonts/v2';
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

    final _queryParameters = <String, dynamic>{
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (cursor != null) r'cursor': encodeQueryParameter(_serializers, cursor, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    TextFontsV2GetCatalog200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TextFontsV2GetCatalog200Response),
      ) as TextFontsV2GetCatalog200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TextFontsV2GetCatalog200Response>(
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

  /// textFontsV2GetRuntimePolicy
  ///
  ///
  /// Parameters:
  /// * [xMarkdownContractVersion] - 声明 6 以读取原始角色提及源和稳定目标投影；省略/低版本安全降级响应副本，不能回写 v6 正文。服务端全局 Markdown 仍为 5
  /// * [xTextColorVersion] - 声明 1 读取文本颜色原始源码；缺失只返回安全去色副本，不能覆盖彩色原文。
  /// * [xTextFontVersion] - 声明 2 读取 v1/v2 混合字体源；1 仅保留 v1，缺失去除两版字体。降级副本不能覆盖未支持字体的原文。颜色能力单独协商。
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TextFontsV2GetRuntimePolicy200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TextFontsV2GetRuntimePolicy200Response>> textFontsV2GetRuntimePolicy({
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
    final _path = r'/api/v1/meta/text-fonts/v2/runtime-policy';
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

    TextFontsV2GetRuntimePolicy200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TextFontsV2GetRuntimePolicy200Response),
      ) as TextFontsV2GetRuntimePolicy200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TextFontsV2GetRuntimePolicy200Response>(
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

  /// textFontsV2GetVersion
  ///
  ///
  /// Parameters:
  /// * [versionId]
  /// * [xMarkdownContractVersion] - 声明 6 以读取原始角色提及源和稳定目标投影；省略/低版本安全降级响应副本，不能回写 v6 正文。服务端全局 Markdown 仍为 5
  /// * [xTextColorVersion] - 声明 1 读取文本颜色原始源码；缺失只返回安全去色副本，不能覆盖彩色原文。
  /// * [xTextFontVersion] - 声明 2 读取 v1/v2 混合字体源；1 仅保留 v1，缺失去除两版字体。降级副本不能覆盖未支持字体的原文。颜色能力单独协商。
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TextFontsV2GetVersion200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TextFontsV2GetVersion200Response>> textFontsV2GetVersion({
    required String versionId,
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
    final _path = r'/api/v1/meta/text-fonts/v2/versions/{versionId}'.replaceAll('{' r'versionId' '}', encodeQueryParameter(_serializers, versionId, const FullType(String)).toString());
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

    TextFontsV2GetVersion200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TextFontsV2GetVersion200Response),
      ) as TextFontsV2GetVersion200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TextFontsV2GetVersion200Response>(
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
