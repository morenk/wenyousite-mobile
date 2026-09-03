import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_autosave.dart';

void main() {
  testWidgets('连续输入只在最后一次修改静止 1.2 秒后保存', (tester) async {
    var dirty = true;
    var saves = 0;
    final coordinator = ThreadManagementAutosaveCoordinator(
      hasChanges: () => dirty,
      onSave: () async {
        saves += 1;
        dirty = false;
        return true;
      },
    );
    addTearDown(coordinator.dispose);

    coordinator.schedule();
    await tester.pump(const Duration(milliseconds: 800));
    coordinator.schedule();
    await tester.pump(const Duration(milliseconds: 1199));
    expect(saves, 0);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(saves, 1);
    expect(coordinator.status, ThreadManagementAutosaveStatus.saved);

    await tester.pump(const Duration(milliseconds: 1499));
    expect(coordinator.status, ThreadManagementAutosaveStatus.saved);
    await tester.pump(const Duration(milliseconds: 1));
    expect(coordinator.status, ThreadManagementAutosaveStatus.idle);
  });

  testWidgets('写入期间的新修改串行合并到下一次保存', (tester) async {
    var draftVersion = 1;
    var savedVersion = 0;
    var saves = 0;
    final firstWrite = Completer<void>();
    final coordinator = ThreadManagementAutosaveCoordinator(
      hasChanges: () => draftVersion != savedVersion,
      onSave: () async {
        saves += 1;
        final writingVersion = draftVersion;
        if (saves == 1) await firstWrite.future;
        savedVersion = writingVersion;
        return true;
      },
    );
    addTearDown(coordinator.dispose);

    final saving = coordinator.saveNow();
    await tester.pump();
    expect(saves, 1);
    draftVersion = 2;
    unawaited(coordinator.saveNow());

    firstWrite.complete();
    await tester.pump();
    await saving;
    expect(saves, 2);
    expect(savedVersion, 2);
    expect(coordinator.status, ThreadManagementAutosaveStatus.saved);
    await tester.pump(const Duration(milliseconds: 1500));
    expect(coordinator.status, ThreadManagementAutosaveStatus.idle);
  });

  testWidgets('保存成功退场前的新修改会切换为待保存', (tester) async {
    var dirty = true;
    final coordinator = ThreadManagementAutosaveCoordinator(
      hasChanges: () => dirty,
      onSave: () async {
        dirty = false;
        return true;
      },
    );
    addTearDown(coordinator.dispose);

    await coordinator.saveNow();
    expect(coordinator.status, ThreadManagementAutosaveStatus.saved);
    await tester.pump(const Duration(milliseconds: 1000));

    dirty = true;
    coordinator.schedule();
    expect(coordinator.status, ThreadManagementAutosaveStatus.scheduled);
    await tester.pump(const Duration(milliseconds: 500));
    expect(coordinator.status, ThreadManagementAutosaveStatus.scheduled);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    expect(coordinator.status, ThreadManagementAutosaveStatus.saved);
    await tester.pump(const Duration(milliseconds: 1500));
    expect(coordinator.status, ThreadManagementAutosaveStatus.idle);
  });
}
