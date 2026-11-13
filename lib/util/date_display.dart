import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/settings_provider.dart';
import 'ethiopian_calendar.dart';

/// Locale-aware display date: Gregorian ("November 13, 2026") when the app
/// language is English, Ethiopian ("ሕዳር 4, 2019") when Amharic.
/// Stored dates are always Gregorian ISO strings - only display changes.
String displayDate(BuildContext context, DateTime? date) {
  if (date == null) return '—';
  final isAm =
      context.read<SettingsProvider>().locale.languageCode == 'am';
  return isAm
      ? formatEthiopian(date, amharicNames: true)
      : formatGregorian(date);
}

String displayTime(BuildContext context, DateTime? date) {
  if (date == null) return '—';
  final hh = date.hour.toString().padLeft(2, '0');
  final mm = date.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}
