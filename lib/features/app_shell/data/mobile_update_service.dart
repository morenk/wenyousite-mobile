import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

export 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart'
    show
        MobileUpdateAvailabilityChecker,
        MobileUpdateException,
        MobileUpdateService,
        MobileUpdateStage,
        UpdateLaunchResult;

abstract interface class MobileUpdatePlatformBridge {
  Future<InstalledAppInfo> readInstalledApp(MobileClientPlatform platform);

  Future<String?> installApk({
    required String filePath,
    required int expectedBuild,
  });
}

class MethodChannelMobileUpdatePlatformBridge
    implements MobileUpdatePlatformBridge {
  const MethodChannelMobileUpdatePlatformBridge();

  static const _installerChannel = MethodChannel('site.wenyou.app/app_update');

  @override
  Future<InstalledAppInfo> readInstalledApp(
    MobileClientPlatform platform,
  ) async {
    final info = await _installerChannel.invokeMapMethod<String, Object?>(
      'getInstalledAppInfo',
    );
    final version = info?['version'];
    final build = int.tryParse('${info?['build'] ?? ''}');
    if (version is! String || version.isEmpty || build == null || build < 1) {
      throw const MobileUpdateException('无法识别当前应用构建号。');
    }
    return InstalledAppInfo(platform: platform, version: version, build: build);
  }

  @override
  Future<String?> installApk({
    required String filePath,
    required int expectedBuild,
  }) {
    return _installerChannel.invokeMethod<String>('installApk', {
      'filePath': filePath,
      'expectedBuild': expectedBuild,
    });
  }
}

