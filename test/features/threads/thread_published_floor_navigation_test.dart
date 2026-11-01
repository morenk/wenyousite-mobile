import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_published_floor_navigation.dart';
import 'thread_publish_locate_support.dart';

void main() {
  late PublishedFloorRepository repository;
  late ThreadDetailController controller;
  late ThreadPublishedFloorNavigation navigation;
  setUp(() async {
    repository = PublishedFloorRepository();
    controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    navigation = ThreadPublishedFloorNavigation();
    await controller.loadInitial();
  });
  tearDown(() {
    navigation.dispose();
    controller.dispose();
  });
  Future<void> locate(int number, {bool Function()? active}) =>
      navigation.locate(
        saved: publishedPost(number),
        controller: controller,
        order: controller.state.floorOrder,
        authorId: controller.state.floorAuthorId,
        active: active ?? () => true,
      );

  test('同目标在途合并；只读目标窗口，不先刷新元数据', () async {
    final first = locate(2);
    await locate(2);
    expect(repository.targets, hasLength(1));
    expect(repository.threadCalls, 1);
    expect(controller.state.isPrefetchingFloors, isTrue);
    repository.requests.single.complete(publishedWindow(2));
    await first;
    expect(navigation.ready, isTrue);
    expect(controller.state.floors.single.id, 'published-2');
    expect(controller.state.isPrefetchingFloors, isFalse);
  });

  test('连续发布旧响应晚到不覆盖新窗口、不释放新请求状态', () async {
    final first = locate(2);
    final second = locate(3);
    repository.requests[0].complete(publishedWindow(2));
    await first;
    expect(navigation.loading, isTrue);
    expect(controller.state.isPrefetchingFloors, isTrue);
    repository.requests[1].complete(publishedWindow(3));
    await second;
    expect(controller.state.floors.single.id, 'published-3');
    expect(navigation.post?.id, 'published-3');
  });

  test('失败停止，重试只增加一个目标 GET', () async {
    final first = locate(2);
    repository.requests.single.completeError(
      const ApiFailure(httpStatus: 429, userMessage: '稍后重试'),
    );
    await first;
    expect(navigation.failure?.httpStatus, 429);
    expect(navigation.post?.id, 'published-2');
    expect(navigation.loading, isFalse);
    expect(controller.state.floors.single.id, 'floor-1');
    final retry = locate(2);
    expect(repository.targets, hasLength(2));
    repository.requests.last.complete(publishedWindow(2));
    await retry;
    expect(navigation.ready, isTrue);
  });

  test('用户滚动让出控制，旧结果不改变窗口，仍可明确查看', () async {
    final first = locate(2);
    navigation.release();
    repository.requests.single.complete(publishedWindow(2));
    await first;
    expect(controller.state.floors.single.id, 'floor-1');
    expect(controller.state.isPrefetchingFloors, isFalse);
    expect(navigation.post?.id, 'published-2');
    expect(navigation.ready, isFalse);
    final retry = locate(2);
    repository.requests.last.complete(publishedWindow(2));
    await retry;
    expect(navigation.ready, isTrue);
  });

  test('切换身份或离开页面后的成功响应不能应用', () async {
    var active = true;
    final first = locate(2, active: () => active);
    active = false;
    navigation.clear();
    repository.requests.single.complete(publishedWindow(2));
    await first;
    expect(navigation.post, isNull);
    expect(controller.state.floors.single.id, 'floor-1');
    expect(controller.state.isPrefetchingFloors, isFalse);
  });

  test('切换子贴后迟到定位不覆盖新范围', () async {
    final first = locate(2);
    await controller.selectSubthread('subthread-2');
    repository.requests.single.complete(publishedWindow(2));
    await first;
    expect(controller.state.selectedSubthreadId, 'subthread-2');
    expect(
      controller.state.floors.any((floor) => floor.id == 'published-2'),
      isFalse,
    );
    expect(navigation.ready, isFalse);
  });

  test('目标在筛选外只按 40010 恢复筛选并重读目标', () async {
    await controller.setFloorAuthor('other-user');
    final first = locate(2);
    repository.requests.single.completeError(
      const ApiFailure(
        httpStatus: 409,
        businessCode: 40010,
        userMessage: '不在筛选内',
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(repository.targets.map((item) => item.author), ['other-user', null]);
    repository.requests.last.complete(publishedWindow(2));
    await first;
    expect(controller.state.floorAuthorId, isNull);
    expect(navigation.clearedAuthor, isTrue);
  });

  test('私帖权限撤回不保留旧正文，发布成功信息仍独立保留', () async {
    final first = locate(2);
    repository.requests.single.completeError(
      const ApiFailure(httpStatus: 403, userMessage: '无权查看'),
    );
    await first;
    expect(controller.state.phase, ThreadDetailPhase.failed);
    expect(controller.state.floors, isEmpty);
    expect(controller.state.detail, isNull);
    expect(navigation.post?.id, 'published-2');
    expect(navigation.failure?.httpStatus, 403);
  });

  test('深链自动定位在途时不因重复调用重发', () async {
    final first = controller.locateFloor('published-2');
    await controller.locateFloor('published-2');
    expect(repository.targets, hasLength(1));
    repository.requests.single.complete(publishedWindow(2));
    await first;
    expect(controller.state.floors.single.id, 'published-2');
  });
}
