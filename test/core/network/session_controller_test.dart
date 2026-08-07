import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(Options());
  });

  test('并发刷新共享一次请求并原子替换双 Token', () async {
    final dio = _MockDio();
    final store = _MemoryTokenStore();
    final controller = SessionController(store, dio);
    await controller.authenticate(
      const SessionTokens(
        accessToken: 'old-access',
        refreshToken: 'old-refresh',
      ),
    );
    when(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: 'auth/refresh'),
        data: {
          'code': 0,
          'message': 'ok',
          'data': {'accessToken': 'new-access', 'refreshToken': 'new-refresh'},
        },
      );
    });

    final results = await Future.wait([
      controller.refresh(),
      controller.refresh(),
    ]);

    expect(
      results.map((tokens) => tokens.accessToken),
      everyElement('new-access'),
    );
    expect(store.value?.refreshToken, 'new-refresh');
    expect(controller.state.isAuthenticated, isTrue);
    verify(
      () => dio.post<Map<String, dynamic>>(
        'auth/refresh',
        data: {'refreshToken': 'old-refresh'},
        options: any(named: 'options'),
      ),
    ).called(1);
  });
}

class _MockDio extends Mock implements Dio {}

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}
