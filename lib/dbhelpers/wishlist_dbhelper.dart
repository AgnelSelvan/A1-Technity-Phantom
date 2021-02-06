import 'dart:core';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stock_q/models/wishlist.dart';

class WishlistDBHelper {
  static WishlistDBHelper _databaseHelper;
  static Database _database;

  String wishTable = 'wishlisttable';
  String colId = 'id';
  String colProductId = 'productId';

  WishlistDBHelper._createInstance();

  factory WishlistDBHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = WishlistDBHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'wishlist.db';
    var todosDb = await openDatabase(path, version: 13, onCreate: _createDb);
    return todosDb;
  }

  void _createDb(Database db, int newVersion) async {
    var sql =
        'CREATE TABLE $wishTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colProductId TEXT)';
    await db.execute(sql);
  }

  Future<List<Map<String, dynamic>>> getMapList() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT * FROM $wishTable');
    return result;
  }

  Future<int> insertWishlist(Wishlist wishlist) async {
    Database db = await this.database;
    var res = db.insert(wishTable, wishlist.toMap());
    return res;
  }

  Future<int> deleteWishlist(int id) async {
    Database db = await this.database;
    int res = await db.rawDelete('DELETE FROM $wishTable where $colId=$id');
    return res;
  }

  Future<int> updateWishlist(Wishlist wishlist) async {
    Database db = await this.database;
    var res = db.update(wishTable, wishlist.toMap(),
        where: '$colId = ?', whereArgs: [wishlist.id]);
    return res;
  }

  Future<List<Wishlist>> getWishlist() async {
    var wishlistMap = await getMapList();
    var count = wishlistMap.length;

    List<Wishlist> wishlists = List<Wishlist>();

    for (int i = 0; i < count; i++) {
      wishlists.add(Wishlist.fromMapObject(wishlistMap[i]));
    }
    return wishlists;
  }
}