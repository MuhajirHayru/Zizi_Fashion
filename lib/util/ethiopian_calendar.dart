/// Ethiopian (Ethiopic / Amete Mihret) calendar conversion.
///
/// Exact integer math over Julian Day Numbers:
/// - 12 months of 30 days + Pagume (13th month) with 5 days,
///   6 days in Ethiopian leap years (`year % 4 == 3`).
/// - Dates are stored in the database as Gregorian ISO strings and only
///   converted for display; switching language never changes stored data.
library;

const int _ethiopicEpochJdn = 1724221; // JDN of 1/1/1 E.C.

const List<String> ethiopianMonthNamesAm = [
  'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሣሥ', 'ጥር', 'የካቲት',
  'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜ',
];

const List<String> ethiopianMonthNamesEn = [
  'Meskerem', 'Tikimt', 'Hidar', 'Tahsas', 'Tir', 'Yekatit',
  'Megabit', 'Miyazya', 'Ginbot', 'Sene', 'Hamle', 'Nehase', 'Pagume',
];

class EthiopicDate {
  const EthiopicDate(this.year, this.month, this.day);
  final int year;
  final int month; // 1..13
  final int day;

  @override
  String toString() => '$month/$day/$year E.C.';
}

/// Current date-time in Africa/Addis_Ababa (UTC+3, no daylight saving).
DateTime nowInAddis() => DateTime.now().toUtc().add(const Duration(hours: 3));

DateTime todayInAddis() {
  final n = nowInAddis();
  return DateTime(n.year, n.month, n.day);
}

int jdnFromGregorian(int y, int m, int d) {
  final int a = (14 - m) ~/ 12;
  final int yy = y + 4800 - a;
  final int mm = m + 12 * a - 3;
  return d + (153 * mm + 2) ~/ 5 + 365 * yy + yy ~/ 4 - yy ~/ 100 + yy ~/ 400 - 32045;
}

(int, int, int) jdnToGregorian(int jdn) {
  final int a = jdn + 32044;
  final int b = (4 * a + 3) ~/ 146097;
  final int c = a - (146097 * b) ~/ 4;
  final int dd = (4 * c + 3) ~/ 1461;
  final int e = c - (1461 * dd) ~/ 4;
  final int m = (5 * e + 2) ~/ 153;
  final int day = e - (153 * m + 2) ~/ 5 + 1;
  final int month = m + 3 - 12 * (m ~/ 10);
  final int year = 100 * b + dd - 4800 + m ~/ 10;
  return (year, month, day);
}

int jdnFromEthiopic(int y, int m, int d) =>
    _ethiopicEpochJdn + 365 * (y - 1) + y ~/ 4 + 30 * (m - 1) + d - 1;

int _startOfEthYear(int y) => _ethiopicEpochJdn + 365 * (y - 1) + y ~/ 4;

EthiopicDate jdnToEthiopic(int jdn) {
  final int days = jdn - _ethiopicEpochJdn;
  // Linear estimate (leap days removed), then correct by walking.
  int year = 1 + (days - days ~/ 1461) ~/ 365;
  while (year > 1 && _startOfEthYear(year) > jdn) {
    year--;
  }
  while (_startOfEthYear(year + 1) <= jdn) {
    year++;
  }
  final int dayOfYear = jdn - _startOfEthYear(year); // 0-based
  if (dayOfYear < 360) {
    return EthiopicDate(year, dayOfYear ~/ 30 + 1, dayOfYear % 30 + 1);
  }
  return EthiopicDate(year, 13, dayOfYear - 359); // Pagume
}

EthiopicDate ethiopicFromGregorian(int y, int m, int d) =>
    jdnToEthiopic(jdnFromGregorian(y, m, d));

EthiopicDate ethiopicFromDateTime(DateTime dt) =>
    ethiopicFromGregorian(dt.year, dt.month, dt.day);

DateTime gregorianFromEthiopic(EthiopicDate e) {
  final (y, m, d) = jdnToGregorian(jdnFromEthiopic(e.year, e.month, e.day));
  return DateTime(y, m, d);
}

/// "ሕዳር 4, 2019" (or Latin transliteration with [amharicNames] = false).
String formatEthiopian(DateTime dt, {bool amharicNames = true}) {
  final e = ethiopicFromDateTime(dt);
  final name = amharicNames
      ? ethiopianMonthNamesAm[e.month - 1]
      : ethiopianMonthNamesEn[e.month - 1];
  return '$name ${e.day}, ${e.year}';
}

/// "November 13, 2026"
String formatGregorian(DateTime dt) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}
