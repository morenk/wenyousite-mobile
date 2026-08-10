import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/storage/app_database.dart';

void main() {
  test('本地数据库创建编辑快照与待确认操作表', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final rows = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = rows.map((row) => row.read<String>('name')).toSet();

    expect(names, contains('local_editor_snapshots'));
    expect(names, contains('pending_create_operations'));
  });

  test('编辑快照按稳定 ID 覆盖保存、读取与删除', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final first = LocalEditorSnapshot(
      id: 'thread:new:user-one',
      contextType: EditorContextType.thread,
      body: '第一版',
      metadataJson: '{"title":"标题"}',
      clientRequestId: '550e8400-e29b-41d4-a716-446655440000',
      updatedAt: DateTime.utc(2026, 8, 10),
    );
    await database.saveEditorSnapshot(first);
    await database.saveEditorSnapshot(
      LocalEditorSnapshot(
        id: first.id,
        contextType: first.contextType,
        body: '第二版',
        metadataJson: first.metadataJson,
        clientRequestId: first.clientRequestId,
        updatedAt: DateTime.utc(2026, 8, 10, 1),
      ),
    );

    expect((await database.findEditorSnapshot(first.id))?.body, '第二版');
    expect(await database.deleteEditorSnapshot(first.id), 1);
    expect(await database.findEditorSnapshot(first.id), isNull);
  });

  test('待确认创建操作完整保存规范化载荷和状态', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final operation = PendingCreateOperation(
      clientRequestId: '550e8400-e29b-41d4-a716-446655440000',
      operationType: 'thread.create',
      normalizedPayload: '{"title":"标题"}',
      state: PendingOperationState.awaitingConfirmation,
      updatedAt: DateTime.utc(2026, 8, 10),
    );
    await database.savePendingCreateOperation(operation);

    expect(
      await database.findPendingCreateOperation(operation.clientRequestId),
      isA<PendingCreateOperation>()
          .having(
            (value) => value.normalizedPayload,
            'payload',
            operation.normalizedPayload,
          )
          .having(
            (value) => value.state,
            'state',
            PendingOperationState.awaitingConfirmation,
          ),
    );
    expect(
      await database.deletePendingCreateOperation(operation.clientRequestId),
      1,
    );
  });
}
