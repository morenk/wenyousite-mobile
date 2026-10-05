import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/features/thread_identity/data/thread_identity_repository.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

void main() {
  late Dio dio;
  late ApiThreadIdentityRepository repository;
  late List<RequestOptions> requests;
  late Map<String, Object?> response;
  setUp(() {
    requests = [];
    response = {
      'threadId': 'thread',
      'userId': 'user',
      'enabled': true,
      'eligible': true,
      'canEdit': true,
      'identityToken': 'confirmed',
      'identity': {
        'id': 'rp',
        'nickname': '白鸦',
        'avatarMediaId': null,
        'version': 3,
      },
      'display': {'id': 'rp', 'nickname': '白鸦', 'avatar': null},
      'account': {
        'id': 'user',
        'username': '站内账号',
        'avatar': 'https://example.com/account.png',
      },
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
    repository = ApiThreadIdentityRepository(
      WenyouApi(dio: dio).getThreadsApi(),
    );
  });
  tearDown(() => dio.close(force: true));

  void asRole() => response.addAll({
    'identityId': 'rp',
    'deleted': false,
    'compatibilityIdentity': true,
    'canDelete': true,
  });

  test('集合保留空资料名额和稳定角色 ID，拒绝跨账号成员', () async {
    asRole();
    final role = Map<String, Object?>.of(response);
    final empty = {
      ...role,
      'identityId': 'empty',
      'identity': {
        'id': 'empty',
        'nickname': null,
        'avatarMediaId': null,
        'version': 1,
      },
      'display': null,
    };
    response = {
      ...role,
      'identities': [role, empty],
      'activeCount': 2,
      'limit': 10,
      'compatibilityIdentityId': 'rp',
      'defaultIdentityId': 'rp',
    };
    final state = await repository.list('thread');
    expect(state.identities.length, 2);
    expect(state.find('empty')!.hasRp, isFalse);
    expect(state.defaultIdentityId, 'rp');
    response['identities'] = [
      role,
      {
        ...empty,
        'userId': 'other',
        'account': {'id': 'other', 'username': '其他', 'avatar': null},
      },
    ];
    await expectLater(repository.list('thread'), throwsA(isA<ApiFailure>()));
  });

  test('角色创建、更新与删除分别走集合端点，写请求不自动重放', () async {
    asRole();
    await repository.create(
      'thread',
      const ThreadIdentityUpdate(nickname: '白鸦'),
    );
    expect(requests.last.method, 'POST');
    expect(requests.last.path, endsWith('/rp-identities'));
    expect(requests.last.data, containsPair('nickname', '白鸦'));
    await repository.updateRole(
      'thread',
      'rp',
      const ThreadIdentityUpdate(nickname: '新名', clearAvatar: true, version: 3),
    );
    expect(requests.last.method, 'PUT');
    expect(requests.last.data, containsPair('version', 3));
    expect(requests.last.data, containsPair('clearAvatar', true));
    response.addAll({
      'deleted': true,
      'identity': null,
      'display': null,
      'identityToken': null,
      'canDelete': false,
    });
    final removed = await repository.remove('thread', 'rp', 3);
    expect(requests.last.method, 'DELETE');
    expect(requests.last.path, endsWith('/rp-identities/rp'));
    expect(requests.last.data, {'version': 3});
    expect(removed.deleted, isTrue);
    expect(removed.identityId, 'rp');
    expect(removed.hasRp, isFalse);
    expect(
      requests.every(
        (request) =>
            request.extra[ApiRequestExtraKeys.noAutomaticReplay] == true,
      ),
      isTrue,
    );
  });

  test('历史卡片只查同一个角色，不能接受其他角色的响应', () async {
    asRole();
    await repository.find('thread', 'rp');
    expect(requests.single.path, endsWith('/rp-identities/rp'));
    await expectLater(
      repository.find('thread', 'another'),
      throwsA(isA<ApiFailure>()),
    );
    response['display'] = {'id': 'another', 'nickname': '同名', 'avatar': null};
    await expectLater(
      repository.find('thread', 'rp'),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('昵称与头像分别清除使用显式标记，保存禁止自动重放', () async {
    final state = await repository.update(
      'thread',
      const ThreadIdentityUpdate(
        clearNickname: true,
        clearAvatar: true,
        version: 3,
      ),
    );
    final request = requests.single;
    expect(request.method, 'PUT');
    expect(request.path, endsWith('/threads/thread/identity'));
    expect(request.data, containsPair('clearNickname', true));
    expect(request.data, containsPair('clearAvatar', true));
    expect(request.data, containsPair('version', 3));
    expect(request.extra[ApiRequestExtraKeys.noAutomaticReplay], isTrue);
    expect(state.identityToken, 'confirmed');
    expect(state.displayName, '白鸦');
    // 治理移除后的空历史头像不能回退成今天的站内头像。
    expect(state.displayAvatarUrl, isNull);
  });

  test('关闭时不消费返回中的残留RP展示，账号关系保留', () async {
    response['enabled'] = false;
    final state = await repository.mine('thread');
    expect(state.display, isNull);
    expect(state.displayName, '站内账号');
    expect(state.userId, 'user');
  });

  test('卡片响应必须属于请求主题与账号', () async {
    await expectLater(
      repository.findUser('another-thread', 'user'),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(
      repository.findUser('thread', 'another-user'),
      throwsA(isA<ApiFailure>()),
    );
    response['account'] = {'id': 'other', 'username': '陌生账号', 'avatar': null};
    await expectLater(repository.mine('thread'), throwsA(isA<ApiFailure>()));
  });

  test('清除本人资料和主题开关使用专属端点，不写站内头像', () async {
    await repository.clear('thread');
    expect(requests.single.method, 'DELETE');
    expect(requests.single.path, endsWith('/threads/thread/identity'));
    response = {'enabled': false};
    await repository.setEnabled('thread', enabled: false);
    expect(requests.last.method, 'PATCH');
    expect(requests.last.path, endsWith('/threads/thread/identity-settings'));
    expect(requests.last.data, {'enabled': false});
    expect(
      requests.every(
        (r) => r.extra[ApiRequestExtraKeys.noAutomaticReplay] == true,
      ),
      isTrue,
    );
  });
}
