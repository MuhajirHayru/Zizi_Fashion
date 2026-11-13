import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../models.dart';
import '../state/shop_provider.dart';
import 'common.dart';

/// Add/edit form in a bottom sheet. Returns true when something was saved.
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
  late final TextEditingController _notes =
      TextEditingController(text: widget.customer?.notes ?? '');

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
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
      ));
    } else {
      widget.customer!
        ..name = name
        ..phone = _phone.text.trim()
        ..notes = _notes.text.trim();
      await shop.saveCustomer(widget.customer!);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            controller: _name,
            autofocus: widget.customer == null,
            decoration: InputDecoration(
              labelText: l10n.fieldName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.fieldPhone,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.fieldNotes,
              border: const OutlineInputBorder(),
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
