import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../data/garment_definitions.dart';
import '../models.dart';
import '../state/shop_provider.dart';
import 'common.dart';

/// Add/edit form in a bottom sheet. Returns true when something was saved.
/// Simplified profile: phone, name, gender, address, notes.
Future<bool> showCustomerEditor(
  BuildContext context, {
  Customer? customer,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CustomerEditorForm(customer: customer),
  );
  return result ?? false;
}

class _CustomerEditorForm extends StatefulWidget {
  const _CustomerEditorForm({this.customer});

  final Customer? customer;

  @override
  State<_CustomerEditorForm> createState() => _CustomerEditorFormState();
}

class _CustomerEditorFormState extends State<_CustomerEditorForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.customer?.name ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.customer?.phone ?? '');
  late final TextEditingController _address =
      TextEditingController(text: widget.customer?.address ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: widget.customer?.notes ?? '');
  String _gender = '';

  @override
  void initState() {
    super.initState();
    _gender = widget.customer?.gender ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _name.text.trim();
    if (name.isEmpty) {
      showSnack(context, l10n.nameRequired);
      return;
    }
    final shop = context.read<ShopProvider>();
    if (widget.customer == null) {
      await shop.saveCustomer(Customer.create(
        name: name,
        phone: _phone.text.trim(),
        notes: _notes.text.trim(),
        gender: _gender,
        address: _address.text.trim(),
      ));
    } else {
      widget.customer!
        ..name = name
        ..phone = _phone.text.trim()
        ..gender = _gender
        ..address = _address.text.trim()
        ..notes = _notes.text.trim();
      await shop.saveCustomer(widget.customer!);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAm = Localizations.localeOf(context).languageCode == 'am';
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.customer == null ? l10n.newCustomerTitle : l10n.editCustomer,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phone,
            autofocus: widget.customer == null,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.fieldPhone,
              prefixIcon: const Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: l10n.fieldName,
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _gender.isEmpty ? null : _gender,
            decoration: InputDecoration(
              labelText: l10n.fieldGender,
              prefixIcon: const Icon(Icons.people),
            ),
            items: [
              for (final o in genderOptions)
                DropdownMenuItem(
                    value: o.value, child: Text(isAm ? o.am : o.en)),
            ],
            onChanged: (v) => setState(() => _gender = v ?? ''),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            decoration: InputDecoration(
              labelText: l10n.fieldAddress,
              prefixIcon: const Icon(Icons.place),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.fieldNotes,
              prefixIcon: const Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _save, child: Text(l10n.save)),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
