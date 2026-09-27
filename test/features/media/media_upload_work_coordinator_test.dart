import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_work_coordinator.dart';

void main() {
  test('提前释放后失败不会再次释放占用中的下一任务', () async {
    final coordinator = MediaUploadWorkCoordinator(transferConcurrency: 1);
    final released = Completer<void>();
    final failed = Completer<int>();
    final next = Completer<int>();
    final started = <int>[];
    final first = coordinator.transfer(() {
      started.add(0);
      return failed.future;
    }, releaseWhen: released.future);
    final failureExpectation = expectLater(first, throwsStateError);
    final second = coordinator.transfer(() {
      started.add(1);
      return next.future;
    });
    final third = coordinator.transfer(() async {
      started.add(2);
      return 2;
    });
    released.complete();
    await Future<void>.delayed(Duration.zero);
    failed.completeError(StateError('remote processing failed'));
    await failureExpectation;
    await Future<void>.delayed(Duration.zero);
    expect(started, [0, 1]);
    next.complete(1);
    expect(await Future.wait([second, third]), [1, 2]);
  });

  test('确认完成释放传输名额，前两张仍处理时第三张可开始', () async {
    final coordinator = MediaUploadWorkCoordinator();
    final confirmed = List.generate(3, (_) => Completer<void>());
    final completed = List.generate(3, (_) => Completer<int>());
    final started = <int>[];
    final results = [
      for (var index = 0; index < 3; index++)
        coordinator.transfer(() {
          started.add(index);
          return completed[index].future;
        }, releaseWhen: confirmed[index].future),
    ];
    expect(started, [0, 1]);
    confirmed[0].complete();
    await Future<void>.delayed(Duration.zero);
    expect(started, [0, 1, 2]);
    expect(completed[0].isCompleted, isFalse);
    expect(completed[1].isCompleted, isFalse);
    for (var index = 0; index < 3; index++) {
      completed[index].complete(index);
    }
    expect(await Future.wait(results), [0, 1, 2]);
  });

  test('查询最多两路并与图片传输互不阻塞', () async {
    final coordinator = MediaUploadWorkCoordinator();
    final completions = List.generate(3, (_) => Completer<int>());
    final started = <int>[];
    final queries = [
      for (var index = 0; index < 3; index++)
        coordinator.query(() {
          started.add(index);
          return completions[index].future;
        }),
    ];
    expect(started, [0, 1]);
    expect(await coordinator.transfer(() async => 7), 7);
    completions[0].complete(0);
    await Future<void>.delayed(Duration.zero);
    expect(started, [0, 1, 2]);
    completions[1].complete(1);
    completions[2].complete(2);
    expect(await Future.wait(queries), [0, 1, 2]);
  });

  test('图片准备严格单路，上传传输最多同时两路', () async {
    final coordinator = MediaUploadWorkCoordinator();
    final preparationCompletions = [Completer<int>(), Completer<int>()];
    var activePreparation = 0;
    var maximumPreparation = 0;
    final preparations = [
      for (var index = 0; index < 2; index++)
        coordinator.prepare(() async {
          activePreparation += 1;
          maximumPreparation = maximumPreparation < activePreparation
              ? activePreparation
              : maximumPreparation;
          final value = await preparationCompletions[index].future;
          activePreparation -= 1;
          return value;
        }),
    ];
    await Future<void>.delayed(Duration.zero);
    expect(activePreparation, 1);
    preparationCompletions[0].complete(0);
    await Future<void>.delayed(Duration.zero);
    expect(activePreparation, 1);
    preparationCompletions[1].complete(1);
    expect(await Future.wait(preparations), [0, 1]);
    expect(maximumPreparation, 1);

    final transferCompletions = [
      Completer<int>(),
      Completer<int>(),
      Completer<int>(),
    ];
    var activeTransfers = 0;
    var maximumTransfers = 0;
    final transfers = [
      for (var index = 0; index < 3; index++)
        coordinator.transfer(() async {
          activeTransfers += 1;
          maximumTransfers = maximumTransfers < activeTransfers
              ? activeTransfers
              : maximumTransfers;
          final value = await transferCompletions[index].future;
          activeTransfers -= 1;
          return value;
        }),
    ];
    await Future<void>.delayed(Duration.zero);
    expect(activeTransfers, 2);
    transferCompletions[0].complete(0);
    await Future<void>.delayed(Duration.zero);
    expect(activeTransfers, 2);
    transferCompletions[1].complete(1);
    transferCompletions[2].complete(2);
    expect(await Future.wait(transfers), [0, 1, 2]);
    expect(maximumTransfers, 2);
  });
}
