import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/app_shell/data/mobile_update_service.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'wenyou-update-test-',
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('校验 RainS3 元数据和 SHA-256 后才把 APK 交给原生安装器', () async {
    final adapter = _ReleaseAdapter(_apkBytes);
    final dio = Dio()..httpClientAdapter = adapter;
    final bridge = _FakePlatformBridge();
    final service = _service(dio, bridge, temporaryDirectory);
    final stages = <MobileUpdateStage>[];
    final progress = <double>[];

    final result = await service.launchUpdate(
      _update,
      onStage: stages.add,
      onProgress: progress.add,
    );

    expect(result, UpdateLaunchResult.installerOpened);
    expect(adapter.headCalls, 1);
    expect(adapter.getCalls, 1);
    expect(
      stages,
      containsAllInOrder(const [
        MobileUpdateStage.checking,
        MobileUpdateStage.downloading,
        MobileUpdateStage.verifying,
        MobileUpdateStage.installing,
      ]),
    );
    expect(progress.last, 1);
    expect(bridge.expectedBuilds, const [43]);
    final installedFile = File(bridge.filePaths.single);
    expect(await installedFile.readAsBytes(), _apkBytes);
    expect(
      installedFile.path,
      contains('wenyou-43-${_digest.substring(0, 12)}'),
    );
    dio.close(force: true);
  });

  test('未知来源权限返回后复用本次已验证 APK，不再次请求或计算下载', () async {
    final adapter = _ReleaseAdapter(_apkBytes);
    final dio = Dio()..httpClientAdapter = adapter;
    final bridge = _FakePlatformBridge(
      installResults: ['permissionRequired', 'installerOpened'],
    );
    final service = _service(dio, bridge, temporaryDirectory);

    final first = await service.launchUpdate(
      _update,
      onStage: (_) {},
      onProgress: (_) {},
    );
    final secondStages = <MobileUpdateStage>[];
    final second = await service.launchUpdate(
      _update,
      onStage: secondStages.add,
      onProgress: (_) {},
    );

    expect(first, UpdateLaunchResult.permissionRequired);
    expect(second, UpdateLaunchResult.installerOpened);
    expect(adapter.headCalls, 1);
    expect(adapter.getCalls, 1);
    expect(secondStages, const [MobileUpdateStage.installing]);
    expect(bridge.filePaths.toSet(), hasLength(1));
    dio.close(force: true);
  });

  test('新进程发现同长度损坏缓存时删除并重新下载', () async {
    final adapter = _ReleaseAdapter(_apkBytes);
    final dio = Dio()..httpClientAdapter = adapter;
    final firstBridge = _FakePlatformBridge();
    final firstService = _service(dio, firstBridge, temporaryDirectory);
    await firstService.launchUpdate(
      _update,
      onStage: (_) {},
      onProgress: (_) {},
    );
    final cachedFile = File(firstBridge.filePaths.single);
    await cachedFile.writeAsBytes(
      Uint8List.fromList(List<int>.filled(_apkBytes.length, 9)),
      flush: true,
    );

    final secondBridge = _FakePlatformBridge();
    final secondService = _service(dio, secondBridge, temporaryDirectory);
    await secondService.launchUpdate(
      _update,
      onStage: (_) {},
      onProgress: (_) {},
    );

    expect(adapter.headCalls, 2);
    expect(adapter.getCalls, 2);
    expect(await cachedFile.readAsBytes(), _apkBytes);
    dio.close(force: true);
  });

  test('发布元数据包名不匹配时拒绝下载和安装', () async {
    final adapter = _ReleaseAdapter(
      _apkBytes,
      applicationId: 'example.invalid.app',
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final bridge = _FakePlatformBridge();
    final service = _service(dio, bridge, temporaryDirectory);

    await expectLater(
      service.launchUpdate(_update, onStage: (_) {}, onProgress: (_) {}),
      throwsA(
        isA<MobileUpdateException>().having(
          (error) => error.userMessage,
          'message',
          '安装包与当前应用不匹配。',
        ),
      ),
    );
    expect(adapter.headCalls, 1);
    expect(adapter.getCalls, 0);
    expect(bridge.filePaths, isEmpty);
    dio.close(force: true);
  });

  test('下载内容哈希不匹配时不保留 partial 或 APK', () async {
    final adapter = _ReleaseAdapter(
      _apkBytes,
      advertisedSha256: sha256.convert(const [1, 2, 3]).toString(),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final bridge = _FakePlatformBridge();
    final service = _service(dio, bridge, temporaryDirectory);

    await expectLater(
      service.launchUpdate(_update, onStage: (_) {}, onProgress: (_) {}),
      throwsA(
        isA<MobileUpdateException>().having(
          (error) => error.userMessage,
          'message',
          '安装包校验失败，请重新下载。',
        ),
      ),
    );
    final updateDirectory = Directory(
      '${temporaryDirectory.path}${Platform.pathSeparator}wenyou_updates',
    );
    expect(await updateDirectory.list().toList(), isEmpty);
    expect(bridge.filePaths, isEmpty);
    dio.close(force: true);
  });
}

DeviceMobileUpdateService _service(
  Dio dio,
  MobileUpdatePlatformBridge bridge,
  Directory temporaryDirectory,
) {
  return DeviceMobileUpdateService.withDependencies(
    dio,
    platformBridge: bridge,
    platformOverride: MobileClientPlatform.android,
    temporaryDirectoryProvider: () async => temporaryDirectory,
  );
}

final _apkBytes = Uint8List.fromList(
  List<int>.generate(4096, (index) => index % 251),
);
final _digest = sha256.convert(_apkBytes).toString();

final _update = MobileUpdateInfo(
  kind: MobileUpdateKind.required,
  platform: MobileClientPlatform.android,
  currentVersion: '0.3.0-dev.36',
  currentBuild: 42,
  targetBuild: 43,
  updateUri: Uri.parse(
    'https://wenyou-apk.cn-nb1.rains3.com/mobile/android/wenyou.apk',
  ),
);

class _FakePlatformBridge implements MobileUpdatePlatformBridge {
  _FakePlatformBridge({List<String>? installResults})
    : _installResults = installResults ?? ['installerOpened'];

  final List<String> _installResults;
  final List<String> filePaths = [];
  final List<int> expectedBuilds = [];
  int _installIndex = 0;

  @override
  Future<String?> installApk({
    required String filePath,
    required int expectedBuild,
  }) async {
    filePaths.add(filePath);
    expectedBuilds.add(expectedBuild);
    final result = _installResults[_installIndex];
    _installIndex += 1;
    return result;
  }

  @override
  Future<InstalledAppInfo> readInstalledApp(
    MobileClientPlatform platform,
  ) async {
    return InstalledAppInfo(platform: platform, version: '0.3.0', build: 42);
  }
}

class _ReleaseAdapter implements HttpClientAdapter {
  _ReleaseAdapter(
    this.bytes, {
    this.applicationId = 'site.wenyou.app',
    String? advertisedSha256,
  }) : advertisedSha256 = advertisedSha256 ?? sha256.convert(bytes).toString();

  final Uint8List bytes;
  final String applicationId;
  final String advertisedSha256;
  int headCalls = 0;
  int getCalls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final headers = <String, List<String>>{
      Headers.contentTypeHeader: ['application/vnd.android.package-archive'],
      Headers.contentLengthHeader: ['${bytes.length}'],
      'content-disposition': ['attachment; filename="wenyou-0.3.0-43.apk"'],
      'x-amz-meta-apk-sha256': [advertisedSha256],
      'x-amz-meta-application-id': [applicationId],
      'x-amz-meta-version-name': ['0.3.0-dev.37'],
      'x-amz-meta-version-code': ['43'],
    };
    if (options.method == 'HEAD') {
      headCalls += 1;
      return ResponseBody.fromBytes(const [], 200, headers: headers);
    }
    getCalls += 1;
    return ResponseBody.fromBytes(bytes, 200, headers: headers);
  }

  @override
  void close({bool force = false}) {}
}
