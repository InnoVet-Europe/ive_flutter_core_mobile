import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:ive_flutter_core_mobile/database/migrations.dart';

/// [DBProvider] is a lightweight class to help with some common DB functions
class DBProvider {
  /// [deleteDb] does what it says on the tin.  ;-)
  static Future<bool> deleteDb(String dbName) async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, dbName);
    await deleteDatabase(path);

    return true;
  }

  /// [openOrInitDb] will open a database if one exists or will
  /// create a new one if one is not already present. It returns
  /// a pointer to the DB as a Future.
  static Future<Database> openOrInitDb(
    String dbName,
    int dbVersion,
    Function informUser,
    List<MigrationsModel> migrations, {
    required Function createTables,
    required Function openDb,
    required String clientAppIdentifier,
  }) async {
    // DBs are stored in the documents directory on the mobile device.
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, dbName);
    return openDatabase(path, version: dbVersion, onOpen: (Database db) async {
      // run any code that needs to execute once the DB has been opened
      await openDb(db, informUser, clientAppIdentifier);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      // run any required DB migrations
      MigrationsTableHelper.doDatabaseMigrations(
          db, migrations, oldVersion, dbVersion);
    }, onCreate: (Database db, int version) async {
      // call back to a function that will create tables and indexes
      await createTables(db, version, informUser, clientAppIdentifier);
    }, onConfigure: (Database db) async {
      await db.execute('PRAGMA cache_size=1500000');
    });
  }
}
