import 'dart:convert';

import 'package:uuid/uuid.dart';

/// Format used for all date-only values stored in the database (yyyy-MM-dd).
/// Stored dates are always Gregorian ISO strings; the Ethiopian calendar is
/// applied only when displaying (see util/ethiopian_calendar.dart).
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime? _parseDay(String? v) => (v == null || v.isEmpty) ? null : DateTime.tryParse(v);

DateTime _parse(String v) => DateTime.tryParse(v) ?? DateTime.now();

double? _num(Object? v) => v == null ? null : (v as num).toDouble();

Map<String, String> _jsonMap(Object? raw) {
  if (raw == null || (raw as String).isEmpty) return {};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
    }
  } catch (_) {}
  return {};
}

class Customer {
  final String id;
  final DateTime createdAt;
  String name;
  String phone;
  String notes;

  // ZIZI FASHION extended profile fields.
  String gender; // male / female
  String altPhone;
  String address;
  String region;
  String city;
  String subCity;
  String kebele;
  String customerType; // new / returning
  String registeredBy; // staff name snapshot

  Customer({
    required this.id,
    required this.createdAt,
    this.name = '',
    this.phone = '',
    this.notes = '',
    this.gender = '',
    this.altPhone = '',
    this.address = '',
    this.region = '',
    this.city = '',
    this.subCity = '',
    this.kebele = '',
    this.customerType = '',
    this.registeredBy = '',
  });

  factory Customer.create({
    required String name,
    String phone = '',
    String notes = '',
    String gender = '',
    String altPhone = '',
    String address = '',
    String region = '',
    String city = '',
    String subCity = '',
    String kebele = '',
    String customerType = '',
    String registeredBy = '',
  }) =>
      Customer(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        name: name,
        phone: phone,
        notes: notes,
        gender: gender,
        altPhone: altPhone,
        address: address,
        region: region,
        city: city,
        subCity: subCity,
        kebele: kebele,
        customerType: customerType,
        registeredBy: registeredBy,
      );

  Map<String, Object?> toRow() => {
        'id': id,
        'name': name,
        'phone': phone,
        'notes': notes,
        'gender': gender,
        'alt_phone': altPhone,
        'address': address,
        'region': region,
        'city': city,
        'sub_city': subCity,
        'kebele': kebele,
        'customer_type': customerType,
        'registered_by': registeredBy,
        'created_at': createdAt.toIso8601String(),
      };

  static Customer fromRow(Map<String, Object?> r) => Customer(
        id: r['id'] as String,
        createdAt: _parse(r['created_at'] as String),
        name: (r['name'] as String?) ?? '',
        phone: (r['phone'] as String?) ?? '',
        notes: (r['notes'] as String?) ?? '',
        gender: (r['gender'] as String?) ?? '',
        altPhone: (r['alt_phone'] as String?) ?? '',
        address: (r['address'] as String?) ?? '',
        region: (r['region'] as String?) ?? '',
        city: (r['city'] as String?) ?? '',
        subCity: (r['sub_city'] as String?) ?? '',
        kebele: (r['kebele'] as String?) ?? '',
        customerType: (r['customer_type'] as String?) ?? '',
        registeredBy: (r['registered_by'] as String?) ?? '',
      );
}

class Measurement {
  final String id;
  final String customerId;
  final DateTime createdAt;
  DateTime dateTaken;
  String notes;

  /// Measurement category: 'general' (legacy fields below) or a garment
  /// key from garment_definitions.dart (values live in [fields]).
  String category;

  /// Dynamic field values (garment-specific measurements + styles).
  Map<String, String> fields = {};

  // Legacy 'general' numeric columns (kept for existing data).
  double? neck;
  double? chest;
  double? waist;
  double? hip;
  double? shoulder;
  double? sleeve;
  double? bicep;
  double? wrist;
  double? thigh;
  double? knee;
  double? trouserLength;
  double? bottomWidth;

