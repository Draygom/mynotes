import 'package:flutter/foundation.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesService {
  Database? _db;

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDataOrThrow();

    await getNote(id: note.id);

    final updatesCount = await db.update(
      noteTable,
      {
        textColumn: text,
        isSyncWithCloudColumn: 0,
      },
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDataOrThrow();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDataOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotDeleteNote();
    } else {
      return DatabaseNote.fromRow(notes.first);
    }
  }

  Future<int> deleteAllnotes() async {
    final db = _getDataOrThrow();
    return await db.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDataOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDataOrThrow();

    //make sure owner existis in database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    //create note
    final notesId = await db.insert(
      noteTable,
      {
        userIdColumn: owner.id,
        textColumn: text,
        isSyncWithCloudColumn: 1,
      },
    );

    final note = DatabaseNote(
      id: notesId,
      userId: owner.id,
      text: text,
      isSyncWithCloud: true,
    );

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDataOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDataOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExistis();
    }

    final userId = await db.insert(
      userTable,
      {emailColumn: email.toLowerCase()},
    );

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDataOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDataOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);

      await db.execute(createNotesTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[inColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[inColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncWithCloud =
            (map[isSyncWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, isSyncWithCloud = $isSyncWithCloud, text = $text';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const inColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncWithCloudColumn = 'is_sync_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTIS "user" (
      "id"	INTEGER NOT NULL,
      "email"	TEXT NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';
const createNotesTable = '''CREATE TABLE IF NOT EXISTIS "note" (
      "id"	INTEGER NOT NULL,
      "user_id"	INTEGER NOT NULL,
      "text"	TEXT,
      "is_sync_with_cloud"	INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("id" AUTOINCREMENT),
      FOREIGN KEY("user_id") REFERENCES "user"("id")
      );
      ''';
