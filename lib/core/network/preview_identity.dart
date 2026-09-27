import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/config/app_environment.dart';

/// 私有开发协议 v1；身份探测使用无凭据 Dio，任何失败都阻止业务请求。
class PreviewIdentityVerifier {
  PreviewIdentityVerifier(this.environment, this.probe);
  final AppEnvironment environment;
  final Dio probe;
  Future<void>? _pending;

  Future<void> verify() {
    if (!environment.isPreview) return Future.value();
    return _pending ??= _verify().whenComplete(() => _pending = null);
  }

  Future<void> _verify() async {
    for (final role in ['backend', 'media']) {
      final origin = role == 'backend'
          ? environment.apiOrigin
          : environment.previewMediaOrigin;
      final response = await probe.get<Object?>(
        '$origin/__preview/identity',
        options: Options(followRedirects: false, maxRedirects: 0),
      );
      final expected = <String, Object?>{
        'version': 1,
        'kind': 'wenyou-dev-preview',
        'sessionId': environment.previewSession,
        'runId': environment.previewRun,
        'role': role,
        'resourceId': environment.previewRun,
        'snapshotSha256': environment.previewSnapshotSha,
      };
      final body = response.data;
      if (response.statusCode != 200 ||
          response.headers.value('X-Wenyou-Preview-Run') !=
              environment.previewRun ||
          !(response.headers
                  .value('content-type')
                  ?.startsWith('application/json') ??
              false) ||
          body is! Map<String, dynamic> ||
          body.length != expected.length ||
          expected.entries.any((entry) => body[entry.key] != entry.value)) {
        throw StateError('开发预览资源身份核验失败。');
      }
    }
  }
}

class PreviewIdentityInterceptor extends Interceptor {
  PreviewIdentityInterceptor(this.verifier, {this.mediaUpload = false});
  final PreviewIdentityVerifier verifier;
  final bool mediaUpload;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final environment = verifier.environment;
    if (!environment.isPreview) {
      handler.next(options);
      return;
    }
    final allowedOrigin = mediaUpload
        ? environment.previewMediaOrigin
        : environment.apiOrigin;
    if (options.uri.origin != allowedOrigin) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: StateError('开发预览拒绝访问批次以外的写入服务。'),
        ),
      );
      return;
    }
    verifier.verify().then(
      (_) {
        options.followRedirects = false;
        options.maxRedirects = 0;
        if (!mediaUpload) {
          options.headers['X-Wenyou-Preview-Run'] = environment.previewRun;
        }
        handler.next(options);
      },
      onError: (Object _) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: StateError('开发预览连接已失效，请重新连接后再试。'),
          ),
        );
      },
    );
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!mediaUpload &&
        verifier.environment.isPreview &&
        response.headers.value('X-Wenyou-Preview-Run') !=
            verifier.environment.previewRun) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          error: StateError('开发预览响应身份不匹配。'),
        ),
      );
      return;
    }
    handler.next(response);
  }
}

// 独立于 network_providers，避免 Dio 与其探测连接互相依赖。
final previewProbeDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      followRedirects: false,
    ),
  );
  ref.onDispose(() => dio.close(force: true));
  return dio;
});