  Measurement({
    required this.id,
    required this.customerId,
    required this.createdAt,
    required this.dateTaken,
    this.notes = '',
    this.category = 'general',
    Map<String, String>? fields,
    this.neck,
    this.chest,
    this.waist,
    this.hip,
    this.shoulder,
    this.sleeve,
    this.bicep,
    this.wrist,
    this.thigh,
    this.knee,
    this.trouserLength,
    this.bottomWidth,
  }) {
    this.fields = fields ?? {};
  }

  factory Measurement.create({
    required String customerId,
    DateTime? dateTaken,
    String notes = '',
    String category = 'general',
    Map<String, String>? fields,
  }) =>
      Measurement(
        id: const Uuid().v4(),
        customerId: customerId,
        createdAt: DateTime.now(),
        dateTaken: dateTaken ?? DateTime.now(),
        notes: notes,
        category: category,
        fields: fields,
      );

  /// Keys match [measurementFields] in widgets/measurement_labels.dart.
  double? getField(String key) => switch (key) {
        'neck' => neck,
        'chest' => chest,
        'waist' => waist,
        'hip' => hip,
        'shoulder' => shoulder,
        'sleeve' => sleeve,
        'bicep' => bicep,
        'wrist' => wrist,
        'thigh' => thigh,
        'knee' => knee,
        'trouserLength' => trouserLength,
        'bottomWidth' => bottomWidth,
        _ => null,
      };

  void setField(String key, double? value) {
    switch (key) {
      case 'neck':
        neck = value;
      case 'chest':
        chest = value;
      case 'waist':
        waist = value;
      case 'hip':
        hip = value;
      case 'shoulder':
        shoulder = value;
      case 'sleeve':
        sleeve = value;
      case 'bicep':
        bicep = value;
      case 'wrist':
        wrist = value;
      case 'thigh':
        thigh = value;
      case 'knee':
        knee = value;
      case 'trouserLength':
        trouserLength = value;
      case 'bottomWidth':
        bottomWidth = value;
    }
  }

