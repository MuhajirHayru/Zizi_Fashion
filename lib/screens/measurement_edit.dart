import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../models.dart';
import '../state/shop_provider.dart';
import '../util/format.dart';
import '../widgets/measurement_labels.dart';

class MeasurementEditScreen extends StatefulWidget {
  const MeasurementEditScreen({
    super.key,
    required this.customerId,
    this.existing,
  });

  final String customerId;
  final Measurement? existing;

  @override
  State<MeasurementEditScreen> createState() => _MeasurementEditScreenState();
}

class _MeasurementEditScreenState extends State<MeasurementEditScreen> {
  late final Map<String, TextEditingController> _controllers = {
    for (final key in measurementFields.keys)
      key: TextEditingController(
        text: widget.existing?.getField(key) == null
            ? ''
            : numStr(widget.existing!.getField(key)!),
      ),
  };

  late final TextEditingController _notes =
      TextEditingController(text: widget.existing?.notes ?? '');

  late DateTime _date = widget.existing?.dateTaken ?? DateTime.now();

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final measurement =
        widget.existing ?? Measurement.create(customerId: widget.customerId);
    measurement
      ..dateTaken = _date
      ..notes = _notes.text.trim();
    for (final entry in measurementFields.entries) {
      measurement.setField(entry.key, parseAmount(_controllers[entry.key]!.text));
    }
    await context.read<ShopProvider>().saveMeasurement(measurement);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null
            ? l10n.addMeasurement
            : l10n.editMeasurement),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.event),
              title: Text(l10n.fieldDate),
              subtitle: Text(dayLabel(_date)),
              onTap: _pickDate,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: [
              for (final entry in measurementFields.entries)
                TextFormField(
                  controller: _controllers[entry.key],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: entry.value(l10n),
                    border: const OutlineInputBorder(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notes,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.fieldNotes,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
