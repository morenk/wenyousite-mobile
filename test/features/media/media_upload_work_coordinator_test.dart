import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_work_coordinator.dart';

void main() {
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