  Map<String, Object?> toRow() => {
        'id': id,
        'customer_id': customerId,
        'date_taken': dayKey(dateTaken),
        'category': category,
        'fields_json': jsonEncode(fields),
        'neck': neck,
        'chest': chest,
        'waist': waist,
        'hip': hip,
        'shoulder': shoulder,
        'sleeve': sleeve,
        'bicep': bicep,
        'wrist': wrist,
        'thigh': thigh,
        'knee': knee,
        'trouser_length': trouserLength,
        'bottom_width': bottomWidth,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  static Measurement fromRow(Map<String, Object?> r) => Measurement(
        id: r['id'] as String,
        customerId: r['customer_id'] as String,
        createdAt: _parse(r['created_at'] as String),
        dateTaken: _parseDay(r['date_taken'] as String?) ?? DateTime.now(),
        notes: (r['notes'] as String?) ?? '',
        category: (r['category'] as String?) ?? 'general',
        fields: _jsonMap(r['fields_json']),
        neck: _num(r['neck']),
        chest: _num(r['chest']),
        waist: _num(r['waist']),
        hip: _num(r['hip']),
        shoulder: _num(r['shoulder']),
        sleeve: _num(r['sleeve']),
        bicep: _num(r['bicep']),
        wrist: _num(r['wrist']),
        thigh: _num(r['thigh']),
        knee: _num(r['knee']),
        trouserLength: _num(r['trouser_length']),
        bottomWidth: _num(r['bottom_width']),
      );
}

/// Full order pipeline. Legacy names ('pending', 'fitting', ...) are mapped
/// so existing database rows keep working.
enum OrderStatus {
  newOrder,
  measurementCompleted,
  fabricPreparation,
  inProduction,
  sewingInProgress,
  readyForFitting,
  modificationRequired,
  completed,
  delivered,
  cancelled,
}

OrderStatus orderStatusFromName(String? name) {
  switch (name) {
    case 'new_order':
      return OrderStatus.newOrder;
    case 'measurement_completed':
      return OrderStatus.measurementCompleted;
    case 'fabric_preparation':
      return OrderStatus.fabricPreparation;
    case 'in_production':
      return OrderStatus.inProduction;
    case 'sewing_in_progress':
      return OrderStatus.sewingInProgress;
    case 'ready_for_fitting':
      return OrderStatus.readyForFitting;
    case 'modification_required':
      return OrderStatus.modificationRequired;
    case 'completed':
      return OrderStatus.completed;
    case 'delivered':
      return OrderStatus.delivered;
    case 'cancelled':
      return OrderStatus.cancelled;
    // Legacy values from app v1.
    case 'pending':
      return OrderStatus.newOrder;
    case 'fitting':
      return OrderStatus.readyForFitting;
    case 'sewing':
      return OrderStatus.sewingInProgress;
    case 'finished':
      return OrderStatus.completed;
    case 'collected':
      return OrderStatus.delivered;
    default:
      return OrderStatus.newOrder;
  }
}

/// The status stored in the database (canonical string).
String orderStatusName(OrderStatus s) => switch (s) {
      OrderStatus.newOrder => 'new_order',
      OrderStatus.measurementCompleted => 'measurement_completed',
      OrderStatus.fabricPreparation => 'fabric_preparation',
      OrderStatus.inProduction => 'in_production',
      OrderStatus.sewingInProgress => 'sewing_in_progress',
      OrderStatus.readyForFitting => 'ready_for_fitting',
      OrderStatus.modificationRequired => 'modification_required',
      OrderStatus.completed => 'completed',
      OrderStatus.delivered => 'delivered',
      OrderStatus.cancelled => 'cancelled',
    };

/// One-step forward along the main production path.
/// 'Modification required' and 'Cancelled' are set explicitly, not advanced.
OrderStatus? nextOrderStatus(OrderStatus status) => switch (status) {
      OrderStatus.newOrder => OrderStatus.measurementCompleted,
      OrderStatus.measurementCompleted => OrderStatus.fabricPreparation,
      OrderStatus.fabricPreparation => OrderStatus.inProduction,
      OrderStatus.inProduction => OrderStatus.sewingInProgress,
      OrderStatus.sewingInProgress => OrderStatus.readyForFitting,
      OrderStatus.readyForFitting => OrderStatus.completed,
      OrderStatus.completed => OrderStatus.delivered,
      _ => null,
    };

bool orderIsOpen(OrderStatus status) =>
    status != OrderStatus.delivered && status != OrderStatus.cancelled;

class ShopOrder {
  final String id;
  final String customerId;
  final DateTime createdAt;
  String style; // legacy short label ('suit', ...)
  String fabric;
  double totalPrice;
  DateTime? deliveryDate;
  OrderStatus status;
  String notes;

  // ZIZI FASHION order fields.
  String orderNo; // human readable id, e.g. ZF-000012
  String category; // 'general' (legacy) or 'graduation_men'
  String assignedTo; // staff name snapshot
  String fabricSampleId; // fabric sample (photo) chosen for this order

  ShopOrder({
    required this.id,
    required this.customerId,
    required this.createdAt,
    required this.style,
    required this.totalPrice,
    this.fabric = '',
    this.deliveryDate,
    this.status = OrderStatus.newOrder,
    this.notes = '',
    this.orderNo = '',
    this.category = 'general',
    this.assignedTo = '',
    this.fabricSampleId = '',
  });

  factory ShopOrder.create({
    required String customerId,
    required String style,
    required double totalPrice,
    String fabric = '',
    DateTime? deliveryDate,
    String notes = '',
    String orderNo = '',
    String category = 'general',
    String assignedTo = '',
    String fabricSampleId = '',
  }) =>
      ShopOrder(
        id: const Uuid().v4(),
        customerId: customerId,
        createdAt: DateTime.now(),
        style: style,
        totalPrice: totalPrice,
        fabric: fabric,
        deliveryDate: deliveryDate,
        notes: notes,
        orderNo: orderNo,
        category: category,
        assignedTo: assignedTo,
        fabricSampleId: fabricSampleId,
      );

