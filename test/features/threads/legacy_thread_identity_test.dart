import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/production_overrides.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/contract_info.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_selection.dart';
import 'package:wenyousite_mobile/features/posts/application/post_publish_draft.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_identity_composer_bar.dart';
import 'package:wenyousite_mobile/features/thread_identity/data/thread_identity_repository.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

class _Posts extends Mock implements PostRepository {}

class _Input extends Fake implements PostCreateInput {}

void main() {
  late Dio dio;
  late ApiThreadIdentityRepository repo;
  late List<RequestOptions> requests;
  late Map<String, Object?> response;
  setUpAll(() => registerFallbackValue(_Input()));
  setUp(() {
    requests = [];
    response = {
      'threadId': 'thread',
      'userId': 'user',
      'enabled': true,
      'eligible': true,
      'canEdit': true,
      'identityToken': 'token',
      'identity': {
        'id': 'role',
        'nickname': '白鸦',
        'avatarMediaId': null,
        'version': 3,
      },
      'display': {'id': 'role', 'nickname': '白鸦', 'avatar': null},
      'account': {'id': 'user', 'username': '玛利亚', 'avatar': null},
    };
    dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'code': 0, 'message': 'ok', 'data': response},
            ),
          );
        },
      ),
    );
    repo = ApiThreadIdentityRepository(
      WenyouApi(dio: dio).getThreadsApi(),
      legacySingleIdentity: true,
    );
  });
  tearDown(() => dio.close(force: true));

  test('仅明确5.33启用旧入口，不因未知版本或角色新写关闭降级', () {
    for (final version in [
      '5.33.0-dev.20261005.1',
      '5.34.0-dev.1',
      '5.35.0',
      'unknown',
    ]) {
      final capability = appCapabilitiesForContract(
        ContractInfo(contractVersion: version, markdownContractVersion: 5),
      );
      expect(
        capability.legacySingleThreadIdentity,
        version.startsWith('5.33.'),
      );
    }
    expect(
      appCapabilitiesForContract(null).legacySingleThreadIdentity,
      isFalse,
    );
  });

  test('旧身份读取复用single，账号默认且不提供新增或归档', () async {
    final selection = PostIdentitySelection(repo, 'thread');
    addTearDown(selection.dispose);
    expect(await selection.refresh(), isTrue);
    expect(requests.single.path, endsWith('/threads/thread/identity'));
    expect(selection.mode, PostIdentityMode.account);
    expect(selection.displayName, '玛利亚');
    expect(selection.collection!.limit, 1);
    expect(selection.collection!.identities.single.canDelete, isFalse);
    selection.select(PostIdentityMode.rp, id: 'role');
    expect(selection.displayName, '白鸦');
    expect(selection.acceptedToken, 'token');
    response['identity'] = null;
    response['display'] = null;
    expect(await selection.refresh(), isTrue);
    expect(selection.changed, isTrue);
    expect(selection.collection!.limit, 0);
    expect(selection.collection!.identities, isEmpty);
  });

  test('既有角色编辑校验同ID与已读version，不映射新建和无版本DELETE', () async {
    await repo.updateRole(
      'thread',
      'role',
      const ThreadIdentityUpdate(nickname: '新名', version: 3),
    );
    expect(requests.map((r) => r.method), ['GET', 'PUT']);
    expect(requests.last.data, containsPair('version', 3));
    requests.clear();
    await expectLater(
      repo.updateRole(
        'thread',
        'other',
        const ThreadIdentityUpdate(version: 3),
      ),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(
      repo.updateRole('thread', 'role', const ThreadIdentityUpdate(version: 2)),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(
      repo.updateRole('thread', 'role', const ThreadIdentityUpdate()),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(
      repo.create('thread', const ThreadIdentityUpdate(nickname: '新角色')),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(
      repo.remove('thread', 'role', 3),
      throwsA(isA<ApiFailure>()),
    );
    expect(requests.every((r) => r.method == 'GET'), isTrue);
  });

  test('新版集合404保持失败，不能误退回single', () async {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: Response(requestOptions: options, statusCode: 404),
            ),
          );
        },
      ),
    );
    final modern = ApiThreadIdentityRepository(
      WenyouApi(dio: dio).getThreadsApi(),
    );
    await expectLater(modern.list('thread'), throwsA(isA<ApiFailure>()));
    expect(requests.single.path, endsWith('/rp-identities'));
  });

  test('旧历史卡按真实账号读取且必须匹配原角色ID', () async {
    final container = ProviderContainer(
      overrides: [
        appCapabilitiesProvider.overrideWithValue(
          const AppCapabilities(legacySingleThreadIdentity: true),
        ),
        threadIdentityRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    final state = await container.read(
      rpIdentityCardProvider((
        threadId: 'thread',
        userId: 'user',
        identityId: 'role',
      )).future,
    );
    expect(state.identityId, 'role');
    expect(requests.single.path, endsWith('/identities/user'));
    await expectLater(
      container.read(
        rpIdentityCardProvider((
          threadId: 'thread',
          userId: 'user',
          identityId: 'another',
        )).future,
      ),
      throwsA(isA<StateError>()),
    );
  });

  testWidgets('旧环境无资料只显示站内账号，不显示错误和加号入口', (tester) async {
    response['identity'] = null;
    response['display'] = null;
    final selection = PostIdentitySelection(repo, 'thread');
    addTearDown(selection.dispose);
    await tester.runAsync(selection.refresh);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PostIdentityComposerBar(
            selection: selection,
            locked: false,
            onSettings: (_) => fail('不应提供新增'),
          ),
        ),
      ),
    );
    expect(find.text('玛利亚'), findsOneWidget);
    expect(find.textContaining('加载失败'), findsNothing);
    expect(find.text('设置帖内身份'), findsNothing);
  });

  test('旧协议首次发言不携ID，未知结果恢复后升级服务也不补ID或换UUID', () async {
    final posts = _Posts();
    final sent = <PostCreateInput>[];
    when(() => posts.create(any())).thenAnswer((invocation) async {
      sent.add(invocation.positionalArguments.single as PostCreateInput);
      throw const ApiFailure(
        reason: FailureReason.timeout,
        source: FailureSource.network,
      );
    });
    const PostComposerTarget target = (
      kind: PostComposerKind.createFloor,
      threadId: 'thread',
      subthreadId: 'sub',
      postId: null,
      parentPostId: null,
      replyToPostId: null,
      version: null,
      initialContent: '草稿',
      label: '发表',
    );
    final first = PostComposerController(
      posts,
      target,
      createRequestId: () => 'same-uuid',
    );
    addTearDown(first.dispose);
    await first.submit(
      identityMode: PostIdentityMode.rp,
      identityId: 'role',
      identityToken: 'token',
      legacySingleIdentity: true,
    );
    expect(sent.single.identityId, isNull);
    final snapshot = PostPublishDraft(
      mode: PostIdentityMode.rp,
      identityId: 'role',
      identityToken: 'token',
      pending: first.state.pendingCreate,
    );
    final restored = PostPublishDraft.fromJson(snapshot.toJson())!;
    expect(restored.identityId, 'role');
    final second = PostComposerController(posts, target);
    addTearDown(second.dispose);
    second.restorePendingCreate(restored.pending!);
    await second.submit(
      identityMode: PostIdentityMode.rp,
      identityId: 'role',
      identityToken: 'token',
    );
    expect(sent.last.identityId, isNull);
    expect(sent.last.clientRequestId, 'same-uuid');
    expect(sent.last.identityToken, 'token');
  });
}
