import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/startup_gate.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_source_ports.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/cover_playback_scope.dart';

import '../../app_shell_test_support.dart';

void main() {
  testWidgets('真实StartupGate等待认证恢复才激活缓存owner，退出和权限变化清理', (tester) async {
    final store = _RestoringTokens();
    final source = _Source();
    var initialized = 0;
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        metaRepositoryProvider.overrideWithValue(
          AppShellTestCompatibleMetaRepository(),
        ),
        coverAnimationSourceProvider.overrideWith((ref) {
          initialized++;
          return source;
        }),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: StartupGate(
            child: const CoverPlaybackScope(child: SizedBox.shrink()),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(initialized, 0);
    expect(source.owners, isEmpty);
    store.restored.complete(
      SessionTokens(
        accessToken:
            'test.${base64Url.encode(utf8.encode(jsonEncode({'sub': 'restored-user'})))}.signature',
        refreshToken: 'test-refresh',
      ),
    );
    await tester.pumpAndSettle();
    expect(initialized, 1);
    expect(source.owners, ['restored-user']);
    expect(source.purges, [false]);
    container.read(contentVisibilityRevisionProvider.notifier).advance();
    await tester.pump();
    expect(source.purges.last, isTrue);
    await container.read(sessionControllerProvider.notifier).logoutLocally();
    await tester.pump();
    expect(source.owners.last, isNull);
    expect(source.purges.last, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _RestoringTokens implements TokenStore {
  final restored = Completer<SessionTokens?>();
  @override
  Future<SessionTokens?> read() => restored.future;
  @override
  Future<void> write(SessionTokens tokens) async {}
  @override
  Future<void> clear() async {}
}

class _Source implements CoverAnimationSource {
  final owners = <String?>[];
  final purges = <bool>[];
  @override
  void changeViewer(String? accountId, {required bool purge}) {
    owners.add(accountId);
    purges.add(purge);
  }

  @override
  void dispose() {}
  @override
  Future<void> invalidate(String url) async {}
  @override
  Future<CoverAnimationData> load(String url, CancelToken cancel) =>
      throw UnimplementedError();
  @override
  void releaseMemory() {}
}
