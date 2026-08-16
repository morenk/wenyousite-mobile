import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_call.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

void main() {
  test(
    'runApiCall translates DioException and preserves request metadata',
    () async {
      final request = RequestOptions(
        path: '/search',
        headers: const {'X-Request-ID': 'request-from-client'},
      );

      await expectLater(
        runApiCall<void>(() async {
          throw DioException(
            requestOptions: request,
            response: Response<void>(
              requestOptions: request,
              statusCode: 429,
              headers: Headers.fromMap({
                'x-request-id': ['request-from-server'],
                'retry-after': ['3'],
              }),
              data: null,
            ),
            type: DioExceptionType.badResponse,
          );
        }),
        throwsA(
          isA<ApiFailure>()
              .having(
                (failure) => failure.requestId,
                'requestId',
                'request-from-server',
              )
              .having(
                (failure) => failure.retryAfter,
                'retryAfter',
                const Duration(seconds: 3),
              ),
        ),
      );
    },
  );

  test('runApiCall leaves domain and mapping failures untouched', () async {
    const failure = ApiFailure(userMessage: 'response is incomplete');

    await expectLater(
      runApiCall<void>(() async => throw failure),
      throwsA(same(failure)),
    );
  });
}
