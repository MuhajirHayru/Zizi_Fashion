import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'app_storage.dart';

/// Offline-first storage: everything lives in a SQLite file on the phone,
/// in the permanent public ZIZI_FASHION folder when storage access is
/// granted. v2 adds the ZIZI FASHION schema: extended customer profiles,
/// garment categories + JSON measurement snapshots, order items, staff and
/// status history. v3 adds the fabric sample catalog (camera photos) and
/// the order -> sample link. Existing data is migrated in place, never
/// deleted.
class LocalDb {
  LocalDb._();
  static final LocalDb instance = LocalDb._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await AppStorage.databasePath();
    await _migrateLegacyDatabase(dbPath);
    _database = await openDatabase(
      dbPath,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  /// On the first run with permanent storage, copies the previous
  /// app-private database file to the new location so no existing data
  /// (customers, orders, measurements, payments) is lost.
  Future<void> _migrateLegacyDatabase(String newPath) async {
    if (await File(newPath).exists()) return;
    try {
      final legacyPath = p.join(await getDatabasesPath(), 'tailor_shop.db');
      final legacy = File(legacyPath);
      if (await legacy.exists()) {
        await legacy.copy(newPath);
      }
    } catch (_) {
      // Copy failed — openDatabase will create a fresh file instead.
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        gender TEXT NOT NULL DEFAULT '',
        alt_phone TEXT NOT NULL DEFAULT '',
        address TEXT NOT NULL DEFAULT '',
        region TEXT NOT NULL DEFAULT '',
        city TEXT NOT NULL DEFAULT '',
        sub_city TEXT NOT NULL DEFAULT '',
        kebele TEXT NOT NULL DEFAULT '',
        customer_type TEXT NOT NULL DEFAULT '',
        registered_by TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE measurements(
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        date_taken TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'general',
        fields_json TEXT NOT NULL DEFAULT '{}',
        neck REAL, chest REAL, waist REAL, hip REAL,
        shoulder REAL, sleeve REAL, bicep REAL, wrist REAL,
        thigh REAL, knee REAL, trouser_length REAL, bottom_width REAL,
        notes TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE orders(
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        style TEXT NOT NULL,
        fabric TEXT NOT NULL DEFAULT '',
        total_price REAL NOT NULL,
        delivery_date TEXT,
        status TEXT NOT NULL DEFAULT 'new_order',
        notes TEXT NOT NULL DEFAULT '',
        order_no TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL DEFAULT 'general',
        assigned_to TEXT NOT NULL DEFAULT '',
        fabric_sample_id TEXT NOT NULL DEFAULT '',
        fabric_color TEXT NOT NULL DEFAULT '',
        fabric_pattern TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE fabric_samples(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        fabric_type TEXT NOT NULL DEFAULT '',
        color TEXT NOT NULL DEFAULT '',
        pattern TEXT NOT NULL DEFAULT '',
        photo_path TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE order_design_images(
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        group_key TEXT NOT NULL,
        path TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE order_items(
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        garment_key TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        measurement_json TEXT NOT NULL DEFAULT '{}',
        style_json TEXT NOT NULL DEFAULT '{}',
        measurement_id TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        updated_at TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE staff(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE order_status_history(
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        status TEXT NOT NULL,
        changed_at TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE payments(
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        amount REAL NOT NULL,
        paid_at TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');
    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_measurements_customer ON measurements(customer_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_items_order ON order_items(order_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_history_order ON order_status_history(order_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          "ALTER TABLE customers ADD COLUMN gender TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE customers ADD COLUMN alt_phone TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE customers ADD COLUMN address TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE customers ADD COLUMN region TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE customers ADD COLUMN city TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE customers ADD COLUMN sub_city TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE customers ADD COLUMN kebele TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE customers ADD COLUMN customer_type TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE customers ADD COLUMN registered_by TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE measurements ADD COLUMN category TEXT NOT NULL DEFAULT 'general'");
      await db.execute(
          "ALTER TABLE measurements ADD COLUMN fields_json TEXT NOT NULL DEFAULT '{}'");
      await db.execute(
          "ALTER TABLE orders ADD COLUMN order_no TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE orders ADD COLUMN category TEXT NOT NULL DEFAULT 'general'");
      await db.execute(
          "ALTER TABLE orders ADD COLUMN assigned_to TEXT NOT NULL DEFAULT ''");
      await db.execute('''
        CREATE TABLE IF NOT EXISTS order_items(
          id TEXT PRIMARY KEY,
          order_id TEXT NOT NULL,
          garment_key TEXT NOT NULL,
          quantity INTEGER NOT NULL DEFAULT 1,
          measurement_json TEXT NOT NULL DEFAULT '{}',
          style_json TEXT NOT NULL DEFAULT '{}',
          measurement_id TEXT NOT NULL DEFAULT '',
          notes TEXT NOT NULL DEFAULT '',
          updated_at TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS staff(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          phone TEXT NOT NULL DEFAULT '',
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS order_status_history(
          id TEXT PRIMARY KEY,
          order_id TEXT NOT NULL,
          status TEXT NOT NULL,
          changed_at TEXT NOT NULL,
          note TEXT NOT NULL DEFAULT ''
        )
      ''');
      await _createIndexes(db);
      // Map legacy v1 statuses onto the new pipeline.
      await db.execute('''
        UPDATE orders SET status = CASE status
          WHEN 'pending' THEN 'new_order'
          WHEN 'fitting' THEN 'ready_for_fitting'
          WHEN 'sewing' THEN 'sewing_in_progress'
          WHEN 'finished' THEN 'completed'
          WHEN 'collected' THEN 'delivered'
          ELSE status END
      ''');
      await db.execute(
          "UPDATE orders SET order_no = 'ZF-' || printf('%06d', rowid) WHERE order_no = ''");
      await db.execute(
          "INSERT INTO staff(id, name, phone, created_at) "
          "SELECT lower(hex(randomblob(16))), 'Staff', '', datetime('now') "
          "WHERE NOT EXISTS (SELECT 1 FROM staff)");
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS fabric_samples(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          fabric_type TEXT NOT NULL DEFAULT '',
          color TEXT NOT NULL DEFAULT '',
          pattern TEXT NOT NULL DEFAULT '',
          photo_path TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute(
          "ALTER TABLE orders ADD COLUMN fabric_sample_id TEXT NOT NULL DEFAULT ''");
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS order_design_images(
          id TEXT PRIMARY KEY,
          order_id TEXT NOT NULL,
          group_key TEXT NOT NULL,
          path TEXT NOT NULL,
          description TEXT NOT NULL DEFAULT '',
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute(
          "ALTER TABLE orders ADD COLUMN fabric_color TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE orders ADD COLUMN fabric_pattern TEXT NOT NULL DEFAULT ''");
    }
  }

  Future<void> upsert(String table, Map<String, Object?> row) async {
    final db = await database;
    await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, Object?>>> all(String table,
      {String? orderBy, String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    return db.query(table,
        orderBy: orderBy, where: where, whereArgs: whereArgs);
  }

  Future<int> count(String table) async {
    final db = await database;
    final rows =
        await db.query(table, columns: ['COUNT(*) AS c']);
    return (rows.first['c'] as int?) ?? 0;
  }

  /// Deletes a customer plus every measurement, order, item, payment and
  /// history entry that belongs to them, in one transaction.
  Future<void> deleteCustomerCascade(String customerId) async {
    final db = await database;
    await db.transaction((txn) async {
      final orderIds = (await txn.query('orders',
              columns: ['id'], where: 'customer_id = ?', whereArgs: [customerId]))
          .map((r) => r['id'] as String)
          .toList();
      if (orderIds.isNotEmpty) {
        final marks = List.filled(orderIds.length, '?').join(',');
        final args = orderIds.toList();
        await txn.delete('payments',
            where: 'order_id IN ($marks)', whereArgs: args);
        await txn.delete('order_items',
            where: 'order_id IN ($marks)', whereArgs: args);
        await txn.delete('order_status_history',
            where: 'order_id IN ($marks)', whereArgs: args);
      }
      await txn.delete('measurements',
          where: 'customer_id = ?', whereArgs: [customerId]);
      await txn.delete('orders',
          where: 'customer_id = ?', whereArgs: [customerId]);
      await txn.delete('customers', where: 'id = ?', whereArgs: [customerId]);
    });
  }

  Future<void> deleteOrderCascade(String orderId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('payments', where: 'order_id = ?', whereArgs: [orderId]);
      await txn.delete('order_items',
          where: 'order_id = ?', whereArgs: [orderId]);
      await txn.delete('order_status_history',
          where: 'order_id = ?', whereArgs: [orderId]);
      await txn.delete('orders', where: 'id = ?', whereArgs: [orderId]);
    });
  }

  Future<void> delete(String table, String id) async {
    final db = await database;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
