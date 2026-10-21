import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transfer_deadline.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transfer_failure.dart';

typedef TextFontFetch =
    Future<Uint8List> Function(
      Uri uri,
      int limit,
      String contentType,
      CancelToken cancel,
    );

/// 独立公开读取，不携带会话，不自动重放；所有重试由字体账本调度。
class TextFontTransport {
  TextFontTransport({
    Dio? dio,
    this.firstResponseTimeout = const Duration(seconds: 15),
    this.progressTimeout = const Duration(seconds: 15),
    this.maximumDuration = const Duration(minutes: 10),
    this.elapsed,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 15),
               followRedirects: false,
             ),
           );
  final Dio _dio;
  final Duration firstResponseTimeout;
  final Duration progressTimeout;
  final Duration maximumDuration;
  final Duration Function()? elapsed;

  Future<Uint8List> fetch(
    Uri uri,
    int limit,
    String contentType,
    CancelToken cancel,
  ) async {
    var timedOut = false;
    final deadline = TextFontTransferDeadline(
      firstResponseTimeout: firstResponseTimeout,
      progressTimeout: progressTimeout,
      maximumDuration: maximumDuration,
      elapsed: elapsed,
      onTimeout: (reason) {
        timedOut = true;
        cancel.cancel(reason);
      },
    );
    void check() {
      if (!deadline.check()) {
        throw const TextFontTransferFailure(
          TextFontTransferFailureKind.temporary,
        );
      }
      if (cancel.isCancelled) {
        throw const TextFontTransferFailure(
          TextFontTransferFailureKind.cancelled,
        );
      }
    }

    try {
      final response = await _dio.get<ResponseBody>(
        uri.toString(),
        cancelToken: cancel,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: progressTimeout,
          followRedirects: false,
          validateStatus: (_) => true,
          headers: {'X-Request-ID': const Uuid().v4()},
        ),
      );
      check();
      deadline.responseReceived();
      final status = response.statusCode;
      if (status != 200) {
        cancel.cancel('rejected-status');
        await response.data?.stream.listen((_) {}).cancel();
        throw TextFontTransferFailure(
          const {408, 429, 500, 502, 503, 504}.contains(status)
              ? TextFontTransferFailureKind.temporary
              : TextFontTransferFailureKind.quarantined,
          retryAfter: parseRetryAfter(
            response.headers.value('retry-after'),
            DateTime.now(),
          ),
        );
      }
      final type = response.headers
          .value('content-type')
          ?.split(';')
          .first
          .trim()
          .toLowerCase();
      if (response.data == null || type != contentType) {
        cancel.cancel('rejected-mime');
        await response.data?.stream.listen((_) {}).cancel();
        throw const FormatException('字体资源MIME不符');
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in response.data!.stream) {
        check();
        if (bytes.length + chunk.length > limit) {
          // 先终止底层来源，否则await-for取消可等待尚未结束的响应体。
          cancel.cancel('length-rejected');
          throw const FormatException('字体资源超出大小');
        }
        if (!deadline.bytesReceived(chunk.length)) {
          throw const TextFontTransferFailure(
            TextFontTransferFailureKind.temporary,
          );
        }
        bytes.add(chunk);
      }
      check();
      return bytes.takeBytes();
    } on DioException catch (error) {
      throw TextFontTransferFailure(
        error.type == DioExceptionType.badCertificate
            ? TextFontTransferFailureKind.quarantined
            : error.type == DioExceptionType.cancel && !timedOut
            ? TextFontTransferFailureKind.cancelled
            : TextFontTransferFailureKind.temporary,
      );
    } on TimeoutException {
      throw const TextFontTransferFailure(
        TextFontTransferFailureKind.temporary,
      );
    } on Object {
      cancel.cancel('failed');
      rethrow;
    } finally {
      deadline.dispose();
    }
  }

  static Duration? parseRetryAfter(String? value, DateTime now) {
    if (value == null) return null;
    if (RegExp(r'^\d+$').hasMatch(value.trim())) {
      final seconds = int.tryParse(value.trim());
      if (seconds != null && seconds <= 2147483647) {
        return Duration(seconds: seconds);
      }
    }
    try {
      final wait = HttpDate.parse(value).difference(now.toUtc());
      return wait.isNegative ? Duration.zero : wait;
    } on Object {
      return null;
    }
  }
}
