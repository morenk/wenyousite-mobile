import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/application/image_gallery.dart';

final deviceImageGalleryServiceProvider = Provider<ImageGalleryService>((ref) {
  return DeviceImageGalleryService(
    dio: ref.watch(imageGalleryDownloadClientProvider),
  );
});

final imageGalleryDownloadClientProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 45),
      sendTimeout: const Duration(seconds: 15),
    ),
  );
});

abstract interface class ImageGalleryPlatformBridge {
  Future<String> requestAddPermission();

  Future<void> saveImage({
    required String filePath,
    required String fileName,
    required String mimeType,
  });

  Future<void> openSettings();
}

class MethodChannelImageGalleryBridge implements ImageGalleryPlatformBridge {
  const MethodChannelImageGalleryBridge();

  static const _channel = MethodChannel('site.wenyou.app/image_gallery');

  @override
  Future<String> requestAddPermission() async {
    return await _channel.invokeMethod<String>('requestAddPermission') ??
        'denied';
  }

  @override
  Future<void> saveImage({
    required String filePath,
    required String fileName,
    required String mimeType,
  }) {
    return _channel.invokeMethod<void>('saveImage', {
      'filePath': filePath,
      'fileName': fileName,
      'mimeType': mimeType,
    });
  }

  @override
  Future<void> openSettings() => _channel.invokeMethod<void>('openSettings');
}

class DeviceImageGalleryService implements ImageGalleryService {
  DeviceImageGalleryService({
    required this.dio,
    this.bridge = const MethodChannelImageGalleryBridge(),
    Future<Directory> Function()? temporaryDirectory,
    this.uuid = const Uuid(),
  }) : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  static const _maximumBytes = 10 * 1024 * 1024;
  static const _maximumRedirects = 5;

  final Dio dio;
  final ImageGalleryPlatformBridge bridge;
  final Future<Directory> Function() _temporaryDirectory;
  final Uuid uuid;

  @override
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  ImageGallerySaveOperation startSave(ImageGallerySource source) {
    final cancelToken = CancelToken();
    return ImageGallerySaveOperation(
      result: _save(source, cancelToken),
      cancel: () => cancelToken.cancel('viewer_closed'),
    );
  }

  @override
  Future<void> openSettings() async {
    try {
      await bridge.openSettings();
    } on PlatformException catch (error) {
      throw _platformFailure(error);
    }
  }

  Future<void> _save(ImageGallerySource source, CancelToken cancelToken) async {
    if (!isSupported) {
      throw const ImageGalleryException(userMessage: '当前设备暂不支持保存图片。');
    }
    final permission = await bridge.requestAddPermission();
    if (permission != 'granted') {
      throw ImageGalleryException(
        userMessage: permission == 'settingsRequired'
            ? '请在系统设置中允许温油站添加照片。'
            : '没有获得照片保存权限。',
        settingsRequired: permission == 'settingsRequired',
      );
    }

    File? downloaded;
    try {
      final urls = <String>[source.url, ...source.fallbackUrls];
      Object? lastFailure;
      for (final value in urls) {
        try {
          downloaded = await _download(value, cancelToken);
          break;
        } on DioException catch (error) {
          if (CancelToken.isCancel(error)) rethrow;
          lastFailure = error;
        } on ImageGalleryException catch (error) {
          lastFailure = error;
        }
      }
      if (downloaded == null) {
        if (lastFailure case final ImageGalleryException failure) throw failure;
        throw const ImageGalleryException(userMessage: '图片下载失败，请检查网络后重试。');
      }
      final format = await _detectFormat(downloaded);
      final finalFile = await downloaded.rename(
        '${path.withoutExtension(downloaded.path)}.${format.extension}',
      );
      downloaded = finalFile;
      final fileName =
          'wenyou_${DateTime.now().millisecondsSinceEpoch}_${uuid.v4()}.${format.extension}';
      await bridge.saveImage(
        filePath: finalFile.path,
        fileName: fileName,
        mimeType: format.mimeType,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        throw const ImageGalleryException(userMessage: '已取消保存图片。');
      }
      throw const ImageGalleryException(userMessage: '图片下载失败，请检查网络后重试。');
    } on PlatformException catch (error) {
      throw _platformFailure(error);
    } finally {
      if (downloaded != null) {
        try {
          if (await downloaded.exists()) await downloaded.delete();
        } on FileSystemException {
          // 系统相册写入已经结束，临时文件清理失败不改变用户可见结果。
        }
      }
    }
  }

