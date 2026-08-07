import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'wenyou_mobile.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
