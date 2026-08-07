import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/data/meta_repository.dart';

void main() {
  testWidgets('兼容契约下游客直接进入四栏首页', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(_CompatibleMetaRepository()),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('公网开发环境已连接'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('搜索'), findsOneWidget);
    expect(find.text('通知'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);

    await tester.tap(find.text('搜索'));
    await tester.pumpAndSettle();
    expect(find.text('搜索模块已进入规划'), findsOneWidget);
  });
}

class _CompatibleMetaRepository implements MetaRepository {
  @override
  Future<ContractInfo> fetch() async {
    return const ContractInfo(
      contractVersion: '3.0.0-dev.test',
      markdownContractVersion: 2,
    );
  }
}

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}