  Map<String, Object?> toRow() => {
        'id': id,
        'customer_id': customerId,
        'style': style,
        'fabric': fabric,
        'total_price': totalPrice,
        'delivery_date': deliveryDate == null ? null : dayKey(deliveryDate!),
        'status': orderStatusName(status),
        'notes': notes,
        'order_no': orderNo,
        'category': category,
        'assigned_to': assignedTo,
        'fabric_sample_id': fabricSampleId,
        'created_at': createdAt.toIso8601String(),
      };

  static ShopOrder fromRow(Map<String, Object?> r) => ShopOrder(
        id: r['id'] as String,
        customerId: r['customer_id'] as String,
        createdAt: _parse(r['created_at'] as String),
        style: (r['style'] as String?) ?? '',
        fabric: (r['fabric'] as String?) ?? '',
        totalPrice: _num(r['total_price']) ?? 0,
        deliveryDate: _parseDay(r['delivery_date'] as String?),
        status: orderStatusFromName(r['status'] as String?),
        notes: (r['notes'] as String?) ?? '',
        orderNo: (r['order_no'] as String?) ?? '',
        category: (r['category'] as String?) ?? 'general',
        assignedTo: (r['assigned_to'] as String?) ?? '',
        fabricSampleId: (r['fabric_sample_id'] as String?) ?? '',
      );
}

/// A photographed fabric sample ("sample wear"). Captured with the phone
/// camera and stored in the catalog; orders reference a sample - picking
/// one for an order inserts a link, it never modifies the sample.
class FabricSample {
  final String id;
  final DateTime createdAt;
  String name;
  String fabricType;
  String color;
  String pattern;
  String photoPath;

  FabricSample({
    required this.id,
    required this.createdAt,
    required this.name,
    this.fabricType = '',
    this.color = '',
    this.pattern = '',
    required this.photoPath,
  });

  factory FabricSample.create({
    required String name,
    required String photoPath,
    String fabricType = '',
    String color = '',
    String pattern = '',
  }) =>
      FabricSample(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        name: name,
        photoPath: photoPath,
        fabricType: fabricType,
        color: color,
        pattern: pattern,
      );

  Map<String, Object?> toRow() => {
        'id': id,
        'name': name,
        'fabric_type': fabricType,
        'color': color,
        'pattern': pattern,
        'photo_path': photoPath,
        'created_at': createdAt.toIso8601String(),
      };

  static FabricSample fromRow(Map<String, Object?> r) => FabricSample(
        id: r['id'] as String,
        createdAt: _parse(r['created_at'] as String),
        name: (r['name'] as String?) ?? '',
        fabricType: (r['fabric_type'] as String?) ?? '',
        color: (r['color'] as String?) ?? '',
        pattern: (r['pattern'] as String?) ?? '',
        photoPath: (r['photo_path'] as String?) ?? '',
      );
}

/// One garment inside an order, with a full measurement + design snapshot
/// taken when the order was placed. Editing later never changes the
/// customer's saved measurement history rows.
class OrderItem {
  final String id;
  final String orderId;
  final DateTime createdAt;
  String garmentKey;
  int quantity;
  Map<String, String> measurement; // snapshot values
  Map<String, String> style; // design selections snapshot
  String measurementId; // source measurement row, '' if none
  String notes;
  DateTime updatedAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.createdAt,
    required this.garmentKey,
    this.quantity = 1,
    Map<String, String>? measurement,
    Map<String, String>? style,
    this.measurementId = '',
    this.notes = '',
    DateTime? updatedAt,
  })  : measurement = measurement ?? {},
        style = style ?? {},
        updatedAt = updatedAt ?? createdAt;

  factory OrderItem.create({
    required String orderId,
    required String garmentKey,
    int quantity = 1,
    Map<String, String>? measurement,
    Map<String, String>? style,
    String measurementId = '',
    String notes = '',
  }) =>
      OrderItem(
        id: const Uuid().v4(),
        orderId: orderId,
        createdAt: DateTime.now(),
        garmentKey: garmentKey,
        quantity: quantity,
        measurement: measurement,
        style: style,
        measurementId: measurementId,
        notes: notes,
      );

  Map<String, Object?> toRow() => {
        'id': id,
        'order_id': orderId,
        'garment_key': garmentKey,
        'quantity': quantity,
        'measurement_json': jsonEncode(measurement),
        'style_json': jsonEncode(style),
        'measurement_id': measurementId,
        'notes': notes,
        'updated_at': updatedAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  static OrderItem fromRow(Map<String, Object?> r) {
    final updatedRaw =
        (r['updated_at'] as String?) ?? (r['created_at'] as String?) ?? '';
    return OrderItem(
      id: r['id'] as String,
      orderId: r['order_id'] as String,
      createdAt: _parse(r['created_at'] as String),
      garmentKey: (r['garment_key'] as String?) ?? '',
      quantity: (r['quantity'] as int?) ?? 1,
      measurement: _jsonMap(r['measurement_json']),
      style: _jsonMap(r['style_json']),
      measurementId: (r['measurement_id'] as String?) ?? '',
      notes: (r['notes'] as String?) ?? '',
      updatedAt: _parse(updatedRaw),
    );
  }
}

