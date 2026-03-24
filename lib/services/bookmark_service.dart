import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseAlreadyOpenException implements Exception {}

class BookmarkService {
  List<BookmarkDatabase> _bookmarks = [];
  Database? _db;
  static final BookmarkService _shared = BookmarkService._sharedInstance();
  BookmarkService._sharedInstance() {
    _bookmarkController = StreamController<List<BookmarkDatabase>>.broadcast(
      onListen: () {
        _bookmarkController.sink.add(_bookmarks);
      },
    );
  }
  factory BookmarkService() => _shared;
  late final StreamController<List<BookmarkDatabase>> _bookmarkController;
  Stream<List<BookmarkDatabase>> get allBookmark => _bookmarkController.stream;

  Future<void> _ensureDbIsOpen() async {
    try {
      await openDb();
    } on DatabaseAlreadyOpenException {
      //
    }
  }

  Future<void> deleteAllBookmark() async {
    //await _ensureDbIsOpen();
    final db = _checkDbExistance();
    await db.rawDelete('DELETE FROM bookmark');
    _bookmarks = [];
    _bookmarkController.add([]);
    await db.query(tableName);
  }

  Future<void> deleteBookmark(int id) async {
    await _ensureDbIsOpen();
    final db = _checkDbExistance();
    final deletedNumber = await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedNumber > 0) {
      _bookmarks.removeWhere((curr) => curr.id == id);
      _bookmarkController.add(_bookmarks);
    }
  }

  Future<void> updateBookmark(
    int id,
    String title,
    String titleAlternative,
    String webUrl,
    double episode,
    Uint8List image,
  ) async {
    await _ensureDbIsOpen();

    final db = _checkDbExistance();
    final updateCount = await db.update(
      tableName,
      {
        titleColumn: title,
        titleAlternativeColumn: titleAlternative,
        webUrlColumn: webUrl,
        episodeColumn: episode,
        imageColumn: image,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    final updatedBookmark = await getBookmark(id);
    _bookmarks.removeWhere((curr) => curr.id == id);
    _bookmarks.add(updatedBookmark);
    _bookmarkController.add(_bookmarks);
  }

  Future<BookmarkDatabase> getBookmark(int id) async {
    await _ensureDbIsOpen();
    final db = _checkDbExistance();
    final bookmark = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (bookmark.isNotEmpty) {
      final newBookmark = BookmarkDatabase.fromMap(bookmark.first);
      _bookmarks.removeWhere((curr) => curr.id == id);
      _bookmarks.add(newBookmark);
      _bookmarkController.add(_bookmarks);
      return newBookmark;
    } else {
      throw Exception('not found');
    }
  }

  Future<BookmarkDatabase> createBookmark(
    String title,
    String titleAlternative,
    String webUrl,
    double episode,
    Uint8List image,
  ) async {
    await _ensureDbIsOpen();
    final db = _checkDbExistance();

    try {
      final Map<String, Object?> mapToInsert = {
        titleColumn: title,
        titleAlternativeColumn: titleAlternative,
        webUrlColumn: webUrl,
        episodeColumn: episode,
        imageColumn: image,
      };
      final bookmarkId = await db.insert(tableName, mapToInsert);
      final bookmark = BookmarkDatabase(
        id: bookmarkId,
        title: title,
        titleAlternative: titleAlternative,
        webUrl: webUrl,
        episode: episode,
        image: image,
      );
      _bookmarks.add(bookmark);
      _bookmarkController.add(_bookmarks);
      return bookmark;
    } catch (e) {
      throw Exception(e);
    }
  }

  Database _checkDbExistance() {
    final db = _db;
    if (db != null) {
      return db;
    } else {
      throw Exception('db not yet open');
    }
  }

  Future<void> _cacheData() async {
    List<BookmarkDatabase> bookmark = await getAllBookmark();
    _bookmarks = bookmark;
    _bookmarkController.add(_bookmarks);
  }

  Future<List<BookmarkDatabase>> getAllBookmark() async {
    final db = _checkDbExistance();
    final bookmarks = await db.query(tableName);
    return bookmarks.map((curr) => BookmarkDatabase.fromMap(curr)).toList();
  }

  Future<String> initialize() async {
    await openDb();
    return 'ok';
  }

  Future<void> closeDb() async {
    final db = _checkDbExistance();
    db.close();
    _db = null;
  }

  Future<void> openDbAfterImport() async {
    await closeDb();
    _bookmarks = [];
    _bookmarkController.add(_bookmarks);
    await openDb();
  }

  Future<void> openDb() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    } else {
      final documentLocation = await getApplicationDocumentsDirectory();
      final dbPath = join(documentLocation.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createDbQuery);
      await _cacheData();
    }
  }
}

class BookmarkDatabase {
  final int id;
  final String title;
  final String titleAlternative;
  final String webUrl;
  final double episode;
  final Uint8List image;

  BookmarkDatabase({
    required this.id,
    required this.title,
    required this.titleAlternative,
    required this.webUrl,
    required this.episode,
    required this.image,
  });

  BookmarkDatabase.fromMap(Map<String, Object?> map)
    : id = map[idColumn] as int,
      title = map[titleColumn] as String,
      titleAlternative = map[titleAlternativeColumn] as String,
      webUrl = map[webUrlColumn] as String,
      episode = map[episodeColumn] is int
          ? (map[episodeColumn] as int).toDouble()
          : map[episodeColumn] as double,
      image = map[imageColumn] as Uint8List;
}

const dbName = 'bookmark.db';
const idColumn = 'id';
const titleColumn = 'title';
const tableName = 'bookmark';
const titleAlternativeColumn = 'title_alternative';
const webUrlColumn = 'web_url';
const episodeColumn = 'episode';
const imageColumn = 'image';
const createDbQuery = """
  CREATE TABLE IF NOT EXISTS "bookmark" (
	"id"	INTEGER NOT NULL,
	"title"	TEXT,
	"title_alternative"	TEXT,
	"web_url"	TEXT,
	"episode"	INTEGER,
	"image"	BLOB,
	PRIMARY KEY("id" AUTOINCREMENT)
);""";
