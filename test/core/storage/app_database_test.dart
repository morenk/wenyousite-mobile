import 'dart:io';

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

  test('schema v1 快照可直接打开并保留草稿与待确认操作', () async {
    final directory = await Directory.systemTemp.createTemp('wenyou-db-v1-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}v1.sqlite');
    final seed = AppDatabase.forTesting(NativeDatabase(file));
    await seed.customStatement('DROP TABLE local_editor_snapshots');
    await seed.customStatement('DROP TABLE pending_create_operations');
    final fixture = File(
      'test/fixtures/app_database/schema_v1.sql',
    ).readAsStringSync();
    for (final statement in fixture.split(';')) {
      if (statement.trim().isNotEmpty) {
        await seed.customStatement(statement);
      }
    }
    await seed.customStatement(
      'INSERT INTO local_editor_snapshots '
      '(id, context_type, context_id, body, metadata_json, '
      'client_request_id, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        'thread:new:user-one',
        'thread',
        null,
        '保留的正文',
        '{"title":"标题"}',
        '550e8400-e29b-41d4-a716-446655440000',
        DateTime.utc(2026, 8, 10).millisecondsSinceEpoch ~/ 1000,
      ],
    );
    await seed.customStatement(
      'INSERT INTO pending_create_operations '
      '(client_request_id, operation_type, normalized_payload, state, '
      'updated_at) VALUES (?, ?, ?, ?, ?)',
      [
        '550e8400-e29b-41d4-a716-446655440000',
        'thread.create',
        '{"title":"标题"}',
        'awaitingConfirmation',
        DateTime.utc(2026, 8, 10).millisecondsSinceEpoch ~/ 1000,
      ],
    );
    await seed.close();

    final database = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(database.close);

    expect(
      (await database.findEditorSnapshot('thread:new:user-one'))?.body,
      '保留的正文',
    );
    expect(
      await database.findPendingCreateOperation(
        '550e8400-e29b-41d4-a716-446655440000',
      ),
      isA<PendingCreateOperation>(),
    );
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 1);
  });

  test('未知存储枚举不会被当作有效草稿或待确认状态', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.customStatement(
      'INSERT INTO local_editor_snapshots '
      '(id, context_type, context_id, body, metadata_json, '
      'client_request_id, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        'unknown-context',
        'futureContext',
        null,
        '正文',
        '{}',
        '550e8400-e29b-41d4-a716-446655440001',
        DateTime.utc(2026, 8, 10).millisecondsSinceEpoch ~/ 1000,
      ],
    );
    await database.customStatement(
      'INSERT INTO pending_create_operations '
      '(client_request_id, operation_type, normalized_payload, state, '
      'updated_at) VALUES (?, ?, ?, ?, ?)',
      [
        '550e8400-e29b-41d4-a716-446655440002',
        'thread.create',
        '{}',
        'futureState',
        DateTime.utc(2026, 8, 10).millisecondsSinceEpoch ~/ 1000,
      ],
    );

    expect(await database.findEditorSnapshot('unknown-context'), isNull);
    expect(
      await database.findPendingCreateOperation(
        '550e8400-e29b-41d4-a716-446655440002',
      ),
      isNull,
    );
  });
}
