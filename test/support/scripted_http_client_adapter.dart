import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef ScriptedHttpHandler =
    Future<ScriptedHttpResponse> Function(RequestOptions request);

class ScriptedHttpResponse {
  const ScriptedHttpResponse({
    required this.statusCode,
    this.data,
    this.headers = const {},
  });

  final int statusCode;
  final Object? data;
  final Map<String, List<String>> headers;

  factory ScriptedHttpResponse.json(
    Object? data, {
    int statusCode = 200,
    Map<String, List<String>> headers = const {},
  }) {
    return ScriptedHttpResponse(
      statusCode: statusCode,
      data: data,
      headers: {
        Headers.contentTypeHeader: const [Headers.jsonContentType],
        ...headers,
      },
    );
  }
}

/// A deterministic Dio transport for tests that need to cross the generated
/// client boundary without reaching the public development environment.
class ScriptedHttpClientAdapter implements HttpClientAdapter {
  ScriptedHttpClientAdapter(this._handler);

  final ScriptedHttpHandler _handler;
  final List<RequestOptions> requests = [];
  var isClosed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (isClosed) {
      throw StateError('ScriptedHttpClientAdapter is closed.');
    }
    requests.add(options);
    final response = await _handler(options);
    final body = response.data is String
        ? response.data! as String
        : jsonEncode(response.data);
    return ResponseBody.fromString(
      body,
      response.statusCode,
      headers: response.headers,
    );
  }

  @override
  void close({bool force = false}) {
    isClosed = true;
  }
}
