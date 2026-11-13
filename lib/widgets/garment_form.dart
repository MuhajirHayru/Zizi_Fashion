import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/garment_definitions.dart';
import '../state/settings_provider.dart';
import '../util/format.dart';

/// Dynamic form for one garment type: centimetre measurement fields plus
/// style/design dropdowns, driven entirely by [GarmentDef]. Values are
/// read/written directly in [values] (the snapshot map).
class GarmentMeasurementForm extends StatelessWidget {
  const GarmentMeasurementForm({
    super.key,
    required this.def,
    required this.values,
    this.showStyles = true,
  });

  final GarmentDef def;
  final Map<String, String> values;
  final bool showStyles;

  @override
  Widget build(BuildContext context) {
    final isAm = context.read<SettingsProvider>().locale.languageCode == 'am';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (def.measurements.isNotEmpty) ...[
          Text(
            isAm ? 'መጠኖች (ሳ.ሜ)' : 'Measurements (cm)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          // Mockup-style rows: label on the left, compact value field on
          // the right.
          for (final field in def.measurements)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${field.label(isAm)} (cm)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      initialValue: values[field.key] ?? '',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      onChanged: (v) => values[field.key] = v.trim(),
                    ),
                  ),
                ],
              ),
            ),
        ],
        if (showStyles && def.styles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            isAm ? 'ንድፍና ቅርጽ' : 'Design & style',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          for (final field in def.styles)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DropdownButtonFormField<String>(
                initialValue: (values[field.key] ?? '').isEmpty
                    ? null
                    : values[field.key],
                decoration: InputDecoration(
                  labelText: field.label(isAm),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  for (final option in field.options)
                    DropdownMenuItem(
                      value: option.value,
                      child: Text(isAm ? option.am : option.en),
                    ),
                ],
                onChanged: (v) => values[field.key] = v ?? '',
              ),
            ),
        ],
      ],
    );
  }
}

/// Compact one-line summary of a snapshot map, e.g.
/// "Chest 92.5 · Waist 78 · Fitting Slim".
String garmentValuesSummary(
    List<GarmentField> fields, Map<String, String> values, bool isAm,
    {int maxFields = 4}) {
  final parts = <String>[];
  for (final field in fields) {
    final v = values[field.key];
    if (v == null || v.isEmpty) continue;
    final label = field.label(isAm);
    final display = field.type == FieldType.choice
        ? optionLabel(field.options, v, isAm)
        : numStrSafe(v);
    parts.add('$label $display');
    if (parts.length >= maxFields) break;
  }
  return parts.join(' · ');
}

String numStrSafe(String raw) {
  final value = double.tryParse(raw);
  return value == null ? raw : numStr(value);
}

/// All values of a snapshot as label/value pairs (used in detail views).
List<(String, String)> garmentValuePairs(
    GarmentDef def, Map<String, String> values, bool isAm) {
  final pairs = <(String, String)>[];
  for (final field in [...def.measurements, ...def.styles]) {
    final v = values[field.key];
    if (v == null || v.isEmpty) continue;
    final display = field.type == FieldType.choice
        ? optionLabel(field.options, v, isAm)
        : numStrSafe(v);
    pairs.add((field.label(isAm), display));
  }
  return pairs;
}
