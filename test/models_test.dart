import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_shop/models.dart';
import 'package:tailor_shop/util/ethiopian_calendar.dart';
import 'package:tailor_shop/util/format.dart';

void main() {
  group('format helpers', () {
    test('dayKey pads month and day', () {
      expect(dayKey(DateTime(2026, 3, 7)), '2026-03-07');
    });

    test('numStr trims trailing zeros', () {
      expect(numStr(38), '38');
      expect(numStr(38.5), '38.5');
    });

    test('amountStr keeps up to 2 decimals', () {
      expect(amountStr(3000), '3000');
      expect(amountStr(2999.5), '2999.50');
    });

    test('parseAmount handles empty and invalid input', () {
      expect(parseAmount(''), isNull);
      expect(parseAmount('abc'), isNull);
      expect(parseAmount(' 1250 '), 1250);
      expect(parseAmount('12.5'), 12.5);
    });
  });

  group('Ethiopian calendar', () {
    test('Ethiopian new year 2010-01-01 is Gregorian Sep 11, 2017', () {
      final g = gregorianFromEthiopic(const EthiopicDate(2010, 1, 1));
      expect(g.year, 2017);
      expect(g.month, 9);
      expect(g.day, 11);
    });

    test('Gregorian Sep 11, 2017 is Ethiopian 1/1/2010', () {
      final e = ethiopicFromGregorian(2017, 9, 11);
      expect(e.year, 2010);
      expect(e.month, 1);
      expect(e.day, 1);
    });

    test('Pagume has 6 days in Ethiopian leap years (2011)', () {
      // Ethiopian 2011 % 4 == 3 -> leap -> Pagume 6 is the last day of the
      // year. New year 2012 E.C. is Sep 12, 2019 (year before Gregorian
      // leap year 2020), so Pagume 6 is Sep 11, 2019.
      final g = gregorianFromEthiopic(const EthiopicDate(2011, 13, 6));
      expect(g.year, 2019);
      expect(g.month, 9);
      expect(g.day, 11);
    });

    test('Ethiopian non-leap year 2010 has only 5 Pagume days', () {
      final g = gregorianFromEthiopic(const EthiopicDate(2010, 13, 5));
      expect(g, DateTime(2018, 9, 10));
    });

    test('round trip Gregorian -> Ethiopic -> Gregorian is exact', () {
      final samples = [
        DateTime(2026, 11, 13),
        DateTime(2016, 2, 29), // Gregorian leap day
        DateTime(2021, 9, 11), // Ethiopian new year boundary
        DateTime(2000, 1, 1),
        DateTime(2030, 12, 31),
      ];
      for (final date in samples) {
        final e = ethiopicFromDateTime(date);
        final back = gregorianFromEthiopic(e);
        expect(back, DateTime(date.year, date.month, date.day));
      }
    });

    test('November 13, 2026 is Hidar 4, 2019', () {
      final e = ethiopicFromDateTime(DateTime(2026, 11, 13));
      expect(e.year, 2019);
      expect(e.month, 3); // Hidar
      expect(e.day, 4);
      expect(formatEthiopian(DateTime(2026, 11, 13)), 'ኅዳር 4, 2019');
    });
  });

  group('order status', () {
    test('progression and fallbacks', () {
      expect(orderStatusFromName('sewing_in_progress'),
          OrderStatus.sewingInProgress);
      expect(orderStatusFromName('bogus'), OrderStatus.newOrder);
      expect(nextOrderStatus(OrderStatus.newOrder),
          OrderStatus.measurementCompleted);
      expect(nextOrderStatus(OrderStatus.completed), OrderStatus.delivered);
      expect(nextOrderStatus(OrderStatus.delivered), isNull);
      expect(nextOrderStatus(OrderStatus.cancelled), isNull);
    });

    test('legacy v1 status names are mapped', () {
      expect(orderStatusFromName('pending'), OrderStatus.newOrder);
      expect(orderStatusFromName('fitting'), OrderStatus.readyForFitting);
      expect(orderStatusFromName('sewing'), OrderStatus.sewingInProgress);
      expect(orderStatusFromName('finished'), OrderStatus.completed);
      expect(orderStatusFromName('collected'), OrderStatus.delivered);
    });

    test('open orders exclude delivered and cancelled', () {
      expect(orderIsOpen(OrderStatus.newOrder), isTrue);
      expect(orderIsOpen(OrderStatus.completed), isTrue);
      expect(orderIsOpen(OrderStatus.delivered), isFalse);
      expect(orderIsOpen(OrderStatus.cancelled), isFalse);
    });
  });

  group('model rows', () {
    test('customer roundtrip with extended fields', () {
      final customer = Customer.create(
        name: 'Abebe',
        phone: '0911',
        notes: 'VIP',
        gender: 'male',
        altPhone: '0922',
        address: 'Bole',
        region: 'addis_ababa',
        city: 'Addis Ababa',
        subCity: 'Bole',
        kebele: '09',
        customerType: 'returning',
        registeredBy: 'Staff',
      );
      final back = Customer.fromRow(customer.toRow());
      expect(back.id, customer.id);
      expect(back.name, 'Abebe');
      expect(back.gender, 'male');
      expect(back.region, 'addis_ababa');
      expect(back.customerType, 'returning');
    });

    test('measurement setField/getField and roundtrip with nulls', () {
      final measurement = Measurement.create(customerId: 'c1');
      expect(measurement.getField('chest'), isNull);
      measurement
        ..setField('chest', 92.5)
        ..setField('trouserLength', 104);
      expect(measurement.getField('chest'), 92.5);
      expect(measurement.getField('trouserLength'), 104);
      expect(measurement.getField('waist'), isNull);

      final back = Measurement.fromRow(measurement.toRow());
      expect(back.getField('chest'), 92.5);
      expect(back.getField('waist'), isNull);
      expect(back.getField('trouserLength'), 104);
      expect(back.dateTaken.day, measurement.dateTaken.day);
    });

    test('garment measurement fields roundtrip through JSON', () {
      final m = Measurement.create(
        customerId: 'c1',
        category: 'grad_shirt',
        fields: {'shirt_length': '74', 'collar_type': 'classic'},
      );
      final back = Measurement.fromRow(m.toRow());
      expect(back.category, 'grad_shirt');
      expect(back.fields['shirt_length'], '74');
      expect(back.fields['collar_type'], 'classic');
    });

    test('order roundtrip with and without delivery date', () {
      final order = ShopOrder.create(
        customerId: 'c1',
        style: 'graduation',
        totalPrice: 3000,
        fabric: 'Wool',
        deliveryDate: DateTime(2026, 12, 1),
        orderNo: 'ZF-000001',
        category: 'graduation_men',
        assignedTo: 'Staff',
      );
      final back = ShopOrder.fromRow(order.toRow());
      expect(back.orderNo, 'ZF-000001');
      expect(back.category, 'graduation_men');
      expect(back.assignedTo, 'Staff');
      expect(back.totalPrice, 3000);
      expect(back.status, OrderStatus.newOrder);
      expect(back.deliveryDate, DateTime(2026, 12, 1));

      final undated = ShopOrder.create(
        customerId: 'c1',
        style: 'shirt',
        totalPrice: 500,
      );
      expect(ShopOrder.fromRow(undated.toRow()).deliveryDate, isNull);
    });

    test('order item snapshot roundtrip', () {
      final item = OrderItem.create(
        orderId: 'o1',
        garmentKey: 'grad_jacket',
        quantity: 2,
        measurement: {'chest': '96', 'jacket_length': '72'},
        style: {'lapel': 'peak', 'button_config': '2'},
      );
      final back = OrderItem.fromRow(item.toRow());
      expect(back.garmentKey, 'grad_jacket');
      expect(back.quantity, 2);
      expect(back.measurement['chest'], '96');
      expect(back.style['lapel'], 'peak');
    });

    test('payment roundtrip', () {
      final payment =
          Payment.create(orderId: 'o1', amount: 1500, note: 'Deposit');
      final back = Payment.fromRow(payment.toRow());
      expect(back.amount, 1500);
      expect(back.note, 'Deposit');
      expect(back.paidAt.day, payment.paidAt.day);
    });
  });
}
