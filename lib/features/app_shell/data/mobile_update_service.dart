import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

enum UpdateLaunchResult {
  permissionRequired,
  installerOpened,
  externalPageOpened,
}

class MobileUpdateException implements Exception {
  const MobileUpdateException(this.userMessage, [this.cause]);

  final String userMessage;
  final Object? cause;

  @override
  String toString() => userMessage;
}

abstract interface class MobileUpdateService {
  MobileClientPlatform get platform;

  Future<InstalledAppInfo> readInstalledApp();

  Future<UpdateLaunchResult> launchUpdate(
    MobileUpdateInfo update, {
    required void Function(double progress) onProgress,
  });
}

class DeviceMobileUpdateService implements MobileUpdateService {
  DeviceMobileUpdateService(this._downloadDio);

  static const _installerChannel = MethodChannel(
    'site.wenyou.app/app_update',
  );

  final Dio _downloadDio;

  @override
  MobileClientPlatform get platform {
    if (kIsWeb) return MobileClientPlatform.unsupported;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => MobileClientPlatform.android,
      TargetPlatform.iOS => MobileClientPlatform.ios,
      _ => MobileClientPlatform.unsupported,
    };
  }

  @override
  Future<InstalledAppInfo> readInstalledApp() async {
    try {
      final info = await _installerChannel.invokeMapMethod<String, Object?>(
        'getInstalledAppInfo',
      );
      final version = info?['version'];
      final build = int.tryParse('${info?['build'] ?? ''}');
      if (version is! String || version.isEmpty || build == null || build < 1) {
        throw const MobileUpdateException('无法识别当前应用构建号。');
      }
      return InstalledAppInfo(
        platform: platform,
        version: version,
        build: build,
      );
    } on MobileUpdateException {
      rethrow;
    } on Object catch (error) {
      throw MobileUpdateException('无法读取当前应用版本，请稍后重试。', error);
    }
  }

  @override
  Future<UpdateLaunchResult> launchUpdate(
    MobileUpdateInfo update, {
    required void Function(double progress) onProgress,
  }) async {
    final uri = update.updateUri;
    if (uri == null) {
      throw const MobileUpdateException('新版本下载地址尚未配置，请稍后重试。');
    }
    if (update.platform != MobileClientPlatform.android) {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        throw const MobileUpdateException('无法打开 TestFlight 更新页面。');
      }
      return UpdateLaunchResult.externalPageOpened;
    }

    try {
      final temporaryDirectory = await getTemporaryDirectory();
      final updateDirectory = Directory(
        path.join(temporaryDirectory.path, 'wenyou_updates'),
      );
      await updateDirectory.create(recursive: true);
      final finalFile = File(
        path.join(updateDirectory.path, 'wenyou-${update.targetBuild}.apk'),
      );

      if (!await finalFile.exists() || await finalFile.length() == 0) {
        final partialFile = File('${finalFile.path}.part');
        if (await partialFile.exists()) await partialFile.delete();
        final response = await _downloadDio.downloadUri(
          uri,
          partialFile.path,
          deleteOnError: true,
          onReceiveProgress: (received, total) {
            if (total > 0) onProgress(received / total);
          },
          options: Options(
            headers: const {
              'Accept': 'application/vnd.android.package-archive',
            },
          ),
        );
        if (response.realUri.scheme != 'https') {
          if (await partialFile.exists()) await partialFile.delete();
          throw const MobileUpdateException('安装包下载地址不是安全连接。');
        }
        if (!await partialFile.exists() || await partialFile.length() == 0) {
          throw const MobileUpdateException('安装包下载不完整，请重试。');
        }
        await partialFile.rename(finalFile.path);
      } else {
        onProgress(1);
      }

      final result = await _installerChannel.invokeMethod<String>(
        'installApk',
        {'filePath': finalFile.path},
      );
      return switch (result) {
        'permissionRequired' => UpdateLaunchResult.permissionRequired,
        'installerOpened' => UpdateLaunchResult.installerOpened,
        _ => throw const MobileUpdateException('系统没有响应安装请求，请重试。'),
      };
    } on MobileUpdateException {
      rethrow;
    } on DioException catch (error) {
      throw MobileUpdateException('安装包下载失败，请检查网络后重试。', error);
    } on PlatformException catch (error) {
      throw MobileUpdateException(
        error.message ?? '无法唤起系统安装器，请稍后重试。',
        error,
      );
    } on Object catch (error) {
      throw MobileUpdateException('更新没有完成，请稍后重试。', error);
    }
  }
}
