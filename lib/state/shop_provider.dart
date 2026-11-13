import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models.dart';
import '../util/ethiopian_calendar.dart' show todayInAddis;
import '../data/app_storage.dart';
import '../data/local_db.dart';

/// Holds all shop data in memory, backed by the local SQLite database.
/// Every save/delete re-reads the lists; at small-shop scale (hundreds of
/// records) this is instant and keeps the code simple and predictable.
class ShopProvider extends ChangeNotifier {
  ShopProvider(this._db);

  final LocalDb _db;

  List<Customer> customers = [];
  List<Measurement> measurements = [];
  List<ShopOrder> orders = [];
  List<Payment> payments = [];
  List<OrderItem> items = [];
  List<StaffMember> staff = [];
  List<FabricSample> fabricSamples = [];
  List<OrderDesignImage> designImages = [];
  String? activeStaffId;
  bool loaded = false;

  Future<void> loadAll() async {
    customers = (await _db.all('customers'))
        .map(Customer.fromRow)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    measurements =
        (await _db.all('measurements', orderBy: 'date_taken DESC, created_at DESC'))
            .map(Measurement.fromRow)
            .toList();

    // Sorted by registration time (newest first); the orders screen can
    // re-sort oldest-first through its filter toggle.
    orders = (await _db.all('orders')).map(ShopOrder.fromRow).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    payments = (await _db.all('payments', orderBy: 'paid_at DESC'))
        .map(Payment.fromRow)
        .toList();

    items = (await _db.all('order_items', orderBy: 'created_at ASC'))
        .map(OrderItem.fromRow)
        .toList();

    history = (await _db.all('order_status_history', orderBy: 'changed_at DESC'))
        .map(StatusHistoryEntry.fromRow)
        .toList();

    staff = (await _db.all('staff', orderBy: 'name ASC'))
        .map(StaffMember.fromRow)
        .toList();

    fabricSamples = (await _db.all('fabric_samples', orderBy: 'created_at DESC'))
        .map(FabricSample.fromRow)
        .toList();

    designImages =
        (await _db.all('order_design_images', orderBy: 'created_at DESC'))
            .map(OrderDesignImage.fromRow)
            .toList();

    final prefs = await SharedPreferences.getInstance();
    activeStaffId = prefs.getString('active_staff_id');
    if ((activeStaffId == null ||
            !staff.any((s) => s.id == activeStaffId)) &&
        staff.isNotEmpty) {
      activeStaffId = staff.first.id;
      await prefs.setString('active_staff_id', activeStaffId!);
    }

    loaded = true;
    notifyListeners();
  }

  // ----- staff -----

  StaffMember? get activeStaff {
    if (staff.isEmpty) return null;
    for (final s in staff) {
      if (s.id == activeStaffId) return s;
    }
    return staff.first;
  }

  Future<void> addStaff(String name, String phone) async {
    final member = StaffMember.create(name: name.trim(), phone: phone.trim());
    await _db.upsert('staff', member.toRow());
    if (staff.isEmpty) {
      activeStaffId = member.id;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_staff_id', member.id);
    }
    await loadAll();
  }

  Future<void> setActiveStaff(String id) async {
    activeStaffId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_staff_id', id);
  }

  Future<void> deleteStaff(StaffMember member) async {
    await _db.delete('staff', member.id);
    if (activeStaffId == member.id) {
      activeStaffId = null;
      await loadAll(); // loadAll reassigns the first staff member
    } else {
      await loadAll();
    }
  }

  // ----- fabric samples -----

