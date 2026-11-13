import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'app_storage.dart';
import 'garment_definitions.dart';
import '../models.dart';
import '../state/shop_provider.dart';
import '../util/ethiopian_calendar.dart' show formatGregorian, todayInAddis;
import '../util/format.dart';
import '../widgets/garment_form.dart' show garmentValuePairs;
import '../widgets/status_chip.dart' show statusLabelEn;

/// Report generation: Excel-ready CSV exports, order-list PDF and printable
/// measurement sheets. Everything is rendered with Noto Sans Ethiopic so
/// Amharic data prints correctly. Reports are saved in the app documents
/// folder (send them over Telegram like the APK).
class ReportService {
  static Future<pw.Font> _loadFont() async {
    final data =
        await rootBundle.load('assets/fonts/NotoSansEthiopic-Regular.ttf');
    return pw.Font.ttf(data);
  }

  static Future<Directory> _docsDir() => AppStorage.base();

  static String _esc(Object? v) =>
      '"${(v?.toString() ?? '').replaceAll('"', '""')}"';

  // ---------- CSV (opens directly in Excel) ----------

  static Future<String> saveOrdersCsv(
      List<ShopOrder> orders, ShopProvider shop) async {
    final sb = StringBuffer();
    sb.writeln(
        'Order No,Order Date,Delivery Date,Customer,Customer ID,Phone,Gender,Region,City,Sub-city/Woreda,Kebele,Category,Garments,Fabric,Total,Paid,Balance,Status,Assigned Tailor,Registered By');
    for (final o in orders) {
      final c = shop.customerById(o.customerId);
      final garments = shop
          .itemsFor(o.id)
          .map((i) => '${i.garmentKey} x${i.quantity}')
          .join(' | ');
      sb.writeln([
        o.orderNo,
        dayKey(o.createdAt),
        o.deliveryDate == null ? '' : dayKey(o.deliveryDate!),
        c?.name,
        c?.id,
        c?.phone,
        c?.gender,
        regionLabel(c?.region, false),
        c?.city,
        c?.subCity,
        c?.kebele,
        o.category,
        garments,
        o.fabric,
        money(o.totalPrice),
        money(shop.paidFor(o.id)),
        money(shop.balanceFor(o)),
        statusLabelEn(o.status),
        o.assignedTo,
        c?.registeredBy,
      ].map(_esc).join(','));
    }
    return shop.writeCsv('zizi_orders', sb.toString());
  }

  static Future<String> saveCustomersCsv(
      List customers, ShopProvider shop) async {
    final sb = StringBuffer();
    sb.writeln(
        'Customer ID,Name,Phone,Alt Phone,Gender,Customer Type,Region,City,Sub-city/Woreda,Kebele,Address,Registered By,Registration Date,Orders');
    for (final c in customers) {
      sb.writeln([
        c.id,
        c.name,
        c.phone,
        c.altPhone,
        c.gender,
        c.customerType,
        regionLabel(c.region, false),
        c.city,
        c.subCity,
        c.kebele,
        c.address,
        c.registeredBy,
        dayKey(c.createdAt),
        shop.ordersFor(c.id).length,
      ].map(_esc).join(','));
    }
    return shop.writeCsv('zizi_customers', sb.toString());
  }

  // ---------- PDF documents ----------

