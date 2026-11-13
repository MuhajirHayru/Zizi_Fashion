import 'package:intl/intl.dart';

final NumberFormat _money = NumberFormat('#,##0.00');
final DateFormat _day = DateFormat('yyyy-MM-dd');

String money(double value) => _money.format(value);

String dayLabel(DateTime? date) => date == null ? '—' : _day.format(date);

/// 38 -> "38", 38.5 -> "38.5" (nice for measurement chips and input fields).
String numStr(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

/// Money for text fields: no thousands separators (so it re-parses cleanly),
/// up to 2 decimals: 3000 -> "3000", 2999.5 -> "2999.50".
String amountStr(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);

double? parseAmount(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}
