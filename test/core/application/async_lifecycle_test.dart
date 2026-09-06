import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/session_logout_controller.dart';
import 'package:wenyousite_mobile/core/application/thread_category_catalog.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/models/thread_category_presentation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/auth/application/auth_ports.dart';
import 'package:wenyousite_mobile/features/auth/application/login_controller.dart';
import 'package:wenyousite_mobile/features/auth/application/registration_controller.dart';
import 'package:wenyousite_mobile/features/tags/application/tag_repository_ports.dart';
import 'package:wenyousite_mobile/features/tags/application/tag_threads_controller.dart';
import 'package:wenyousite_mobile/features/tags/domain/tag_models.dart';

void main() {
  for (final changedAccount in [false, true]) {
    test('登录迟到结果不在${changedAccount ? '切号' : '页面释放'}后安装凭据', () async {
      final repository = _Auth();
      final store = _Tokens();
      final session = SessionController(store, _Remote());
      addTearDown(session.dispose);
      final controller = LoginController(repository, session);
      final pending = controller.submit(
        account: 'test',
        password: 'test-value',
      );
      if (changedAccount) {
        await session.authenticate(_tokens('new'));
        addTearDown(controller.dispose);
      } else {
        controller.dispose();
      }
      repository.tokens.complete(_tokens('old'));
      expect(await pending, isFalse);
      expect(session.tokens?.accessToken, changedAccount ? 'new' : null);
      expect(store.value?.accessToken, changedAccount ? 'new' : null);
    });
  }

  for (final failed in [false, true]) {
    test('注册验证码${failed ? '失败' : '成功'}迟到时不回写已释放页面或重建计时器', () async {
      final code = Completer<RegistrationCodeInfo>();
      final repository = _Auth()..code = code.future;
      final session = SessionController(_Tokens(), _Remote());
      addTearDown(session.dispose);
      final controller = RegistrationController(repository, session);
      final pending = controller.requestCode('test@example.com');
      controller.dispose();
      if (failed) {
        code.completeError(const ApiFailure(httpStatus: 503));
      } else {
        code.complete(
          const RegistrationCodeInfo(expiresIn: Duration(minutes: 15)),
        );
      }
      expect(await pending, isFalse);
    });
  }

  test('注册完成请求在页面释放后不建立会话', () async {
    final repository = _Auth();
    final session = SessionController(_Tokens(), _Remote());
    addTearDown(session.dispose);
    final controller = RegistrationController(repository, session);
    await controller.requestCode('test@example.com');
    final pending = controller.complete(
      code: '123456',
      username: '测试',
      password: 'test-value',
    );
    controller.dispose();
    repository.tokens.complete(_tokens('old'));
    expect(await pending, isFalse);
    expect(session.tokens, isNull);
  });

  test('退出页面释放后会话退出仍可完成且不回写已释放状态', () async {
    final remote = _Remote();
    final session = SessionController(_Tokens(), remote);
    addTearDown(session.dispose);
    await session.authenticate(_tokens('current'));
    final controller = LogoutController(session);
    final pending = controller.submit();
    controller.dispose();
    remote.loggedOut.complete();
    expect(await pending, isTrue);
    expect(session.tokens, isNull);
  });

  for (final failed in [false, true]) {
    test('分类目录${failed ? '失败' : '成功'}迟到不回写已释放控制器', () async {
      final repository = _Categories();
      final controller = ThreadCategoryCatalogController(
        repository,
        autoStart: false,
      );
      final pending = controller.load();
      controller.dispose();
      if (failed) {
        repository.result.completeError(StateError('Delayed failure.'));
      } else {
        repository.result.complete([]);
      }
      await pending;
    });

    test('标签列表${failed ? '失败' : '成功'}迟到不回写已释放控制器', () async {
      final repository = _Tags();
      final controller = TagThreadsController(
        'tag',
        repository,
        autoStart: false,
      );
      final pending = controller.loadInitial();
      controller.dispose();
      if (failed) {
        repository.result.completeError(const ApiFailure(httpStatus: 503));
      } else {
        repository.result.complete(
          TagThreadsBootstrap(
            tag: const TopicTagModel(
              id: 'tag',
              name: '标签',
              sortOrder: 0,
              isActive: true,
            ),
            categories: const [],
            page: const CursorPage(items: [], hasMore: false),
          ),
        );
      }
      await pending;
    });
  }
}

SessionTokens _tokens(String value) =>
    SessionTokens(accessToken: value, refreshToken: '$value-refresh');

class _Auth extends Fake implements AuthRepository {
  final tokens = Completer<SessionTokens>();
  Future<RegistrationCodeInfo>? code;
  @override
  Future<SessionTokens> login({
    required String account,
    required String password,
  }) => tokens.future;
  @override
  Future<RegistrationCodeInfo> requestRegistrationCode({
    required String email,
  }) =>
      code ??
      Future.value(
        const RegistrationCodeInfo(expiresIn: Duration(minutes: 15)),
      );
  @override
  Future<SessionTokens> completeRegistration({
    required String email,
    required String code,
    required String username,
    required String password,
  }) => tokens.future;
}

class _Tokens implements TokenStore {
  SessionTokens? value;
  @override
  Future<SessionTokens?> read() async => value;
  @override
  Future<void> write(SessionTokens tokens) async {
    value = tokens;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

class _Remote extends Fake implements SessionRemote {
  final loggedOut = Completer<void>();
  @override
  Future<void> logout(SessionTokens tokens) => loggedOut.future;
}

class _Categories extends Fake implements ThreadCategoryCatalogRepository {
  final result = Completer<List<HomeCategory>>();
  @override
  Future<List<HomeCategory>> fetchThreadCategories() => result.future;
}

class _Tags extends Fake implements TagRepository {
  final result = Completer<TagThreadsBootstrap>();
  @override
  Future<TagThreadsBootstrap> loadTagThreads(String tagId) => result.future;
}
