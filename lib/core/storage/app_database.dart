import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';

part 'app_database.g.dart';

@DataClassName('LocalEditorSnapshotRow')
class LocalEditorSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get contextType => text()();
  TextColumn get contextId => text().nullable()();
  TextColumn get body => text()();
  TextColumn get metadataJson => text()();
  TextColumn get clientRequestId => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PendingCreateOperationRow')
class PendingCreateOperations extends Table {
  TextColumn get clientRequestId => text()();
  TextColumn get operationType => text()();
  TextColumn get normalizedPayload => text()();
  TextColumn get state => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {clientRequestId};
}

@DriftDatabase(tables: [LocalEditorSnapshots, PendingCreateOperations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<LocalEditorSnapshot?> findEditorSnapshot(String id) async {
    final row = await (select(
      localEditorSnapshots,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final contextType = EditorContextType.values
        .where((value) => value.name == row.contextType)
        .firstOrNull;
    if (contextType == null) return null;
    return LocalEditorSnapshot(
      id: row.id,
      contextType: contextType,
      contextId: row.contextId,
      body: row.body,
      metadataJson: row.metadataJson,
      clientRequestId: row.clientRequestId,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> saveEditorSnapshot(LocalEditorSnapshot snapshot) {
    return into(localEditorSnapshots).insertOnConflictUpdate(
      LocalEditorSnapshotsCompanion.insert(
        id: snapshot.id,
        contextType: snapshot.contextType.name,
        contextId: Value(snapshot.contextId),
        body: snapshot.body,
        metadataJson: snapshot.metadataJson,
        clientRequestId: snapshot.clientRequestId,
        updatedAt: snapshot.updatedAt,
      ),
    );
  }

  Future<int> deleteEditorSnapshot(String id) {
    return (delete(
      localEditorSnapshots,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<PendingCreateOperation?> findPendingCreateOperation(
    String clientRequestId,
  ) async {
    final row =
        await (select(pendingCreateOperations)
              ..where((table) => table.clientRequestId.equals(clientRequestId)))
            .getSingleOrNull();
    if (row == null) return null;
    final operationState = PendingOperationState.values
        .where((value) => value.name == row.state)
        .firstOrNull;
    if (operationState == null) return null;
    return PendingCreateOperation(
      clientRequestId: row.clientRequestId,
      operationType: row.operationType,
      normalizedPayload: row.normalizedPayload,
      state: operationState,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> savePendingCreateOperation(PendingCreateOperation operation) {
    return into(pendingCreateOperations).insertOnConflictUpdate(
      PendingCreateOperationsCompanion.insert(
        clientRequestId: operation.clientRequestId,
        operationType: operation.operationType,
        normalizedPayload: operation.normalizedPayload,
        state: operation.state.name,
        updatedAt: operation.updatedAt,
      ),
    );
  }

  Future<int> deletePendingCreateOperation(String clientRequestId) {
    return (delete(
      pendingCreateOperations,
    )..where((table) => table.clientRequestId.equals(clientRequestId))).go();
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'wenyou_mobile.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