  Future<File> _download(String value, CancelToken cancelToken) async {
    var uri = _safeImageUri(value);
    for (var redirect = 0; redirect <= _maximumRedirects; redirect++) {
      final response = await dio.get<ResponseBody>(
        uri.toString(),
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: false,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 400,
          headers: {'X-Request-ID': uuid.v4()},
        ),
      );
      final status = response.statusCode ?? 0;
      if (status >= 300) {
        final location = response.headers.value(HttpHeaders.locationHeader);
        await _discard(response.data);
        if (location == null || redirect == _maximumRedirects) {
          throw const ImageGalleryException(userMessage: '图片地址已失效，请重新加载。');
        }
        uri = _safeImageUri(uri.resolve(location).toString());
        continue;
      }
      final body = response.data;
      if (body == null) {
        throw const ImageGalleryException(userMessage: '图片下载失败，请重试。');
      }
      final declaredLength = int.tryParse(
        response.headers.value(Headers.contentLengthHeader) ?? '',
      );
      if (declaredLength != null && declaredLength > _maximumBytes) {
        await _discard(body);
        throw const ImageGalleryException(userMessage: '图片超过 10 MB，无法保存。');
      }
      final headerMime = response.headers
          .value(Headers.contentTypeHeader)
          ?.split(';')
          .first
          .trim()
          .toLowerCase();
      if (headerMime != null &&
          headerMime.isNotEmpty &&
          headerMime != 'application/octet-stream' &&
          !headerMime.startsWith('image/')) {
        await _discard(body);
        throw const ImageGalleryException(userMessage: '这个文件不是可保存的图片。');
      }
      final directory = Directory(
        path.join((await _temporaryDirectory()).path, 'wenyou_gallery'),
      );
      await directory.create(recursive: true);
      final file = File(path.join(directory.path, '${uuid.v4()}.part'));
      final sink = file.openWrite();
      var received = 0;
      try {
        try {
          await for (final chunk in body.stream) {
            received += chunk.length;
            if (received > _maximumBytes) {
              throw const ImageGalleryException(
                userMessage: '图片超过 10 MB，无法保存。',
              );
            }
            sink.add(chunk);
          }
          await sink.flush();
        } finally {
          await sink.close();
        }
        if (received == 0) {
          throw const ImageGalleryException(userMessage: '图片内容为空，无法保存。');
        }
        final format = await _detectFormat(file);
        if (headerMime != null &&
            headerMime.startsWith('image/') &&
            !_mimeMatches(headerMime, format.mimeType)) {
          throw const ImageGalleryException(userMessage: '图片格式与文件内容不一致。');
        }
        return file;
      } on Object {
        try {
          if (await file.exists()) await file.delete();
        } on FileSystemException {
          // 失败分支继续保留原始错误，后续临时目录清理可处理残留文件。
        }
        rethrow;
      }
    }
    throw const ImageGalleryException(userMessage: '图片地址已失效，请重新加载。');
  }

  Future<void> _discard(ResponseBody? body) async {
    if (body == null) return;
    final subscription = body.stream.listen((_) {});
    await subscription.cancel();
  }

  Uri _safeImageUri(String value) {
    final uri = Uri.tryParse(value.trim());
    final loopbackHosts = {'localhost', '127.0.0.1', '::1', '10.0.2.2'};
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        (uri.scheme != 'https' &&
            !(uri.scheme == 'http' && loopbackHosts.contains(uri.host)))) {
      throw const ImageGalleryException(userMessage: '图片地址不安全，无法保存。');
    }
    return uri;
  }

  Future<_ImageFormat> _detectFormat(File file) async {
    final input = await file.open();
    late final Uint8List bytes;
    try {
      bytes = await input.read(32);
    } finally {
      await input.close();
    }
    if (_startsWith(bytes, const [0xff, 0xd8, 0xff])) {
      return const _ImageFormat('jpg', 'image/jpeg');
    }
    if (_startsWith(bytes, const [
      0x89,
      0x50,
      0x4e,
      0x47,
      0x0d,
      0x0a,
      0x1a,
      0x0a,
    ])) {
      return const _ImageFormat('png', 'image/png');
    }
    if (_asciiAt(bytes, 0, 'GIF87a') || _asciiAt(bytes, 0, 'GIF89a')) {
      return const _ImageFormat('gif', 'image/gif');
    }
    if (_asciiAt(bytes, 0, 'RIFF') && _asciiAt(bytes, 8, 'WEBP')) {
      return const _ImageFormat('webp', 'image/webp');
    }
    if (_asciiAt(bytes, 4, 'ftyp') &&
        (_asciiAt(bytes, 8, 'avif') || _asciiAt(bytes, 8, 'avis'))) {
      return const _ImageFormat('avif', 'image/avif');
    }
    throw const ImageGalleryException(userMessage: '暂不支持保存这种图片格式。');
  }

  bool _startsWith(Uint8List bytes, List<int> prefix) {
    if (bytes.length < prefix.length) return false;
    for (var index = 0; index < prefix.length; index++) {
      if (bytes[index] != prefix[index]) return false;
    }
    return true;
  }

  bool _asciiAt(Uint8List bytes, int offset, String value) {
    if (bytes.length < offset + value.length) return false;
    for (var index = 0; index < value.length; index++) {
      if (bytes[offset + index] != value.codeUnitAt(index)) return false;
    }
    return true;
  }

  bool _mimeMatches(String header, String detected) {
    final normalized = header == 'image/jpg' ? 'image/jpeg' : header;
    return normalized == detected;
  }

  ImageGalleryException _platformFailure(PlatformException error) {
    return switch (error.code) {
      'permission_denied' => const ImageGalleryException(
        userMessage: '没有获得照片保存权限。',
      ),
      'settings_required' => const ImageGalleryException(
        userMessage: '请在系统设置中允许温油站添加照片。',
        settingsRequired: true,
      ),
      'unsupported_format' => const ImageGalleryException(
        userMessage: '系统相册不支持这种图片格式。',
      ),
      'storage_unavailable' => const ImageGalleryException(
        userMessage: '系统相册暂时不可用，请稍后重试。',
      ),
      _ => const ImageGalleryException(userMessage: '图片保存失败，请稍后重试。'),
    };
  }
}

class _ImageFormat {
  const _ImageFormat(this.extension, this.mimeType);

  final String extension;
  final String mimeType;
}
