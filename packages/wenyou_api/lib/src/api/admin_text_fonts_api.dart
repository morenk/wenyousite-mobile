//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'dart:typed_data';
import 'package:wenyou_api/src/api_util.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_create201_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_create_submission201_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_detail200_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_enabled200_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_get_job200_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_list200_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_management200_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_preview200_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_process201_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_process_submission201_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_publish201_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_reorder200_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_submission200_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_update200_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_upload201_response.dart';
import 'package:wenyou_api/src/model/admin_text_fonts_withdraw201_response.dart';
import 'package:wenyou_api/src/model/api_error_envelope.dart';
import 'package:wenyou_api/src/model/create_font_submission_dto.dart';
import 'package:wenyou_api/src/model/font_configuration_dto.dart';
import 'package:wenyou_api/src/model/font_enabled_dto.dart';
import 'package:wenyou_api/src/model/font_publish_dto.dart';
import 'package:wenyou_api/src/model/font_withdraw_dto.dart';
import 'package:wenyou_api/src/model/process_font_submission_dto.dart';
import 'package:wenyou_api/src/model/reorder_fonts_dto.dart';
import 'package:wenyou_api/src/model/update_font_configuration_dto.dart';

class AdminTextFontsApi {

  final Dio _dio;

  final Serializers _serializers;

  const AdminTextFontsApi(this._dio, this._serializers);

  /// adminTextFontsAsset
  ///
  ///
  /// Parameters:
  /// * [versionId]
  /// * [asset]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  Future<Response<Uint8List>> adminTextFontsAsset({
    required String versionId,
    required String asset,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/versions/{versionId}/assets/{asset}'.replaceAll('{' r'versionId' '}', encodeQueryParameter(_serializers, versionId, const FullType(String)).toString()).replaceAll('{' r'asset' '}', encodeQueryParameter(_serializers, asset, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      responseType: ResponseType.bytes,
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
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

