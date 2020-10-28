import 'dart:io';

import 'package:mbautomation/tracking/model/mb_automation_event.dart';
import 'package:mbautomation/tracking/model/mb_automation_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MBAutomationDatabase {
  static Future<void> initDb() async {
    await _database();
  }

  static Future<Database> _database() async {
    String path = await _dbPath();
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return db;
  }

  static void _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS view '
      '(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      'view TEXT, '
      'metadata TEXT, '
      'timestamp INT);',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS event '
      '(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      'event TEXT, '
      'name TEXT, '
      'metadata TEXT, '
      'timestamp INT);',
    );
  }

//region view

  static Future<void> saveView(MBAutomationView view) async {
    Database db = await _database();
    await db.insert(
      'view',
      view.toDbDictionary(),
    );
  }

  static Future<List<MBAutomationView>> views() async {
    Database db = await _database();
    final res = await db.query(
      'view',
      orderBy: 'timestamp ASC',
    );
    if (res.isNotEmpty) {
      return res.map((e) => MBAutomationView.fromDbData(dbData: e)).toList();
    }
    return null;
  }

  static Future<void> deleteViews(List<MBAutomationView> views) async {
    Database db = await _database();
    String viewIds = views.map((e) => e.id).toList().join(',');
    await db.rawQuery('DELETE FROM view WHERE id IN ($viewIds)');
  }

//endregion

//region event

  static Future<void> saveEvent(MBAutomationEvent event) async {
    Database db = await _database();
    await db.insert(
      'event',
      event.toDbDictionary(),
    );
  }

  static Future<List<MBAutomationEvent>> events() async {
    Database db = await _database();
    final res = await db.query(
      'view',
      orderBy: 'timestamp ASC',
    );
    if (res.isNotEmpty) {
      return res.map((e) => MBAutomationEvent.fromDbData(dbData: e)).toList();
    }
    return null;
  }

  static Future<void> deleteEvents(List<MBAutomationEvent> events) async {
    Database db = await _database();
    String eventsIds = events.map((e) => e.id).toList().join(',');
    await db.rawQuery('DELETE FROM event WHERE id IN ($eventsIds)');
  }

//endregion

  static Future<String> _dbPath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "mb_automation_db_f.sqlite");
    return path;
  }
}