class DeviceMobileUpdateService
    implements MobileUpdateService, MobileUpdateAvailabilityChecker {
  factory DeviceMobileUpdateService(Dio downloadDio) {
    return DeviceMobileUpdateService.withDependencies(downloadDio);
  }

  factory DeviceMobileUpdateService.withDependencies(
    Dio downloadDio, {
    MobileUpdatePlatformBridge platformBridge =
        const MethodChannelMobileUpdatePlatformBridge(),
    MobileClientPlatform? platformOverride,
    Future<Directory> Function()? temporaryDirectoryProvider,
    Future<bool> Function(Uri uri)? externalLauncher,
  }) {
    return DeviceMobileUpdateService._(
      downloadDio,
      platformBridge,
      platformOverride,
      temporaryDirectoryProvider ?? getTemporaryDirectory,
      externalLauncher ?? _launchExternal,
    );
  }

  DeviceMobileUpdateService._(
    this._downloadDio,
    this._platformBridge,
    this._platformOverride,
    this._temporaryDirectoryProvider,
    this._externalLauncher,
  );

  static const _applicationId = 'site.wenyou.app';
  static const _apkContentType = 'application/vnd.android.package-archive';
  static const _maximumApkBytes = 250 * 1024 * 1024;

  final Dio _downloadDio;
  final MobileUpdatePlatformBridge _platformBridge;
  final MobileClientPlatform? _platformOverride;
  final Future<Directory> Function() _temporaryDirectoryProvider;
  final Future<bool> Function(Uri uri) _externalLauncher;
  _VerifiedAndroidArtifact? _verifiedArtifact;
  _AvailableAndroidRelease? _availableRelease;

  @override
  MobileClientPlatform get platform {
    final override = _platformOverride;
    if (override != null) return override;
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
      return await _platformBridge.readInstalledApp(platform);
    } on MobileUpdateException {
      rethrow;
    } on Object catch (error) {
      throw MobileUpdateException('无法读取当前应用版本，请稍后重试。', error);
    }
  }

  @override
  Future<MobileUpdateAvailability> checkAvailability(
    MobileUpdateInfo update,
  ) async {
    final uri = update.updateUri;
    if (uri == null) return const MobileUpdateAvailability.preparing();
    if (update.platform != MobileClientPlatform.android) {
      return const MobileUpdateAvailability.available();
    }
    try {
      final metadata = await _readAndroidReleaseMetadata(
        uri,
        targetBuild: update.targetBuild,
      );
      _availableRelease = _AvailableAndroidRelease(
        uri: uri,
        targetBuild: update.targetBuild,
        metadata: metadata,
      );
      return MobileUpdateAvailability.available(
        targetVersion: metadata.versionName,
      );
    } on Object {
      _availableRelease = null;
      return const MobileUpdateAvailability.preparing();
    }
  }

  @override
  Future<UpdateLaunchResult> launchUpdate(
    MobileUpdateInfo update, {
    required void Function(MobileUpdateStage stage) onStage,
    required void Function(double progress) onProgress,
  }) async {
    final uri = update.updateUri;
    if (uri == null) {
      throw const MobileUpdateException('获取新版本下载地址失败，请稍后重试。');
    }
    if (update.platform != MobileClientPlatform.android) {
      onStage(MobileUpdateStage.openingExternalPage);
      final opened = await _externalLauncher(uri);
      if (!opened) {
        throw const MobileUpdateException('无法打开 TestFlight 更新页面。');
      }
      return UpdateLaunchResult.externalPageOpened;
    }

    try {
      final reusable = await _reusableArtifact(update);
      if (reusable != null) {
        onProgress(1);
        return await _install(reusable, onStage);
      }

      onStage(MobileUpdateStage.checking);
      final availableRelease = _availableRelease;
      final metadata =
          availableRelease != null &&
              availableRelease.uri == uri &&
              availableRelease.targetBuild == update.targetBuild
          ? availableRelease.metadata
          : await _readAndroidReleaseMetadata(
              uri,
              targetBuild: update.targetBuild,
            );
      final temporaryDirectory = await _temporaryDirectoryProvider();
      final updateDirectory = Directory(
        path.join(temporaryDirectory.path, 'wenyou_updates'),
      );
      await updateDirectory.create(recursive: true);
      final finalFile = File(
        path.join(
          updateDirectory.path,
          'wenyou-${update.targetBuild}-${metadata.sha256.substring(0, 12)}.apk',
        ),
      );
      await _cleanStaleArtifacts(updateDirectory, keep: finalFile.path);

      if (await _verifyFile(finalFile, metadata, onStage: onStage)) {
        onProgress(1);
      } else {
        await _downloadAndVerify(
          uri: uri,
          finalFile: finalFile,
          metadata: metadata,
          targetBuild: update.targetBuild,
          onStage: onStage,
          onProgress: onProgress,
        );
      }

      final artifact = _VerifiedAndroidArtifact(
        uri: uri,
        targetBuild: update.targetBuild,
        file: finalFile,
        metadata: metadata,
      );
      _verifiedArtifact = artifact;
      return await _install(artifact, onStage);
    } on MobileUpdateException {
      rethrow;
    } on DioException catch (error) {
      throw MobileUpdateException('安装包下载失败，请检查网络后重试。', error);
    } on PlatformException catch (error) {
      if (error.code.startsWith('apk_')) {
        await _discardVerifiedArtifact();
      }
      throw MobileUpdateException(error.message ?? '无法唤起系统安装器，请稍后重试。', error);
    } on Object catch (error) {
      throw MobileUpdateException('更新失败，请稍后重试。', error);
    }
  }

  Future<_VerifiedAndroidArtifact?> _reusableArtifact(
    MobileUpdateInfo update,
  ) async {
    final artifact = _verifiedArtifact;
    if (artifact == null ||
        artifact.uri != update.updateUri ||
        artifact.targetBuild != update.targetBuild) {
      return null;
    }
    if (!await artifact.file.exists() ||
        await artifact.file.length() != artifact.metadata.contentLength) {
      await _discardVerifiedArtifact();
      return null;
    }
    return artifact;
  }

  Future<_AndroidReleaseMetadata> _readAndroidReleaseMetadata(
    Uri uri, {
    required int targetBuild,
  }) async {
    final response = await _downloadDio.headUri<Object?>(
      uri,
      options: Options(
        headers: const {'Accept': _apkContentType},
        followRedirects: true,
      ),
    );
    return _AndroidReleaseMetadata.fromResponse(
      response,
      targetBuild: targetBuild,
    );
  }

  Future<UpdateLaunchResult> _install(
    _VerifiedAndroidArtifact artifact,
    void Function(MobileUpdateStage stage) onStage,
  ) async {
    onStage(MobileUpdateStage.installing);
    final result = await _platformBridge.installApk(
      filePath: artifact.file.path,
      expectedBuild: artifact.targetBuild,
    );
    return switch (result) {
      'permissionRequired' => UpdateLaunchResult.permissionRequired,
      'installerOpened' => UpdateLaunchResult.installerOpened,
      _ => throw const MobileUpdateException('系统未能开始安装，请重试。'),
    };
  }

  Future<void> _downloadAndVerify({
    required Uri uri,
    required File finalFile,
    required _AndroidReleaseMetadata metadata,
    required int targetBuild,
    required void Function(MobileUpdateStage stage) onStage,
    required void Function(double progress) onProgress,
  }) async {
    final partialFile = File('${finalFile.path}.part');
    await _deleteIfExists(partialFile);
    try {
      onStage(MobileUpdateStage.downloading);
      final response = await _downloadDio.downloadUri(
        uri,
        partialFile.path,
        deleteOnError: true,
        onReceiveProgress: (received, total) {
          final expectedTotal = total > 0 ? total : metadata.contentLength;
          if (expectedTotal > 0) {
            onProgress((received / expectedTotal).clamp(0.0, 1.0));
          }
        },
        options: Options(
          headers: const {'Accept': _apkContentType},
          followRedirects: true,
        ),
      );
      final downloadMetadata = _AndroidReleaseMetadata.fromResponse(
        response,
        targetBuild: targetBuild,
      );
      if (downloadMetadata != metadata) {
        throw const MobileUpdateException('安装包发布信息在下载期间发生变化，请重试。');
      }
      if (!await _verifyFile(partialFile, metadata, onStage: onStage)) {
        throw const MobileUpdateException('安装包校验失败，请重新下载。');
      }
      await _deleteIfExists(finalFile);
      await partialFile.rename(finalFile.path);
      onProgress(1);
    } finally {
      await _deleteIfExists(partialFile);
    }
  }

  Future<bool> _verifyFile(
    File file,
    _AndroidReleaseMetadata metadata, {
    required void Function(MobileUpdateStage stage) onStage,
  }) async {
    if (!await file.exists()) return false;
    onStage(MobileUpdateStage.verifying);
    if (await file.length() != metadata.contentLength) {
      await _deleteIfExists(file);
      return false;
    }
    final digest = await sha256.bind(file.openRead()).first;
    if (digest.toString() != metadata.sha256) {
      await _deleteIfExists(file);
      return false;
    }
    return true;
  }

  Future<void> _cleanStaleArtifacts(
    Directory directory, {
    required String keep,
  }) async {
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File || entity.path == keep) continue;
      final name = path.basename(entity.path);
      if (name.startsWith('wenyou-') &&
          (name.endsWith('.apk') || name.endsWith('.apk.part'))) {
        await _deleteIfExists(entity);
      }
    }
  }

  Future<void> _discardVerifiedArtifact() async {
    final artifact = _verifiedArtifact;
    _verifiedArtifact = null;
    if (artifact != null) await _deleteIfExists(artifact.file);
  }

  static Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) await file.delete();
  }

  static Future<bool> _launchExternal(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _AndroidReleaseMetadata {
  const _AndroidReleaseMetadata({
    required this.contentLength,
    required this.sha256,
    required this.versionName,
  });

  factory _AndroidReleaseMetadata.fromResponse(
    Response<Object?> response, {
    required int targetBuild,
  }) {
    if (response.realUri.scheme.toLowerCase() != 'https') {
      throw const MobileUpdateException('安装包下载地址不是安全连接。');
    }
    final contentType = _header(
      response,
      Headers.contentTypeHeader,
    ).split(';').first.trim().toLowerCase();
    if (contentType != DeviceMobileUpdateService._apkContentType) {
      throw const MobileUpdateException('下载的更新文件无法安装，请重新下载。');
    }
    final contentLength = int.tryParse(
      _header(response, Headers.contentLengthHeader),
    );
    if (contentLength == null ||
        contentLength < 1 ||
        contentLength > DeviceMobileUpdateService._maximumApkBytes) {
      throw const MobileUpdateException('安装包大小无效或超出限制。');
    }
    final disposition = _header(response, 'content-disposition').toLowerCase();
    if (!disposition.contains('.apk')) {
      throw const MobileUpdateException('安装包下载失败，请稍后重试。');
    }
    final applicationId = _header(response, 'x-amz-meta-application-id');
    if (applicationId != DeviceMobileUpdateService._applicationId) {
      throw const MobileUpdateException('安装包与当前应用不匹配。');
    }
    final versionCode = int.tryParse(
      _header(response, 'x-amz-meta-version-code'),
    );
    if (versionCode != targetBuild) {
      throw const MobileUpdateException('安装包构建号与更新目标不一致。');
    }
    final versionName = _header(response, 'x-amz-meta-version-name').trim();
    if (versionName.isEmpty) {
      throw const MobileUpdateException('安装包版本加载失败，请稍后重试。');
    }
    final digest = _header(response, 'x-amz-meta-apk-sha256').toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(digest)) {
      throw const MobileUpdateException('安装包校验信息无效，请稍后重试。');
    }
    return _AndroidReleaseMetadata(
      contentLength: contentLength,
      sha256: digest,
      versionName: versionName,
    );
  }

  final int contentLength;
  final String sha256;
  final String versionName;

  @override
  bool operator ==(Object other) {
    return other is _AndroidReleaseMetadata &&
        other.contentLength == contentLength &&
        other.sha256 == sha256 &&
        other.versionName == versionName;
  }

  @override
  int get hashCode => Object.hash(contentLength, sha256, versionName);

  static String _header(Response<Object?> response, String name) {
    final value = response.headers.value(name);
    if (value == null || value.trim().isEmpty) {
      throw const MobileUpdateException('安装包发布信息加载失败，请稍后重试。');
    }
    return value.trim();
  }
}

class _VerifiedAndroidArtifact {
  const _VerifiedAndroidArtifact({
    required this.uri,
    required this.targetBuild,
    required this.file,
    required this.metadata,
  });

  final Uri uri;
  final int targetBuild;
  final File file;
  final _AndroidReleaseMetadata metadata;
}

class _AvailableAndroidRelease {
  const _AvailableAndroidRelease({
    required this.uri,
    required this.targetBuild,
    required this.metadata,
  });

  final Uri uri;
  final int targetBuild;
  final _AndroidReleaseMetadata metadata;
}

final mobileUpdateDownloadDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(minutes: 5),
      headers: const {'Accept-Encoding': 'identity'},
    ),
  );
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final deviceMobileUpdateServiceProvider = Provider<MobileUpdateService>((ref) {
  return DeviceMobileUpdateService(ref.watch(mobileUpdateDownloadDioProvider));
});
