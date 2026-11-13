import '../models.dart';
import '../state/shop_provider.dart';

/// Combined filters for the orders list (requirement: multiple filters can
/// be applied together, e.g. "male graduation suit orders of this month
/// that are not delivered yet").
class OrderFilter {
  String text = '';
  OrderStatus? status;
  String garmentKey = '';
  DateTime? orderFrom;
  DateTime? orderTo;
  DateTime? deliveryFrom;
  DateTime? deliveryTo;
  String tailor = '';
  String region = '';
  String city = '';
  String fabric = '';
  bool newestFirst = true;

  bool get isActive =>
      text.trim().isNotEmpty ||
      status != null ||
      garmentKey.isNotEmpty ||
      orderFrom != null ||
      orderTo != null ||
      deliveryFrom != null ||
      deliveryTo != null ||
      tailor.trim().isNotEmpty ||
      region.isNotEmpty ||
      city.trim().isNotEmpty ||
      fabric.trim().isNotEmpty;

  void clear() {
    text = '';
    status = null;
    garmentKey = '';
    orderFrom = null;
    orderTo = null;
    deliveryFrom = null;
    deliveryTo = null;
    tailor = '';
    region = '';
    city = '';
    fabric = '';
  }

  bool _inRange(DateTime? date, DateTime? from, DateTime? to) {
    if (from == null && to == null) return true;
    if (date == null) return false;
    final d = DateTime(date.year, date.month, date.day);
    if (from != null) {
      final f = DateTime(from.year, from.month, from.day);
      if (d.isBefore(f)) return false;
    }
    if (to != null) {
      final t = DateTime(to.year, to.month, to.day);
      if (d.isAfter(t)) return false;
    }
    return true;
  }

  List<ShopOrder> apply(List<ShopOrder> orders, ShopProvider shop) {
    final query = text.trim().toLowerCase();
    final tailorQuery = tailor.trim().toLowerCase();
    final cityQuery = city.trim().toLowerCase();
    final fabricQuery = fabric.trim().toLowerCase();

    final result = orders.where((o) {
      final customer = shop.customerById(o.customerId);
      if (query.isNotEmpty) {
        final hay = '${o.orderNo} ${o.id} ${customer?.name ?? ''} '
                '${customer?.phone ?? ''}'
            .toLowerCase();
        if (!hay.contains(query)) return false;
      }
      if (status != null && o.status != status) return false;
      if (garmentKey.isNotEmpty &&
          !shop.itemsFor(o.id).any((i) => i.garmentKey == garmentKey)) {
        return false;
      }
      if (!_inRange(o.createdAt, orderFrom, orderTo)) return false;
      if (!_inRange(o.deliveryDate, deliveryFrom, deliveryTo)) return false;
      if (tailorQuery.isNotEmpty &&
          !o.assignedTo.toLowerCase().contains(tailorQuery)) {
        return false;
      }
      if (region.isNotEmpty && (customer?.region ?? '') != region) return false;
      if (cityQuery.isNotEmpty &&
          !(customer?.city.toLowerCase().contains(cityQuery) ?? false)) {
        return false;
      }
      if (fabricQuery.isNotEmpty &&
          !o.fabric.toLowerCase().contains(fabricQuery)) {
        return false;
      }
      return true;
    }).toList();

    result.sort((a, b) => newestFirst
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
    return result;
  }
}

/// Combined filters for the customers list.
class CustomerFilter {
  String text = '';
  String gender = '';
  String customerType = '';
  String region = '';
  String city = '';

  bool get isActive =>
      text.trim().isNotEmpty ||
      gender.isNotEmpty ||
      customerType.isNotEmpty ||
      region.isNotEmpty ||
      city.trim().isNotEmpty;

  void clear() {
    text = '';
    gender = '';
    customerType = '';
    region = '';
    city = '';
  }

  List apply(List customers) {
    final query = text.trim().toLowerCase();
    final cityQuery = city.trim().toLowerCase();
    return customers.where((c) {
      if (query.isNotEmpty) {
        final hay =
            '${c.name} ${c.phone} ${c.id}'.toLowerCase();
        if (!hay.contains(query)) return false;
      }
      if (gender.isNotEmpty && c.gender != gender) return false;
      if (customerType.isNotEmpty && c.customerType != customerType) return false;
      if (region.isNotEmpty && c.region != region) return false;
      if (cityQuery.isNotEmpty && !c.city.toLowerCase().contains(cityQuery)) {
        return false;
      }
      return true;
    }).toList();
  }
}