  /// adminTextFontsCreate
  ///
  ///
  /// Parameters:
  /// * [fontConfigurationDto]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsCreate201Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsCreate201Response>> adminTextFontsCreate({
    required FontConfigurationDto fontConfigurationDto,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(FontConfigurationDto);
      _bodyData = _serializers.serialize(fontConfigurationDto, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    AdminTextFontsCreate201Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsCreate201Response),
      ) as AdminTextFontsCreate201Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsCreate201Response>(
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

  /// adminTextFontsCreateSubmission
  ///
  ///
  /// Parameters:
  /// * [createFontSubmissionDto]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsCreateSubmission201Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsCreateSubmission201Response>> adminTextFontsCreateSubmission({
    required CreateFontSubmissionDto createFontSubmissionDto,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/submissions';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(CreateFontSubmissionDto);
      _bodyData = _serializers.serialize(createFontSubmissionDto, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    AdminTextFontsCreateSubmission201Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsCreateSubmission201Response),
      ) as AdminTextFontsCreateSubmission201Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsCreateSubmission201Response>(
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

  /// adminTextFontsDetail
  ///
  ///
  /// Parameters:
  /// * [familyId]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsDetail200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsDetail200Response>> adminTextFontsDetail({
    required String familyId,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/{familyId}'.replaceAll('{' r'familyId' '}', encodeQueryParameter(_serializers, familyId, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
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

    AdminTextFontsDetail200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsDetail200Response),
      ) as AdminTextFontsDetail200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsDetail200Response>(
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

  /// adminTextFontsEnabled
  ///
  ///
  /// Parameters:
  /// * [familyId]
  /// * [fontEnabledDto]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsEnabled200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsEnabled200Response>> adminTextFontsEnabled({
    required String familyId,
    required FontEnabledDto fontEnabledDto,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/{familyId}/enabled'.replaceAll('{' r'familyId' '}', encodeQueryParameter(_serializers, familyId, const FullType(String)).toString());
    final _options = Options(
      method: r'PATCH',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(FontEnabledDto);
      _bodyData = _serializers.serialize(fontEnabledDto, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    AdminTextFontsEnabled200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsEnabled200Response),
      ) as AdminTextFontsEnabled200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsEnabled200Response>(
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

  /// adminTextFontsGetJob
  ///
  ///
  /// Parameters:
  /// * [jobId]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsGetJob200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsGetJob200Response>> adminTextFontsGetJob({
    required String jobId,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/jobs/{jobId}'.replaceAll('{' r'jobId' '}', encodeQueryParameter(_serializers, jobId, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
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

    AdminTextFontsGetJob200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsGetJob200Response),
      ) as AdminTextFontsGetJob200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsGetJob200Response>(
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

  /// adminTextFontsList
  ///
  ///
  /// Parameters:
  /// * [xCSRFToken] - 管理后台写操作必填
  /// * [limit]
  /// * [after]
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsList200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsList200Response>> adminTextFontsList({
    String? xCSRFToken,
    int? limit = 100,
    String? after,
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
    final _path = r'/api/v1/admin/text-fonts';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (after != null) r'after': encodeQueryParameter(_serializers, after, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    AdminTextFontsList200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsList200Response),
      ) as AdminTextFontsList200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsList200Response>(
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

  /// adminTextFontsManagement
  ///
  ///
  /// Parameters:
  /// * [xCSRFToken] - 管理后台写操作必填
  /// * [q] - 管理展示名称包含匹配；已发布按最后当前版本、未发布按草稿。NFC、去首尾空白、不区分大小写，%/_ 按文字处理。
  /// * [language]
  /// * [status]
  /// * [sort]
  /// * [direction]
  /// * [cursor] - 不透明游标，绑定规范筛选、排序及管理列表修订；变化返回 409/40931，从第一页重取。
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsManagement200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsManagement200Response>> adminTextFontsManagement({
    String? xCSRFToken,
    String? q,
    String? language,
    String? status,
    String? sort = 'createdAt',
    String? direction = 'desc',
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
    final _path = r'/api/v1/admin/text-fonts/management';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (q != null) r'q': encodeQueryParameter(_serializers, q, const FullType(String)),
      if (language != null) r'language': encodeQueryParameter(_serializers, language, const FullType(String)),
      if (status != null) r'status': encodeQueryParameter(_serializers, status, const FullType(String)),
      if (sort != null) r'sort': encodeQueryParameter(_serializers, sort, const FullType(String)),
      if (direction != null) r'direction': encodeQueryParameter(_serializers, direction, const FullType(String)),
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

    AdminTextFontsManagement200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsManagement200Response),
      ) as AdminTextFontsManagement200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsManagement200Response>(
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

  /// adminTextFontsPreview
  ///
  ///
  /// Parameters:
  /// * [versionId]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsPreview200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsPreview200Response>> adminTextFontsPreview({
    required String versionId,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/versions/{versionId}/preview'.replaceAll('{' r'versionId' '}', encodeQueryParameter(_serializers, versionId, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
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

    AdminTextFontsPreview200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsPreview200Response),
      ) as AdminTextFontsPreview200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsPreview200Response>(
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

  /// adminTextFontsProcess
  ///
  ///
  /// Parameters:
  /// * [jobId]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsProcess201Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsProcess201Response>> adminTextFontsProcess({
    required String jobId,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/jobs/{jobId}/process'.replaceAll('{' r'jobId' '}', encodeQueryParameter(_serializers, jobId, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
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

    AdminTextFontsProcess201Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsProcess201Response),
      ) as AdminTextFontsProcess201Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsProcess201Response>(
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

  /// adminTextFontsProcessSubmission
  ///
  ///
  /// Parameters:
  /// * [submissionId]
  /// * [processFontSubmissionDto]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsProcessSubmission201Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsProcessSubmission201Response>> adminTextFontsProcessSubmission({
    required String submissionId,
    required ProcessFontSubmissionDto processFontSubmissionDto,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/submissions/{submissionId}/process'.replaceAll('{' r'submissionId' '}', encodeQueryParameter(_serializers, submissionId, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(ProcessFontSubmissionDto);
      _bodyData = _serializers.serialize(processFontSubmissionDto, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    AdminTextFontsProcessSubmission201Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsProcessSubmission201Response),
      ) as AdminTextFontsProcessSubmission201Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsProcessSubmission201Response>(
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

  /// adminTextFontsPublish
  ///
  ///
  /// Parameters:
  /// * [familyId]
  /// * [fontPublishDto]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsPublish201Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsPublish201Response>> adminTextFontsPublish({
    required String familyId,
    required FontPublishDto fontPublishDto,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/{familyId}/publish'.replaceAll('{' r'familyId' '}', encodeQueryParameter(_serializers, familyId, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(FontPublishDto);
      _bodyData = _serializers.serialize(fontPublishDto, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    AdminTextFontsPublish201Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsPublish201Response),
      ) as AdminTextFontsPublish201Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsPublish201Response>(
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

  /// adminTextFontsReorder
  ///
  ///
  /// Parameters:
  /// * [reorderFontsDto]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsReorder200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsReorder200Response>> adminTextFontsReorder({
    required ReorderFontsDto reorderFontsDto,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/order';
    final _options = Options(
      method: r'PUT',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(ReorderFontsDto);
      _bodyData = _serializers.serialize(reorderFontsDto, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    AdminTextFontsReorder200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsReorder200Response),
      ) as AdminTextFontsReorder200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsReorder200Response>(
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

  /// adminTextFontsSubmission
  ///
  ///
  /// Parameters:
  /// * [submissionId]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsSubmission200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsSubmission200Response>> adminTextFontsSubmission({
    required String submissionId,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/submissions/{submissionId}'.replaceAll('{' r'submissionId' '}', encodeQueryParameter(_serializers, submissionId, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
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

    AdminTextFontsSubmission200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsSubmission200Response),
      ) as AdminTextFontsSubmission200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsSubmission200Response>(
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

  /// adminTextFontsUpdate
  ///
  ///
  /// Parameters:
  /// * [familyId]
  /// * [updateFontConfigurationDto]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsUpdate200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsUpdate200Response>> adminTextFontsUpdate({
    required String familyId,
    required UpdateFontConfigurationDto updateFontConfigurationDto,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/{familyId}'.replaceAll('{' r'familyId' '}', encodeQueryParameter(_serializers, familyId, const FullType(String)).toString());
    final _options = Options(
      method: r'PATCH',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(UpdateFontConfigurationDto);
      _bodyData = _serializers.serialize(updateFontConfigurationDto, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    AdminTextFontsUpdate200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsUpdate200Response),
      ) as AdminTextFontsUpdate200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsUpdate200Response>(
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

  /// adminTextFontsUpload
  ///
  ///
  /// Parameters:
  /// * [familyId]
  /// * [expectedFamilyRevision]
  /// * [format] - 只接受单个 TTF/OTF 文件；扩展名不替代 Worker 对实际容器的验证。
  /// * [body]
  /// * [xCSRFToken] - 管理后台写操作必填
  /// * [submissionId] - 简化提交标识；绑定已有提交、授权确认及唯一任务。省略时完全沿用旧授权流程。
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsUpload201Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsUpload201Response>> adminTextFontsUpload({
    required String familyId,
    required int expectedFamilyRevision,
    required String format,
    required MultipartFile body,
    String? xCSRFToken,
    String? submissionId,
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
    final _path = r'/api/v1/admin/text-fonts/{familyId}/sources'.replaceAll('{' r'familyId' '}', encodeQueryParameter(_serializers, familyId, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      contentType: 'application/octet-stream',
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (submissionId != null) r'submissionId': encodeQueryParameter(_serializers, submissionId, const FullType(String)),
      r'expectedFamilyRevision': encodeQueryParameter(_serializers, expectedFamilyRevision, const FullType(int)),
      r'format': encodeQueryParameter(_serializers, format, const FullType(String)),
    };

    dynamic _bodyData;

    try {
      _bodyData = body.finalize();

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
          queryParameters: _queryParameters,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    AdminTextFontsUpload201Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsUpload201Response),
      ) as AdminTextFontsUpload201Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsUpload201Response>(
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

  /// adminTextFontsWithdraw
  ///
  ///
  /// Parameters:
  /// * [versionId]
  /// * [fontWithdrawDto]
  /// * [xCSRFToken] - 管理后台写操作必填
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
  /// Returns a [Future] containing a [Response] with a [AdminTextFontsWithdraw201Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminTextFontsWithdraw201Response>> adminTextFontsWithdraw({
    required String versionId,
    required FontWithdrawDto fontWithdrawDto,
    String? xCSRFToken,
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
    final _path = r'/api/v1/admin/text-fonts/versions/{versionId}/withdraw'.replaceAll('{' r'versionId' '}', encodeQueryParameter(_serializers, versionId, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
        if (xMarkdownContractVersion != null) r'X-Markdown-Contract-Version': xMarkdownContractVersion,
        if (xTextColorVersion != null) r'X-Text-Color-Version': xTextColorVersion,
        if (xTextFontVersion != null) r'X-Text-Font-Version': xTextFontVersion,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'adminSession',
            'keyName': '__Secure-wenyou-admin-session',
            'where': '',
          },{
            'type': 'apiKey',
            'name': 'adminCsrf',
            'keyName': 'X-CSRF-Token',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(FontWithdrawDto);
      _bodyData = _serializers.serialize(fontWithdrawDto, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    AdminTextFontsWithdraw201Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminTextFontsWithdraw201Response),
      ) as AdminTextFontsWithdraw201Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminTextFontsWithdraw201Response>(
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
