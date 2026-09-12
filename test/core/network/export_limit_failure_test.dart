import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

void main() {
  test('下载响应按字节返回 413 时仍提示缩小范围和减少图片', () {
    final request = RequestOptions(path: '/threads/test/export');
    final failure = ApiFailure.fromDio(
      DioException.badResponse(
        statusCode: 413,
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 413,
          data: Uint8List.fromList([123, 125]),
        ),
      ),
    );
    expect(failure.userMessage, contains('缩小范围'));
    expect(failure.userMessage, contains('减少图片'));
    expect(failure.httpStatus, 413);
  });
}
