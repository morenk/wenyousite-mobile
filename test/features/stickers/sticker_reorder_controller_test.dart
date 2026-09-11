import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

import 'sticker_reorder_test_support.dart';

void main() {
  late ReorderTestRepository repository;
  late StickerCollectionController controller;

  setUp(() async {
    repository = ReorderTestRepository();
    controller = StickerCollectionController(
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
    );
    await controller.load();
  });
  tearDown(() => controller.dispose());

  test('落位立即共享乐观顺序，成功只更新版本且没有成功提示', () async {
    final saving = controller.reorder(stickers(['b', 'c', 'a']));
    expect(ids(controller), ['b', 'c', 'a']);
    expect(controller.state.collection!.items.map((item) => item.position), [
      0,
      1,
      2,
    ]);
    expect(controller.state.action, StickerAction.reordering);
    expect(repository.writes.single.version, 3);
    repository.complete(0);
    expect(await saving, isTrue);
    expect(ids(controller), ['b', 'c', 'a']);
    expect(controller.state.collection!.version, 4);
    expect(controller.state.successMessage, isNull);
    expect(controller.state.isBusy, isFalse);
  });

  test('连续拖动合并最新顺序，旧成功响应不会闪回，串行使用确认版本', () async {
    final first = controller.reorder(stickers(['b', 'a', 'c']));
    final second = controller.reorder(stickers(['c', 'b', 'a']));
    final last = controller.reorder(stickers(['c', 'a', 'b']));
    expect(repository.writes, hasLength(1));
    expect(ids(controller), ['c', 'a', 'b']);
    repository.complete(0);
    await Future<void>.delayed(Duration.zero);
    expect(ids(controller), ['c', 'a', 'b']);
    expect(repository.writes, hasLength(2));
    expect(repository.writes[1].version, 4);
    expect(repository.writes[1].ids, ['c', 'a', 'b']);
    repository.complete(1);
    expect(await Future.wait([first, second, last]), everyElement(isTrue));
    expect(controller.state.collection!.version, 5);
  });

  test('保存失败恢复最近确认顺序并清掉后续未保存意图', () async {
    final saving = controller.reorder(stickers(['b', 'a', 'c']));
    unawaited(controller.reorder(stickers(['c', 'b', 'a'])));
    repository.complete(0);
    await Future<void>.delayed(Duration.zero);
    unawaited(controller.reorder(stickers(['a', 'c', 'b'])));
    repository.writes[1].result.completeError(
      const ApiFailure(userMessage: '操作失败，请重试。'),
    );
    expect(await saving, isFalse);
    expect(ids(controller), ['b', 'a', 'c']);
    expect(controller.state.collection!.version, 4);
    expect(controller.state.transientFailure, isNotNull);
    expect(repository.writes, hasLength(2));
    final retry = controller.reorder(stickers(['a', 'c', 'b']));
    expect(repository.writes[2].version, 4);
    repository.complete(2);
    expect(await retry, isTrue);
  });

  test('首个保存失败回退原顺序，原位放下不请求', () async {
    expect(await controller.reorder(stickers(['a', 'b', 'c'])), isTrue);
    expect(repository.writes, isEmpty);
    final saving = controller.reorder(stickers(['c', 'b', 'a']));
    repository.writes.single.result.completeError(
      const ApiFailure(userMessage: '操作失败'),
    );
    expect(await saving, isFalse);
    expect(ids(controller), ['a', 'b', 'c']);
    expect(controller.state.successMessage, isNull);
  });

  test('拖动前的迟到刷新及保存中的下拉刷新不覆盖乐观顺序', () async {
    repository.nextRead = Completer<StickerCollection>();
    final loading = controller.load();
    final saving = controller.reorder(stickers(['c', 'b', 'a']));
    await controller.load();
    expect(repository.reads, 2);
    repository.nextRead!.complete(stickerCollection());
    await loading;
    expect(ids(controller), ['c', 'b', 'a']);
    expect(controller.state.action, StickerAction.reordering);
    repository.complete(0);
    await saving;
  });

  test('40911 保留错误并校准其他设备版本，校准期间不接收新排序', () async {
    repository.nextRead = Completer<StickerCollection>();
    final saving = controller.reorder(stickers(['c', 'b', 'a']));
    repository.writes.single.result.completeError(
      const ApiFailure(businessCode: 40911, userMessage: '收藏夹已在其他设备修改，请刷新后重试。'),
    );
    await Future<void>.delayed(Duration.zero);
    expect(ids(controller), ['a', 'b', 'c']);
    expect(await controller.reorder(stickers(['b', 'c', 'a'])), isFalse);
    repository.nextRead!.complete(
      stickerCollection(order: ['a', 'c', 'b'], version: 9),
    );
    expect(await saving, isFalse);
    expect(ids(controller), ['a', 'c', 'b']);
    expect(controller.state.collection!.version, 9);
    expect(controller.state.transientFailure!.businessCode, 40911);
    expect(controller.state.isBusy, isFalse);
  });

  test('销毁控制器后迟到保存不触发状态回写或第二次写入', () async {
    final temporary = StickerCollectionController(
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
    );
    await temporary.load();
    final saving = temporary.reorder(stickers(['c', 'b', 'a']));
    temporary.dispose();
    repository.complete(0);
    expect(await saving, isFalse);
    expect(repository.writes, hasLength(1));
  });
}
