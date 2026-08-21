import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/posts/application/post_thread_context_ports.dart';

void main() {
  test('主题权限上下文随会话作用域重新读取而不复用旧账号 capability', () async {
    var lookups = 0;
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_UnusedSessionRemote()),
        postThreadContextLookupProvider.overrideWithValue((_) async {
          lookups += 1;
          return PostThreadContext(
            isPrivate: false,
            canManageThread: lookups > 1,
          );
        }),
      ],
    );
    addTearDown(container.dispose);
    final provider = postThreadContextProvider('thread-1');
    final subscription = container.listen<AsyncValue<PostThreadContext>>(
      provider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect((await container.read(provider.future)).canManageThread, isFalse);

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(
          const SessionTokens(
            accessToken: 'new-session-access',
            refreshToken: 'new-session-refresh',
          ),
        );

    expect((await container.read(provider.future)).canManageThread, isTrue);
    expect(lookups, 2);
  });
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

class _UnusedSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) => throw UnimplementedError();

  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw UnimplementedError();
}
