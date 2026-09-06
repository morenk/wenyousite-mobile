import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/storage/app_database.dart';
import 'package:wenyousite_mobile/features/editor/data/editor_snapshot_store.dart';

void main() {
  test('首次主题快照与创建记录一起提交或一起回滚', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = DatabaseEditorSnapshotStore(database);
    await database.customStatement(
      '''CREATE TRIGGER fail_pending BEFORE INSERT
      ON pending_create_operations BEGIN SELECT RAISE(ABORT, 'test failure'); END''',
    );
    await expectLater(
      store.beginThreadCreate(_snapshot(), _operation()),
      throwsA(isA<Object>()),
    );
    expect(await store.findThreadSnapshot('owner'), isNull);
    expect(await store.findPendingCreate('request'), isNull);
    await database.customStatement('DROP TRIGGER fail_pending');
    await store.beginThreadCreate(_snapshot(), _operation());
    expect(
      (await store.findThreadSnapshot('owner'))?.clientRequestId,
      'request',
    );
    expect((await store.findPendingCreate('request'))?.normalizedPayload, '{}');
  });

  test('创建确认的远端关联与待确认清理必须原子完成', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = DatabaseEditorSnapshotStore(database);
    await store.beginThreadCreate(_snapshot(), _operation());
    await database.customStatement(
      '''CREATE TRIGGER fail_cleanup BEFORE DELETE
      ON pending_create_operations BEGIN SELECT RAISE(ABORT, 'test failure'); END''',
    );
    await expectLater(
      store.completeThreadCreate(_snapshot(remote: true)),
      throwsA(isA<Object>()),
    );
    expect((await store.findThreadSnapshot('owner'))?.metadataJson, '{}');
    expect(await store.findPendingCreate('request'), isNotNull);
    await database.customStatement('DROP TRIGGER fail_cleanup');
    await store.completeThreadCreate(_snapshot(remote: true));
    expect(
      (await store.findThreadSnapshot('owner'))?.metadataJson,
      '{"remoteDraft":"thread"}',
    );
    expect(await store.findPendingCreate('request'), isNull);
  });
}

LocalEditorSnapshot _snapshot({bool remote = false}) => LocalEditorSnapshot(
  id: threadEditorSnapshotId('owner'),
  contextType: EditorContextType.thread,
  body: '**完整正文**',
  metadataJson: remote ? '{"remoteDraft":"thread"}' : '{}',
  clientRequestId: 'request',
  updatedAt: DateTime.utc(2026, 9, 7),
);

PendingCreateOperation _operation() => PendingCreateOperation(
  clientRequestId: 'request',
  operationType: 'thread.create',
  normalizedPayload: '{}',
  state: PendingOperationState.sending,
  updatedAt: DateTime.utc(2026, 9, 7),
);
