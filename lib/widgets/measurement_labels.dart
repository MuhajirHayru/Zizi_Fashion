import 'package:tailor_shop/l10n/app_localizations.dart';

/// Ordered map of measurement keys (matching Measurement.getField/setField)
/// to their localized labels. The order here is the order shown in the form.
final Map<String, String Function(AppLocalizations)> measurementFields = {
  'neck': (l) => l.neck,
  'chest': (l) => l.chest,
  'waist': (l) => l.waist,
  'hip': (l) => l.hip,
  'shoulder': (l) => l.shoulder,
  'sleeve': (l) => l.sleeve,
  'bicep': (l) => l.bicep,
  'wrist': (l) => l.wrist,
  'thigh': (l) => l.thigh,
  'knee': (l) => l.knee,
  'trouserLength': (l) => l.trouserLength,
  'bottomWidth': (l) => l.bottomWidth,
};