  FabricSample? fabricSampleById(String id) {
    if (id.isEmpty) return null;
    for (final s in fabricSamples) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Saves a photographed fabric sample. The camera image is copied from
  /// the temp folder into the app documents folder so it survives.
  Future<FabricSample> saveFabricSample({
    required String name,
    required String tempPhotoPath,
    String fabricType = '',
    String color = '',
    String pattern = '',
  }) async {
    final fabricsDir = await AppStorage.fabricsDir();
    final ext = tempPhotoPath.toLowerCase().endsWith('.png') ? '.png' : '.jpg';
    final target = File(p.join(fabricsDir.path,
        '${const Uuid().v4()}$ext'));
    final source = File(tempPhotoPath);
    if (await source.exists()) {
      await source.copy(target.path);
    }

    final sample = FabricSample.create(
      name: name.trim(),
      photoPath: target.path,
      fabricType: fabricType.trim(),
      color: color.trim(),
      pattern: pattern.trim(),
    );
    await _db.upsert('fabric_samples', sample.toRow());
    await loadAll();
    return sample;
  }

  Future<void> deleteFabricSample(FabricSample sample) async {
    await _db.delete('fabric_samples', sample.id);
    final photo = File(sample.photoPath);
    if (await photo.exists()) {
      await photo.delete();
    }
    await loadAll();
  }

  // ----- design reference images -----

  List<OrderDesignImage> designImagesFor(String orderId) =>
      designImages.where((img) => img.orderId == orderId).toList();

  /// Copies a captured/uploaded image into the permanent designs folder
  /// and stores the record for the order.
  Future<OrderDesignImage> saveOrderImage({
    required String orderId,
    required String groupKey,
    required String tempPath,
    String viewType = 'front',
    String description = '',
  }) async {
    final dir = await AppStorage.designsDir();
    final ext = tempPath.toLowerCase().endsWith('.png') ? '.png' : '.jpg';
    final target = File(p.join(dir.path, '${const Uuid().v4()}$ext'));
    final source = File(tempPath);
    if (await source.exists()) {
      await source.copy(target.path);
    }
    final image = OrderDesignImage.create(
      orderId: orderId,
      groupKey: groupKey,
      viewType: viewType,
      path: target.path,
      description: description.trim(),
    );
    await _db.upsert('order_design_images', image.toRow());
    await loadAll();
    return image;
  }

  Future<void> deleteOrderImage(OrderDesignImage image) async {
    await _db.delete('order_design_images', image.id);
    final file = File(image.path);
    if (await file.exists()) {
      await file.delete();
    }
    await loadAll();
  }

  // ----- customers -----

  Future<void> saveCustomer(Customer customer) async {
    await _db.upsert('customers', customer.toRow());
    await loadAll();
  }

  Future<void> deleteCustomer(Customer customer) async {
    await _db.deleteCustomerCascade(customer.id);
    await loadAll();
  }

  Customer? customerById(String id) {
    for (final c in customers) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Finds an existing customer by exact (digits-only) phone number.
  Customer? customerByPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    for (final c in customers) {
      if (c.phone.replaceAll(RegExp(r'\D'), '') == digits) return c;
    }
    return null;
  }

  // ----- measurements -----

  Future<void> saveMeasurement(Measurement measurement) async {
    await _db.upsert('measurements', measurement.toRow());
    await loadAll();
  }

  Future<void> deleteMeasurement(Measurement measurement) async {
    await _db.delete('measurements', measurement.id);
    await loadAll();
  }

  List<Measurement> measurementsFor(String customerId) =>
      measurements.where((m) => m.customerId == customerId).toList();

  /// Newest saved measurement of a given category (for "reuse" prefill).
  Measurement? latestMeasurement(String customerId, String category) {
    for (final m in measurements) {
      if (m.customerId == customerId && m.category == category) return m;
    }
    return null;
  }

  // ----- orders -----

  /// Human readable, unique order number: ZF-000001, ZF-000002, ...
  Future<String> nextOrderNumber() async {
    final rows = await _db.all('orders', orderBy: 'order_no DESC');
    int max = 0;
    for (final row in rows) {
      final no = (row['order_no'] as String?) ?? '';
      final match = RegExp(r'ZF-(\d+)').firstMatch(no);
      if (match != null) {
        final value = int.tryParse(match.group(1)!);
        if (value != null && value > max) max = value;
      }
    }
    return 'ZF-${(max + 1).toString().padLeft(6, '0')}';
  }

  /// Creates the customer (or updates the matching returning one), the
  /// order, its garment items with measurement snapshots, the initial
  /// status history entry and the optional deposit payment.
  Future<ShopOrder> saveNewOrder({
    required Customer customer,
    required ShopOrder order,
    required List<OrderItem> items,
    double? deposit,
    String? depositNote,
  }) async {
    var savedCustomer = customerByPhone(customer.phone);
    if (savedCustomer == null) {
      await _db.upsert('customers', customer.toRow());
      savedCustomer = customer;
    } else {
      // Returning customer: refresh the profile fields from the form.
      savedCustomer
        ..name = customer.name
        ..phone = customer.phone
        ..gender = customer.gender
        ..altPhone = customer.altPhone
        ..address = customer.address
        ..region = customer.region
        ..city = customer.city
        ..subCity = customer.subCity
        ..kebele = customer.kebele
        ..customerType =
            customer.customerType.isEmpty ? 'returning' : customer.customerType
        ..registeredBy = customer.registeredBy;
      if (customer.notes.isNotEmpty) {
        savedCustomer.notes = customer.notes;
      }
      await _db.upsert('customers', savedCustomer.toRow());
    }

    final saved = ShopOrder.create(
      customerId: savedCustomer.id,
      style: order.style,
      totalPrice: order.totalPrice,
      fabric: order.fabric,
      deliveryDate: order.deliveryDate,
      notes: order.notes,
      orderNo: order.orderNo,
      category: order.category,
      assignedTo: order.assignedTo,
    );
    saved.status = OrderStatus.newOrder;
    await _db.upsert('orders', saved.toRow());
    await _db.upsert(
      'order_status_history',
      StatusHistoryEntry.create(orderId: saved.id, status: OrderStatus.newOrder)
          .toRow(),
    );
    for (final item in items) {
      final withOrder = OrderItem.create(
        orderId: saved.id,
        garmentKey: item.garmentKey,
        quantity: item.quantity,
        measurement: item.measurement,
        style: item.style,
        measurementId: item.measurementId,
        notes: item.notes,
      );
      await _db.upsert('order_items', withOrder.toRow());

      // Persist the measurements so they can be reused for this customer.
      if (item.measurement.isNotEmpty) {
        await _db.upsert(
          'measurements',
          Measurement.create(
            customerId: savedCustomer.id,
            category: item.garmentKey,
            fields: item.measurement,
          ).toRow(),
        );
      }
    }
    if (deposit != null && deposit > 0) {
      await _db.upsert(
        'payments',
        Payment.create(
          orderId: saved.id,
          amount: deposit,
          note: depositNote ?? '',
        ).toRow(),
      );
    }
    await loadAll();
    return saved;
  }

  Future<void> saveOrder(ShopOrder order) async {
    await _db.upsert('orders', order.toRow());
    await loadAll();
  }

  /// Status change with a history record (the tracking requirement).
  Future<void> changeOrderStatus(ShopOrder order, OrderStatus status) async {
    order.status = status;
    await _db.upsert('orders', order.toRow());
    await _db.upsert(
      'order_status_history',
      StatusHistoryEntry.create(orderId: order.id, status: status).toRow(),
    );
    await loadAll();
  }

  Future<void> deleteOrder(ShopOrder order) async {
    await _db.deleteOrderCascade(order.id);
    await loadAll();
  }

  ShopOrder? orderById(String id) {
    for (final o in orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  List<ShopOrder> ordersFor(String customerId) =>
      orders.where((o) => o.customerId == customerId).toList();

  List<OrderItem> itemsFor(String orderId) =>
      items.where((i) => i.orderId == orderId).toList();

  List<StatusHistoryEntry> historyFor(String orderId) {
    final list = history
        .where((h) => h.orderId == orderId)
        .toList()
      ..sort((a, b) => b.changedAt.compareTo(a.changedAt));
    return list;
  }

  List<StatusHistoryEntry> history = [];

  int get openOrderCount =>
      orders.where((o) => orderIsOpen(o.status)).length;

  // ----- measurements persisted with items -----

  Future<void> saveItem(OrderItem item) async {
    item.updatedAt = DateTime.now();
    await _db.upsert('order_items', item.toRow());
    await loadAll();
  }

  // ----- payments -----

  Future<void> savePayment(Payment payment) async {
    await _db.upsert('payments', payment.toRow());
    await loadAll();
  }

  Future<void> deletePayment(Payment payment) async {
    await _db.delete('payments', payment.id);
    await loadAll();
  }

  List<Payment> paymentsFor(String orderId) =>
      payments.where((pay) => pay.orderId == orderId).toList();

  double paidFor(String orderId) =>
      paymentsFor(orderId).fold(0.0, (sum, pay) => sum + pay.amount);

  double balanceFor(ShopOrder order) => order.totalPrice - paidFor(order.id);

  /// Total money customers still owe across all open orders.
  double get totalOwed => orders.fold(0.0, (sum, o) {
        if (o.status == OrderStatus.cancelled) return sum;
        final balance = balanceFor(o);
        return sum + (balance > 0 ? balance : 0);
      });

  // ----- backup -----

  /// Writes every table to a JSON file in the app documents folder and
  /// returns the full path. Data never leaves the phone.
  Future<String> exportBackup() async {
    final db = await _db.database;
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'customers': await db.query('customers'),
      'measurements': await db.query('measurements'),
      'orders': await db.query('orders'),
      'order_items': await db.query('order_items'),
      'staff': await db.query('staff'),
      'order_status_history': await db.query('order_status_history'),
      'payments': await db.query('payments'),
    };
    final dir = await AppStorage.base();
    final file = File(p.join(
      dir.path,
      'zizi_backup_${dayKey(todayInAddis())}.json',
    ));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file.path;
  }

  /// Writes any prepared CSV text to a dated file and returns the path.
  Future<String> writeCsv(String name, String csv) async {
    final dir = await AppStorage.base();
    final file = File(p.join(dir.path, '${name}_${dayKey(todayInAddis())}.csv'));
    // BOM so Excel opens UTF-8 (Amharic) correctly.
    await file.writeAsBytes(const Utf8Encoder().convert('\uFEFF$csv'));
    return file.path;
  }
}
