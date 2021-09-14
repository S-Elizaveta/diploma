import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import '../events.dart';
import '../notes.dart';

const String notesTable = 'notes';
const String columnNoteId = 'note_id';
const String columnTitle = 'title';
const String columnSubtitle = 'sub_title';
const String columnNoteCircleAvatarIndex = 'note_circle_avatar_index';
const String columnNoteDate = 'date';

const String eventsTable = 'events';
const String columnEventId = 'event_id';
const String columnCurrentNoteId = 'current_note_id';
const String columnText = 'text';
const String columnTime = 'time';
const String columnEventCircleAvatarIndex = 'event_circle_avatar_index';
const String columnEventBookmarkIndex = 'bookmark_index';
const String columnImagePath = 'image_path';
const String columnDate = 'date';

class DatabaseProvider {
  static DatabaseProvider _databaseProvider;
  static Database _database;

  DatabaseProvider._createInstance();

  Future<Database> get database async => _database ?? await initDB();

  factory DatabaseProvider() =>
      _databaseProvider ?? DatabaseProvider._createInstance();

  Future<Database> initDB() async {
    return openDatabase(
        join(await getDatabasesPath(), 'chat_journal_database.db'),
        version: 1, onCreate: (db, version) {
      db.execute('''
      create table $notesTable(
      $columnNoteId integer primary key autoincrement,
      $columnTitle text not null,
      $columnSubtitle text not null,
      $columnNoteCircleAvatarIndex integer,
      $columnNoteDate text not null
      ) 
      ''');
      db.execute('''
       create table $eventsTable(
      $columnEventId integer primary key autoincrement,
      $columnCurrentNoteId integer,
      $columnText text not null,
      $columnTime text not null,
      $columnEventCircleAvatarIndex integer,
      $columnEventBookmarkIndex integer,
      $columnImagePath text, 
      $columnDate text not null
      )
      ''');
    });
  }

  Future<int> insertNotes(Notes notes) async {
    final db = await database;
    return db.insert(
      notesTable,
      notes.convertNotesToMapWithId(),
    );
  }

  Future<int> deleteNotes(Notes notes) async {
    final db = await database;
    return db.delete(
      notesTable,
      where: '$columnNoteId = ?',
      whereArgs: [notes.notesId],
    );
  }

  Future<int> updateNote(Notes notes) async {
    final db = await database;
    return await db.update(
      notesTable,
      notes.convertNotesToMap(),
      where: '$columnNoteId = ?',
      whereArgs: [notes.notesId],
    );
  }

  Future<List<Notes>> fetchNotesList() async {
    final db = await database;
    final dbNotesList = await db.query(notesTable);
    final notesList = <Notes>[];
    for (var item in dbNotesList) {
      final note = Notes.fromMap(item);
      notesList.insert(0, note);
    }
    return notesList;
  }

  Future<int> insertEvents(EventPageMessages events) async {
    final db = await database;
    return db.insert(
      eventsTable,
      events.convertEventToMapWithId(),
    );
  }

  Future<int> deleteEvent(EventPageMessages events) async {
    final db = await database;
    return await db.delete(
      eventsTable,
      where: '$columnEventId = ?',
      whereArgs: [events.eventId],
    );
  }

  Future<int> deleteEventsFromNote(int noteId) async {
    final db = await database;
    return await db.delete(
      eventsTable,
      where: '$columnCurrentNoteId = ?',
      whereArgs: [noteId],
    );
  }

  Future<int> updateEvent(EventPageMessages events) async {
    final db = await database;
    return await db.update(
      eventsTable,
      events.convertEventToMap(),
      where: '$columnEventId = ?',
      whereArgs: [events.eventId],
    );
  }

  Future<List<EventPageMessages>> fetchEventsList(int noteId) async {
    final eventsList = <EventPageMessages>[];
    final db = await database;
    final dbEventsList = await db.rawQuery(
      'SELECT * FROM $eventsTable WHERE $columnCurrentNoteId = ?',
      [noteId],
    );
    for (var item in dbEventsList) {
      final events = EventPageMessages.fromMap(item);
      eventsList.insert(0, events);
    }
    return eventsList;
  }

  Future<List<EventPageMessages>> fetchFullEventsList() async {
    final db = await database;
    final eventList = <EventPageMessages>[];
    final dbNotesList = await db.query(eventsTable);
    for (var element in dbNotesList) {
      final events = EventPageMessages.fromMap(element);
      eventList.insert(0, events);
    }
    return eventList;
  }
}