  static Future<pw.Document> _ordersPdf(
      List<ShopOrder> orders, ShopProvider shop) async {
    final font = await _loadFont();
    final doc = pw.Document(theme: pw.ThemeData.withFont(base: font, bold: font));
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Header(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('ZIZI FASHION',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'Orders report — ${orders.length} orders — ${formatGregorian(todayInAddis())}'),
            ],
          ),
        ),
        pw.Table.fromTextArray(
          headers: const [
            'Order No', 'Date', 'Customer', 'Phone', 'Status', 'Tailor',
            'Total', 'Balance',
          ],
          data: [
            for (final o in orders)
              [
                o.orderNo,
                dayKey(o.createdAt),
                shop.customerById(o.customerId)?.name ?? '',
                shop.customerById(o.customerId)?.phone ?? '',
                statusLabelEn(o.status),
                o.assignedTo,
                money(o.totalPrice),
                money(shop.balanceFor(o)),
              ]
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellPadding: const pw.EdgeInsets.all(3),
        ),
      ],
    ));
    return doc;
  }

  static Future<String> saveOrdersPdf(
      List<ShopOrder> orders, ShopProvider shop) async {
    final doc = await _ordersPdf(orders, shop);
    final file = File(p.join(
        (await _docsDir()).path, 'zizi_orders_${dayKey(todayInAddis())}.pdf'));
    await file.writeAsBytes(await doc.save());
    return file.path;
  }

  static Future<void> printOrdersPdf(
      List<ShopOrder> orders, ShopProvider shop) async {
    final doc = await _ordersPdf(orders, shop);
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  // ---------- printable measurement sheet ----------

  static const Map<String, String> _legacyEn = {
    'neck': 'Neck', 'chest': 'Chest', 'waist': 'Waist', 'hip': 'Hip',
    'shoulder': 'Shoulder', 'sleeve': 'Sleeve', 'bicep': 'Bicep',
    'wrist': 'Wrist', 'thigh': 'Thigh', 'knee': 'Knee',
    'trouserLength': 'Trouser length', 'bottomWidth': 'Bottom width',
  };
  static const Map<String, String> _legacyAm = {
    'neck': 'አንገት', 'chest': 'ደረት', 'waist': 'ወገብ', 'hip': 'ሂፕ',
    'shoulder': 'ትከሻ', 'sleeve': 'የእጅ ርዝመት', 'bicep': 'የእጅ ዙሪያ',
    'wrist': 'የእጅ አንገት', 'thigh': 'የጉልበት ላይ ዙሪያ', 'knee': 'የጉልበት ዙሪያ',
    'trouserLength': 'የሱሪ ርዝመት', 'bottomWidth': 'የሱሪ ግርጌ ስፋት',
  };

  static Future<pw.Document> _measurementDoc(
      Customer customer, ShopProvider shop, bool isAm) async {
    final font = await _loadFont();
    final doc = pw.Document(theme: pw.ThemeData.withFont(base: font, bold: font));
    String l(String en, String am) => isAm ? am : en;
    final widgets = <pw.Widget>[
      pw.Header(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('ZIZI FASHION',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text(l('Customer measurement sheet', 'የደንበኛ መጠን ማስታወሻ')),
          ],
        ),
      ),
      pw.Text(
        '${l('Name', 'ስም')}: ${customer.name}\n'
        '${l('Phone', 'ስልክ')}: ${customer.phone}\n'
        '${l('Customer ID', 'የደንበኛ ቁጥር')}: ${customer.id}\n'
        '${l('Address', 'አድራሻ')}: '
        '${regionLabel(customer.region, isAm)} ${customer.city} ${customer.subCity} ${customer.kebele}',
      ),
      pw.SizedBox(height: 12),
    ];

    // Garment measurements (dynamic, per category) saved for this customer.
    final rows = <pw.Widget>[];
    for (final m in shop.measurementsFor(customer.id)) {
      final def = garmentByKey(m.category);
      if (def == null) {
        final labels = isAm ? _legacyAm : _legacyEn;
        final values = <(String, String)>[
          for (final entry in labels.entries)
            if (m.getField(entry.key) != null)
              (entry.value, numStr(m.getField(entry.key)!)),
        ];
        if (values.isEmpty) continue;
        rows.add(_categoryBlock(l('General', 'ጠቅላላ'), m.dateTaken, values));
      } else {
        final values = garmentValuePairs(def, m.fields, isAm);
        if (values.isEmpty) continue;
        rows.add(_categoryBlock(def.label(isAm), m.dateTaken, values));
      }
    }
    if (rows.isEmpty) {
      rows.add(pw.Text(l('No measurements saved yet.', 'መጠኖች አሁን አልተመዘገቡም።')));
    }
    widgets.addAll(rows);

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => widgets,
    ));
    return doc;
  }

  static pw.Widget _categoryBlock(
      String title, DateTime date, List<(String, String)> values) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$title — ${dayKey(date)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            headers: const ['Field', 'Value'],
            data: [for (final (k, v) in values) [k, v]],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding: const pw.EdgeInsets.all(3),
          ),
        ],
      ),
    );
  }

  static Future<String> saveMeasurementSheet(
      Customer customer, ShopProvider shop, bool isAm) async {
    final doc = await _measurementDoc(customer, shop, isAm);
    final file = File(p.join(
      (await _docsDir()).path,
      'zizi_measurements_${customer.phone.isEmpty ? customer.id.substring(0, 8) : customer.phone}.pdf',
    ));
    await file.writeAsBytes(await doc.save());
    return file.path;
  }

  static Future<void> printMeasurementSheet(
      Customer customer, ShopProvider shop, bool isAm) async {
    final doc = await _measurementDoc(customer, shop, isAm);
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }
}
