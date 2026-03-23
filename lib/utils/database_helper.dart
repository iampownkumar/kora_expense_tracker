import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// A lighting-fast SQLite document store for Kora Expense Tracker.
/// This prevents out-of-memory crashes by saving items individually
/// instead of serializing a massive JSON array every time.
class DatabaseHelper {
  static const _databaseName = "kora_expense_tracker.db";
  static const _databaseVersion = 1;
  static const _tableName = "app_documents";

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static bool _isInitializing = false;
  static Future<Database>? _initFuture;

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Prevent multiple parallel initializations
    if (_isInitializing && _initFuture != null) {
      await _initFuture;
      return _database!;
    }
    
    _isInitializing = true;
    _initFuture = _initDatabase();
    _database = await _initFuture;
    _isInitializing = false;
    
    return _database!;
  }

  /// Explicit initialization explicitly called on startup
  Future<void> init() async {
    await database;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        collection TEXT NOT NULL,
        payload TEXT NOT NULL
      )
    ''');
    
    // Create an index for faster lookups by collection
    await db.execute('CREATE INDEX idx_collection ON $_tableName(collection)');
  }

  /// Inserts a new document (e.g. Transaction, Account)
  Future<bool> insertDocument(String collection, String id, Map<String, dynamic> data) async {
    try {
      final db = await database;
      await db.insert(
        _tableName,
        {
          'id': id,
          'collection': collection,
          'payload': jsonEncode(data),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      debugPrint('Database insert error: $e');
      return false;
    }
  }

  /// Updates an existing document
  Future<bool> updateDocument(String id, Map<String, dynamic> data) async {
    try {
      final db = await database;
      await db.update(
        _tableName,
        {'payload': jsonEncode(data)},
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      debugPrint('Database update error: $e');
      return false;
    }
  }

  /// Deletes a document
  Future<bool> deleteDocument(String id) async {
    try {
      final db = await database;
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      debugPrint('Database delete error: $e');
      return false;
    }
  }

  /// Gets all documents in a collection and returns them as parsed JSON Maps
  Future<List<Map<String, dynamic>>> getDocuments(String collection) async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableName,
        where: 'collection = ?',
        whereArgs: [collection],
      );
      
      return maps.map((row) {
        return jsonDecode(row['payload'] as String) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      debugPrint('Database query error: $e');
      return [];
    }
  }

  /// Returns true if the collection has any documents
  Future<bool> hasDocuments(String collection) async {
    try {
      final db = await database;
      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE collection = ?', [collection]
      ));
      return (count ?? 0) > 0;
    } catch (e) {
      return false;
    }
  }

  /// Clears an entire collection (e.g. removing all transactions)
  Future<bool> clearCollection(String collection) async {
    try {
      final db = await database;
      await db.delete(
        _tableName,
        where: 'collection = ?',
        whereArgs: [collection],
      );
      return true;
    } catch (e) {
      debugPrint('Database clear error: $e');
      return false;
    }
  }
}
