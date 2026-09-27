//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:wenyou_api/src/api_util.dart';
import 'package:wenyou_api/src/model/admin_mobile_releases_confirm201_response.dart';
import 'package:wenyou_api/src/model/admin_mobile_releases_create201_response.dart';
import 'package:wenyou_api/src/model/admin_mobile_releases_detail200_response.dart';
import 'package:wenyou_api/src/model/admin_mobile_releases_list200_response.dart';
import 'package:wenyou_api/src/model/admin_mobile_releases_update200_response.dart';
import 'package:wenyou_api/src/model/api_error_envelope.dart';
import 'package:wenyou_api/src/model/create_mobile_release_dto.dart';
import 'package:wenyou_api/src/model/mobile_release_revision_dto.dart';
import 'package:wenyou_api/src/model/update_mobile_release_dto.dart';

class AdminMobileReleasesApi {

  final Dio _dio;

  final Serializers _serializers;

  const AdminMobileReleasesApi(this._dio, this._serializers);

  /// 超级管理员确认当前 revision；已发布文案原子换为确认快照，不触发安装包发布
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [mobileReleaseRevisionDto]
  /// * [xCSRFToken] - 管理后台写操作必填
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [AdminMobileReleasesConfirm201Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminMobileReleasesConfirm201Response>> adminMobileReleasesConfirm({
    required String id,
    required MobileReleaseRevisionDto mobileReleaseRevisionDto,
    String? xCSRFToken,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/admin/mobile-releases/{id}/confirm'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
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
      const _type = FullType(MobileReleaseRevisionDto);
      _bodyData = _serializers.serialize(mobileReleaseRevisionDto, specifiedType: _type);

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

    AdminMobileReleasesConfirm201Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminMobileReleasesConfirm201Response),
      ) as AdminMobileReleasesConfirm201Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminMobileReleasesConfirm201Response>(
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

  /// adminMobileReleasesCreate
  ///
  ///
  /// Parameters:
  /// * [createMobileReleaseDto]
  /// * [xCSRFToken] - 管理后台写操作必填
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [AdminMobileReleasesCreate201Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminMobileReleasesCreate201Response>> adminMobileReleasesCreate({
    required CreateMobileReleaseDto createMobileReleaseDto,
    String? xCSRFToken,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/admin/mobile-releases';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
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
      const _type = FullType(CreateMobileReleaseDto);
      _bodyData = _serializers.serialize(createMobileReleaseDto, specifiedType: _type);

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

    AdminMobileReleasesCreate201Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminMobileReleasesCreate201Response),
      ) as AdminMobileReleasesCreate201Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminMobileReleasesCreate201Response>(
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

  /// adminMobileReleasesDetail
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [xCSRFToken] - 管理后台写操作必填
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [AdminMobileReleasesDetail200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminMobileReleasesDetail200Response>> adminMobileReleasesDetail({
    required String id,
    String? xCSRFToken,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/admin/mobile-releases/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
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

    AdminMobileReleasesDetail200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminMobileReleasesDetail200Response),
      ) as AdminMobileReleasesDetail200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminMobileReleasesDetail200Response>(
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

  /// adminMobileReleasesList
  ///
  ///
  /// Parameters:
  /// * [platform]
  /// * [cursor] - 服务端返回的不透明分页游标；首次请求不传，后续必须原样回传
  /// * [limit] - 每页条数（默认 20，最大 50）
  /// * [xCSRFToken] - 管理后台写操作必填
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [AdminMobileReleasesList200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminMobileReleasesList200Response>> adminMobileReleasesList({
    required String platform,
    String? cursor,
    num? limit = 20,
    String? xCSRFToken,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/admin/mobile-releases';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
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

    AdminMobileReleasesList200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminMobileReleasesList200Response),
      ) as AdminMobileReleasesList200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminMobileReleasesList200Response>(
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

  /// 更新编辑稿；已发布版本仅 SUPER_ADMIN 可修正，旧公开快照保留
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [updateMobileReleaseDto]
  /// * [xCSRFToken] - 管理后台写操作必填
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [AdminMobileReleasesUpdate200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AdminMobileReleasesUpdate200Response>> adminMobileReleasesUpdate({
    required String id,
    required UpdateMobileReleaseDto updateMobileReleaseDto,
    String? xCSRFToken,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/admin/mobile-releases/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
    final _options = Options(
      method: r'PATCH',
      headers: <String, dynamic>{
        if (xCSRFToken != null) r'X-CSRF-Token': xCSRFToken,
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
      const _type = FullType(UpdateMobileReleaseDto);
      _bodyData = _serializers.serialize(updateMobileReleaseDto, specifiedType: _type);

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

    AdminMobileReleasesUpdate200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AdminMobileReleasesUpdate200Response),
      ) as AdminMobileReleasesUpdate200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AdminMobileReleasesUpdate200Response>(
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
