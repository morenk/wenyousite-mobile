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

class TextFontResponse {
  const TextFontResponse(this.status, this.bytes, {this.etag});
  final int status;
  final Uint8List bytes;
  final String? etag;
}

typedef TextFontRequest =
    Future<TextFontResponse> Function(
      Uri uri,
      int limit,
      String contentType,
      CancelToken cancel, {
      String? etag,
    });

/// 独立公开读取，不携带会话，不自动重放；所有重试由字体账本调度。
class TextFontTransport {
  TextFontTransport({
    Dio? dio,
    this.firstResponseTimeout = const Duration(seconds: 15),
    this.progressTimeout = const Duration(seconds: 15),
    this.maximumDuration = const Duration(minutes: 10),
    this.elapsed,
    this.onProgress,
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
  final void Function(Uri uri, int receivedBytes)? onProgress;

  Future<Uint8List> fetch(
    Uri uri,
    int limit,
    String contentType,
    CancelToken cancel,
  ) async {
    final result = await request(uri, limit, contentType, cancel);
    if (result.status != 200) {
      throw const TextFontTransferFailure(
        TextFontTransferFailureKind.quarantined,
      );
    }
    return result.bytes;
  }

  Future<TextFontResponse> request(
    Uri uri,
    int limit,
    String contentType,
    CancelToken cancel, {
    String? etag,
  }) async {
    var timedOut = false;
    final transferCancel = CancelToken();
    unawaited(cancel.whenCancel.then((error) => transferCancel.cancel(error)));
    final deadline = TextFontTransferDeadline(
      firstResponseTimeout: firstResponseTimeout,
      progressTimeout: progressTimeout,
      maximumDuration: maximumDuration,
      elapsed: elapsed,
      onTimeout: (reason) {
        timedOut = true;
        cancel.cancel(reason);
        transferCancel.cancel(reason);
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
        cancelToken: transferCancel,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: progressTimeout,
          followRedirects: false,
          validateStatus: (_) => true,
          headers: {'X-Request-ID': const Uuid().v4(), 'If-None-Match': ?etag},
        ),
      );
      check();
      deadline.responseReceived();
      final status = response.statusCode;
      final responseEtag = response.headers.value('etag');
      if (const {304, 404, 409, 410}.contains(status)) {
        // 状态已足够完成判断；错误响应体可能持续不结束，先终止底层读取。
        transferCancel.cancel('status-complete');
        await response.data?.stream.listen((_) {}).cancel();
        return TextFontResponse(status!, Uint8List(0), etag: responseEtag);
      }
      if (status != 200) {
        transferCancel.cancel('rejected-status');
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
        transferCancel.cancel('rejected-mime');
        await response.data?.stream.listen((_) {}).cancel();
        throw const FormatException('字体资源MIME不符');
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in response.data!.stream) {
        check();
        if (bytes.length + chunk.length > limit) {
          // 先终止底层来源，否则await-for取消可等待尚未结束的响应体。
          transferCancel.cancel('length-rejected');
          throw const FormatException('字体资源超出大小');
        }
        if (!deadline.bytesReceived(chunk.length)) {
          throw const TextFontTransferFailure(
            TextFontTransferFailureKind.temporary,
          );
        }
        bytes.add(chunk);
        if (chunk.isNotEmpty) onProgress?.call(uri, bytes.length);
      }
      check();
      return TextFontResponse(200, bytes.takeBytes(), etag: responseEtag);
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
      transferCancel.cancel('failed');
      rethrow;
    } finally {
      deadline.dispose();
      transferCancel.cancel('complete');
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
