import 'dart:io';

import 'package:mbautomation/tracking/model/mb_automation_event.dart';
import 'package:mbautomation/tracking/model/mb_automation_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// The class that manages the automation DB that stores views and events tracked.
class MBAutomationDatabase {
  /// Initializes the DB and tables.
  static Future<void> initDb() async {
    await _database();
  }

  /// Opens and returns the database
  /// @returns An instance of a Database.
  static Future<Database> _database() async {
    String path = await _dbPath();
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return db;
  }

  /// Function called when the database is created, it creates the tables for views and  events
  /// @param db The database.
  /// @param version The version of the database.
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

  /// Saves a view in the DB.
  /// @param view The view to save.
  static Future<void> saveView(MBAutomationView view) async {
    Database db = await _database();
    await db.insert(
      'view',
      view.toDbDictionary(),
    );
  }

  /// Fetches the views saved in the DB.
  /// @returns A Future that completes whit the views retrieved from the DB.
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

  /// Deletes the views from the DB.
  /// @param views An array of views to delete.
  static Future<void> deleteViews(List<MBAutomationView> views) async {
    Database db = await _database();
    String viewIds = views.map((e) => e.id).toList().join(',');
    await db.rawQuery('DELETE FROM view WHERE id IN ($viewIds)');
  }

//endregion

//region event

  /// Saves an event in the DB.
  /// @param event The event to save.
  static Future<void> saveEvent(MBAutomationEvent event) async {
    Database db = await _database();
    await db.insert(
      'event',
      event.toDbDictionary(),
    );
  }

  /// Fetches the events saved in the DB.
  /// @returns A Future that completes whit the events retrieved from the DB.
  static Future<List<MBAutomationEvent>> events() async {
    Database db = await _database();
    final res = await db.query(
      'event',
      orderBy: 'timestamp ASC',
    );
    if (res.isNotEmpty) {
      return res.map((e) => MBAutomationEvent.fromDbData(dbData: e)).toList();
    }
    return null;
  }

  /// Deletes the events from the DB.
  /// @param views An array of events to delete.
  static Future<void> deleteEvents(List<MBAutomationEvent> events) async {
    Database db = await _database();
    String eventsIds = events.map((e) => e.id).toList().join(',');
    await db.rawQuery('DELETE FROM event WHERE id IN ($eventsIds)');
  }

//endregion

  /// The path for the Database.
  static Future<String> _dbPath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "mb_automation_db_f.sqlite");
    return path;
  }
}
