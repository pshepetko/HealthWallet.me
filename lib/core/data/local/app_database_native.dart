import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file, setup: (database) {
      // Enable foreign key constraints and other optimizations
      database.execute('PRAGMA foreign_keys = ON');
      database.execute('PRAGMA journal_mode = WAL');
      database.execute('PRAGMA synchronous = NORMAL');
      database.execute('PRAGMA cache_size = 10000');
      database.execute('PRAGMA temp_store = MEMORY');
    });
  });
}
