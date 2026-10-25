import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/config/app_environment.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/data/meta_repository.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

class _Tokens extends Mock implements TokenStore {}

class _Remote extends Mock implements SessionRemote {}

class _Updates extends Mock implements MobileUpdateService {}

class _Dismiss extends Mock implements RecommendedUpdateDismissStore {}

void main() {
  test('公网5.40原始meta经真实解码和启动控制器允许build100进入且关闭字体能力', () async {
    // 2026-10-22只读GET记录；离线回放，不请求公网或登录。
    final captured = jsonDecode(
      File(
        'test/features/app_shell/fixtures/meta_public_5_40.json',
      ).readAsStringSync(),
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api/v1'));
    addTearDown(dio.close);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'GET');
          expect(options.path, '/api/v1/meta');
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: captured),
          );
        },
      ),
    );
    final tokens = _Tokens();
    when(tokens.read).thenAnswer((_) async => null);
    final remote = _Remote();
    final session = SessionController(tokens, remote);
    addTearDown(session.dispose);
    final updates = _Updates();
    when(() => updates.platform).thenReturn(MobileClientPlatform.android);
    when(updates.readInstalledApp).thenAnswer(
      (_) async => const InstalledAppInfo(
        platform: MobileClientPlatform.android,
        version: '0.10.0-debug',
        build: 100,
      ),
    );
    final startup = StartupController(
      ApiMetaRepository(WenyouApi(dio: dio)),
      const AppEnvironment(apiBaseUrl: 'https://wenyou.site/api/v1'),
      session,
      mobileUpdateService: updates,
      dismissStore: _Dismiss(),
      autoStart: false,
    );
    addTearDown(startup.dispose);
    await startup.check();
    expect(startup.state.status, StartupStatus.ready);
    expect(startup.state.update, isNull);
    expect(session.state.status, SessionStatus.guest);
    final contract = startup.state.contract!;
    expect(contract.contractVersion, '5.40.0-dev.20261018.1');
    expect(contract.markdownContractVersion, 5);
    expect(contract.android.minimumSupportedBuild, isNull);
    expect(contract.android.recommendedBuild, 100);
    expect(contract.textFontSupported, isFalse);
    expect(contract.textFontV2Supported, isFalse);
    expect(contract.textFontWriteEnabled, isFalse);
    expect(contract.textFontV2WriteEnabled, isFalse);
    verifyZeroInteractions(remote);
  });
}
