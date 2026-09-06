import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_interceptors.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/search/data/search_repository.dart';

void main() {
  test('搜索匿名可用，登录携带会话以应用服务端拉黑投影', () async {
    final session = SessionController(_Tokens(), _Remote());
    final adapter = _VisibilityAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(RequestContextInterceptor(dio, session));
    final repository = ApiSearchRepository(
      WenyouApi(dio: dio, interceptors: []).getSearchApi(),
    );
    expect(await repository.searchUsers('测试'), hasLength(1));
    expect(adapter.lastAuthorization, isNull);
    await session.authenticate(
      const SessionTokens(
        accessToken: 'fixture-access',
        refreshToken: 'fixture-refresh',
      ),
    );
    expect(await repository.searchUsers('测试'), isEmpty);
    expect(adapter.lastAuthorization, 'Bearer fixture-access');
    await session.logoutLocally();
    expect(await repository.searchUsers('测试'), hasLength(1));
    expect(adapter.lastAuthorization, isNull);
    dio.close();
    session.dispose();
  });
}

class _VisibilityAdapter implements HttpClientAdapter {
  Object? lastAuthorization;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastAuthorization = options.headers['Authorization'];
    return ResponseBody.fromString(
      jsonEncode({
        'code': 0,
        'message': 'ok',
        'data': lastAuthorization == null
            ? [
                {
                  'id': 'blocked-user',
                  'username': '测试',
                  'avatar': null,
                  'bio': null,
                },
              ]
            : [],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _Tokens implements TokenStore {
  SessionTokens? value;
  @override
  Future<SessionTokens?> read() async => value;
  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
  @override
  Future<void> clear() async => value = null;
}

class _Remote extends Fake implements SessionRemote {}
