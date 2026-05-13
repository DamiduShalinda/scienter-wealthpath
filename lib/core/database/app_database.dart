import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class BudgetsTable extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  RealColumn get spent => real()();
  RealColumn get limit => real()();
  TextColumn get currency => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(tables: <Type>[BudgetsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> replaceBudgets(List<BudgetsTableCompanion> budgets) async {
    await transaction(() async {
      await delete(budgetsTable).go();
      if (budgets.isNotEmpty) {
        await batch((batch) => batch.insertAll(budgetsTable, budgets));
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dbFolder.path, 'wealthpath.db'));
    return NativeDatabase.createInBackground(file);
  });
}
