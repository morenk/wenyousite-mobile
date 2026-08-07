import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
