import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'yamama_store_v1.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE master_products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL,
            category TEXT,
            image_url TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE local_cart(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER,
            name TEXT,
            price REAL,
            quantity INTEGER
          )
        ''');

        // Data sampel awal dengan foto URL
        await db.insert('master_products', {
          'name': 'Sepatu Sneakers Pro',
          'price': 350000.0,
          'category': 'Fashion',
          'image_url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400'
        });
        await db.insert('master_products', {
          'name': 'Headphone Wireless',
          'price': 275000.0,
          'category': 'Elektronik',
          'image_url': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400'
        });
        await db.insert('master_products', {
          'name': 'Smartwatch Sport',
          'price': 490000.0,
          'category': 'Elektronik',
          'image_url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400'
        });
        await db.insert('master_products', {
          'name': 'Tas Ransel Modern',
          'price': 180000.0,
          'category': 'Fashion',
          'image_url': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400'
        });
      },
    );
  }

  static Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('master_products', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  static Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert('master_products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('local_cart');
    return List.generate(maps.length, (i) => CartItem.fromMap(maps[i]));
  }

  static Future<void> insertCartItem(CartItem item) async {
    final db = await database;
    await db.insert('local_cart', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateCartQuantity(int id, int quantity) async {
    final db = await database;
    await db.update('local_cart', {'quantity': quantity}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteCartItem(int id) async {
    final db = await database;
    await db.delete('local_cart', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearCart() async {
    final db = await database;
    await db.delete('local_cart');
  }
}