class StaffMember {
  final String id;
  final DateTime createdAt;
  String name;
  String phone;

  StaffMember({
    required this.id,
    required this.createdAt,
    required this.name,
    this.phone = '',
  });

  factory StaffMember.create({required String name, String phone = ''}) =>
      StaffMember(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        name: name,
        phone: phone,
      );

  Map<String, Object?> toRow() => {
        'id': id,
        'name': name,
        'phone': phone,
        'created_at': createdAt.toIso8601String(),
      };

  static StaffMember fromRow(Map<String, Object?> r) => StaffMember(
        id: r['id'] as String,
        createdAt: _parse(r['created_at'] as String),
        name: (r['name'] as String?) ?? '',
        phone: (r['phone'] as String?) ?? '',
      );
}

/// Every status change is recorded here for tracking and reports.
class StatusHistoryEntry {
  final String id;
  final String orderId;
  final OrderStatus status;
  final DateTime changedAt;
  final String note;

  StatusHistoryEntry({
    required this.id,
    required this.orderId,
    required this.status,
    required this.changedAt,
    this.note = '',
  });

  factory StatusHistoryEntry.create({
    required String orderId,
    required OrderStatus status,
    String note = '',
  }) =>
      StatusHistoryEntry(
        id: const Uuid().v4(),
        orderId: orderId,
        status: status,
        changedAt: DateTime.now(),
        note: note,
      );

  Map<String, Object?> toRow() => {
        'id': id,
        'order_id': orderId,
        'status': orderStatusName(status),
        'changed_at': changedAt.toIso8601String(),
        'note': note,
      };

  static StatusHistoryEntry fromRow(Map<String, Object?> r) =>
      StatusHistoryEntry(
        id: r['id'] as String,
        orderId: r['order_id'] as String,
        status: orderStatusFromName(r['status'] as String?),
        changedAt: _parse(r['changed_at'] as String),
        note: (r['note'] as String?) ?? '',
      );
}

class Payment {
  final String id;
  final String orderId;
  final DateTime createdAt;
  double amount;
  DateTime paidAt;
  String note;

  Payment({
    required this.id,
    required this.orderId,
    required this.createdAt,
    required this.amount,
    required this.paidAt,
    this.note = '',
  });

  factory Payment.create({
    required String orderId,
    required double amount,
    DateTime? paidAt,
    String note = '',
  }) =>
      Payment(
        id: const Uuid().v4(),
        orderId: orderId,
        createdAt: DateTime.now(),
        amount: amount,
        paidAt: paidAt ?? DateTime.now(),
        note: note,
      );

  Map<String, Object?> toRow() => {
        'id': id,
        'order_id': orderId,
        'amount': amount,
        'paid_at': dayKey(paidAt),
        'note': note,
        'created_at': createdAt.toIso8601String(),
      };

  static Payment fromRow(Map<String, Object?> r) => Payment(
        id: r['id'] as String,
        orderId: r['order_id'] as String,
        createdAt: _parse(r['created_at'] as String),
        amount: _num(r['amount']) ?? 0,
        paidAt: _parseDay(r['paid_at'] as String?) ?? DateTime.now(),
        note: (r['note'] as String?) ?? '',
      );
}
