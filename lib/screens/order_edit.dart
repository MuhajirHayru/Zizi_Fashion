import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../models.dart';
import '../state/shop_provider.dart';
import '../util/format.dart';
import 'common.dart';
import 'customer_picker.dart';

class OrderEditScreen extends StatefulWidget {
  const OrderEditScreen({super.key, this.existing});

  final ShopOrder? existing;

  @override
  State<OrderEditScreen> createState() => _OrderEditScreenState();
}

class _OrderEditScreenState extends State<OrderEditScreen> {
  Customer? _customer;
  String? _style;
  DateTime? _delivery;

  late final TextEditingController _fabric =
      TextEditingController(text: widget.existing?.fabric ?? '');
  late final TextEditingController _total = TextEditingController(
    text: widget.existing == null ? '' : amountStr(widget.existing!.totalPrice),
  );
  final TextEditingController _deposit = TextEditingController();
  late final TextEditingController _notes =
      TextEditingController(text: widget.existing?.notes ?? '');

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _customer = context.read<ShopProvider>().customerById(existing.customerId);
      _style = orderStyleKeys.contains(existing.style) ? existing.style : 'other';
      _delivery = existing.deliveryDate;
    }
  }

  @override
  void dispose() {
    _fabric.dispose();
    _total.dispose();
    _deposit.dispose();
    _notes.dispose();
    super.dispose();
  }

  Map<String, String> _styleLabels(AppLocalizations l10n) => {
        'suit': l10n.styleSuit,
        'shirt': l10n.styleShirt,
        'trousers': l10n.styleTrousers,
        'dress': l10n.styleDress,
        'traditional': l10n.styleTraditional,
        'other': l10n.styleOther,
      };

  Future<void> _pickDeliveryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _delivery ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _delivery = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final total = parseAmount(_total.text);
    // Graduation orders keep their garment items; the style chips only
    // apply to legacy 'general' orders.
    final showStyle = widget.existing == null ||
        widget.existing!.category != 'graduation_men';
    if (_customer == null) {
      showSnack(context, l10n.selectCustomer);
      return;
    }
    if (showStyle && _style == null) {
      showSnack(context, l10n.style);
      return;
    }
    if (total == null || total < 0) {
      showSnack(context, l10n.enterValidAmount);
      return;
    }

    final shop = context.read<ShopProvider>();
    if (widget.existing != null) {
      widget.existing!
        ..fabric = _fabric.text.trim()
        ..totalPrice = total
        ..deliveryDate = _delivery
        ..notes = _notes.text.trim();
      if (showStyle) {
        widget.existing!.style = _style!;
      }
      await shop.saveOrder(widget.existing!);
    } else {
      final order = ShopOrder.create(
        customerId: _customer!.id,
        style: _style!,
        totalPrice: total,
        fabric: _fabric.text.trim(),
        deliveryDate: _delivery,
        notes: _notes.text.trim(),
      );
      await shop.saveOrder(order);
      // A deposit entered here is stored as the order's first payment.
      final deposit = parseAmount(_deposit.text);
      if (deposit != null && deposit > 0) {
        await shop.savePayment(Payment.create(
          orderId: order.id,
          amount: deposit,
          note: l10n.deposit,
        ));
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();
    final labels = _styleLabels(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? l10n.newOrder : l10n.editOrder),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(_customer?.name ?? l10n.selectCustomer),
              subtitle: _customer?.phone.isEmpty == false
                  ? Text(_customer!.phone)
                  : null,
              trailing: const Icon(Icons.chevron_right),
              // Customer is fixed once the order exists.
              onTap: widget.existing == null
                  ? () async {
                      final picked = await Navigator.push<Customer>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerPickerScreen(),
                        ),
                      );
                      if (picked != null) {
                        setState(() => _customer = picked);
                      }
                    }
                  : null,
            ),
          ),
          if (widget.existing == null && shop.customers.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l10n.noCustomers),
            ),
          if (widget.existing == null ||
              widget.existing!.category != 'graduation_men') ...[
            const SizedBox(height: 16),
            Text(l10n.style, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final key in orderStyleKeys)
                  ChoiceChip(
                    label: Text(labels[key]!),
                    selected: _style == key,
                    onSelected: (_) => setState(() => _style = key),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _fabric,
            decoration: InputDecoration(
              labelText: l10n.fabric,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _total,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.totalPrice,
              suffixText: l10n.currencyBirr,
              border: const OutlineInputBorder(),
            ),
          ),
          if (widget.existing == null) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _deposit,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.depositOptional,
                suffixText: l10n.currencyBirr,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event),
              title: Text(l10n.deliveryDate),
              subtitle: Text(dayLabel(_delivery)),
              onTap: _pickDeliveryDate,
            ),
          ),
          const SizedBox(height: 12),
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
