import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../models.dart';
import '../state/shop_provider.dart';
import '../util/format.dart';
import 'common.dart';

/// Add/edit payment in a bottom sheet (amount, date, note).
Future<void> showPaymentEditor(
  BuildContext context,
  ShopOrder order, {
  Payment? payment,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PaymentForm(order: order, payment: payment),
  );
}

class _PaymentForm extends StatefulWidget {
  const _PaymentForm({required this.order, this.payment});

  final ShopOrder order;
  final Payment? payment;

  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.payment == null ? '' : amountStr(widget.payment!.amount),
  );
  late final TextEditingController _note =
      TextEditingController(text: widget.payment?.note ?? '');

  late DateTime _date = widget.payment?.paidAt ?? DateTime.now();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
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
    final l10n = AppLocalizations.of(context)!;
    final amount = parseAmount(_amount.text);
    if (amount == null || amount <= 0) {
      showSnack(context, l10n.enterValidAmount);
      return;
    }
    final payment =
        widget.payment ?? Payment.create(orderId: widget.order.id, amount: amount);
    payment
      ..amount = amount
      ..paidAt = _date
      ..note = _note.text.trim();
    await context.read<ShopProvider>().savePayment(payment);
    if (mounted) Navigator.pop(context);
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
            widget.payment == null ? l10n.addPayment : l10n.editPayment,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            autofocus: widget.payment == null,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.amount,
              suffixText: l10n.currencyBirr,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event),
              title: Text(l10n.fieldDate),
              subtitle: Text(dayLabel(_date)),
              onTap: _pickDate,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
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
                onPressed: () => Navigator.pop(context),
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
