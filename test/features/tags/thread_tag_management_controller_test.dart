import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/tags/application/thread_tag_management_controller.dart';
import 'package:wenyousite_mobile/features/tags/data/tag_repository.dart';
import 'package:wenyousite_mobile/features/tags/domain/tag_models.dart';

void main() {
  test('快速搜索时旧响应不能覆盖新关键词', () async {
    final oldResult = Completer<List<TopicTagModel>>();
    final newResult = Completer<List<TopicTagModel>>();
    final repository = _FakeTagRepository(
      onSearch: (query) => query == '旧' ? oldResult.future : newResult.future,
    );
    final controller = ThreadTagManagementController(
      'thread-1',
      repository,
      autoStart: false,
    );
    await controller.load();

    final oldRequest = controller.search('旧');
    final newRequest = controller.search('新');
    newResult.complete([_tag(id: 'new', name: '新')]);
    await newRequest;
    oldResult.complete([_tag(id: 'old', name: '旧')]);
    await oldRequest;

    expect(controller.state.query, '新');
    expect(controller.state.bootstrap!.suggestions.single.id, 'new');
  });

  test('添加已有标签先读取最新详情再关联主题', () async {
    final repository = _FakeTagRepository();
    final controller = ThreadTagManagementController(
      'thread-1',
      repository,
      autoStart: false,
    );
    await controller.load();

    final succeeded = await controller.addExisting(
      _tag(id: 'tag-2', name: '群像'),
    );

    expect(succeeded, isTrue);
    expect(repository.findIds, ['tag-2']);
    expect(repository.addedNames, ['群像']);
    expect(controller.state.bootstrap!.tags.last.id, 'tag-2');
  });

  test('创建遇到 40905 时解析唯一同名标签并继续添加', () async {
    final repository = _FakeTagRepository(
      createFailure: const ApiFailure(
        userMessage: '标签已存在',
        businessCode: 40905,
        httpStatus: 409,
      ),
    );
    final controller = ThreadTagManagementController(
      'thread-1',
      repository,
      autoStart: false,
    );
    await controller.load();

    final succeeded = await controller.createAndAdd(' 群像 ');

    expect(succeeded, isTrue);
    expect(repository.searches.last, '群像');
    expect(repository.findIds, ['tag-2']);
    expect(repository.addedNames, ['群像']);
  });

  test('达到五个标签后本地拒绝第六个写请求', () async {
    final repository = _FakeTagRepository(
      bootstrap: _bootstrap(
        tags: List.generate(
          maxThreadTagCount,
          (index) => _tag(id: 'tag-$index', name: '标签$index'),
        ),
      ),
    );
    final controller = ThreadTagManagementController(
      'thread-1',
      repository,
      autoStart: false,
    );
    await controller.load();

    expect(
      await controller.addExisting(_tag(id: 'sixth', name: '第六个')),
      isFalse,
    );
    expect(repository.addedNames, isEmpty);
  });

  test('移除失败保留原标签并暴露请求 ID', () async {
    final repository = _FakeTagRepository(
      removeFailure: const ApiFailure(
        userMessage: '暂时无法移除标签',
        requestId: 'tag-remove-request',
      ),
    );
    final controller = ThreadTagManagementController(
      'thread-1',
      repository,
      autoStart: false,
    );
    await controller.load();

    expect(await controller.remove(_tag()), isFalse);
    expect(controller.state.bootstrap!.tags.single.id, 'tag-1');
    expect(controller.state.failure!.requestId, 'tag-remove-request');
  });
}

class _FakeTagRepository implements TagRepository {
  _FakeTagRepository({
    ThreadTagManagementBootstrap? bootstrap,
    this.onSearch,
    this.createFailure,
    this.removeFailure,
  }) : bootstrap = bootstrap ?? _bootstrap();

  final ThreadTagManagementBootstrap bootstrap;
  final Future<List<TopicTagModel>> Function(String query)? onSearch;
  final ApiFailure? createFailure;
  final ApiFailure? removeFailure;
  final searches = <String>[];
  final findIds = <String>[];
  final addedNames = <String>[];

  @override
  Future<TopicTagModel> addToThread({
    required String threadId,
    required String name,
  }) async {
    addedNames.add(name);
    return name == '群像' ? _tag(id: 'tag-2', name: name) : _tag(name: name);
  }

  @override
  Future<TopicTagModel> create(String name) async {
    if (createFailure != null) throw createFailure!;
    return _tag(id: 'created', name: name);
  }

  @override
  Future<TopicTagModel> findById(String tagId) async {
    findIds.add(tagId);
    return tagId == 'tag-2' ? _tag(id: tagId, name: '群像') : _tag(id: tagId);
  }

  @override
  Future<CursorPage<HomeThreadCardModel>> fetchTagThreads({
    required String tagId,
    String? cursor,
    int limit = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ThreadTagManagementBootstrap> loadManagement(String threadId) async {
    return bootstrap;
  }

  @override
  Future<TagThreadsBootstrap> loadTagThreads(String tagId) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeFromThread({
    required String threadId,
    required String tagId,
  }) async {
    if (removeFailure != null) throw removeFailure!;
  }

  @override
  Future<List<TopicTagModel>> search(String query) {
    searches.add(query);
    return onSearch?.call(query) ??
        Future.value([_tag(id: 'tag-2', name: '群像')]);
  }
}

ThreadTagManagementBootstrap _bootstrap({List<TopicTagModel>? tags}) {
  return ThreadTagManagementBootstrap(
    threadId: 'thread-1',
    threadTitle: '星海旅团',
    tags: tags ?? [_tag()],
    suggestions: [
      _tag(),
      _tag(id: 'tag-2', name: '群像'),
    ],
  );
}

TopicTagModel _tag({String id = 'tag-1', String name = '太空歌剧'}) {
  return TopicTagModel(
    id: id,
    name: name,
    color: '#704C65',
    sortOrder: id == 'tag-1' ? 1 : 2,
    isActive: true,
  );
}
