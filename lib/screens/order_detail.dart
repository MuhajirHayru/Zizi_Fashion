import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../data/garment_definitions.dart';
import '../models.dart';
import '../state/shop_provider.dart';
import '../util/date_display.dart';
import '../util/format.dart';
import '../widgets/garment_form.dart';
import '../widgets/status_chip.dart';
import 'common.dart';
import 'order_edit.dart';
import 'payment_edit.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();

    final order = shop.orderById(orderId);
    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.noOrders)),
      );
    }

    final customer = shop.customerById(order.customerId);
    final paid = shop.paidFor(order.id);
    final balance = order.totalPrice - paid;
    final fullyPaid = order.totalPrice > 0 && balance <= 0;
    final next = nextOrderStatus(order.status);
    final items = shop.itemsFor(order.id);
    final history = shop.historyFor(order.id);
    final isAm = Localizations.localeOf(context).languageCode == 'am';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final delivery = order.deliveryDate;
    final isOverdue = delivery != null &&
        orderIsOpen(order.status) &&
        DateTime(delivery.year, delivery.month, delivery.day).isBefore(today);

    final categoryTitle =
        categoryValueLabel(order.category, isAm, styleKey: order.style);

    return Scaffold(
      appBar: AppBar(
        title: Text(order.orderNo.isEmpty ? categoryTitle : order.orderNo),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.editOrder,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderEditScreen(existing: order),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.delete,
            onPressed: () async {
              final shopProvider = context.read<ShopProvider>();
              if (await confirmDelete(context, l10n.confirmDeleteOrder)) {
                await shopProvider.deleteOrder(order);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer?.name ?? l10n.unknownCustomer,
                      style: Theme.of(context).textTheme.titleMedium),
                  if (customer?.phone.isNotEmpty == true)
                    Text(customer!.phone,
                        style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StatusChip(status: order.status),
                      const SizedBox(width: 8),
                      PopupMenuButton<OrderStatus>(
                        tooltip: l10n.status,
                        icon: const Icon(Icons.edit, size: 18),
                        onSelected: (status) => context
                            .read<ShopProvider>()
                            .changeOrderStatus(order, status),
                        itemBuilder: (context) => [
                          for (final status in OrderStatus.values)
                            PopupMenuItem(
                              value: status,
                              child: Text(statusLabel(context, status)),
                            ),
                        ],
                      ),
                      if (fullyPaid) ...[
                        const SizedBox(width: 4),
                        _Pill(
                          label: l10n.fullyPaid,
                          background: Colors.green.shade100,
                          foreground: Colors.green.shade900,
                        ),
                      ],
                      if (isOverdue) ...[
                        const SizedBox(width: 4),
                        _Pill(
                          label: l10n.overdue,
                          background: Colors.red.shade100,
                          foreground: Colors.red.shade900,
                        ),
                      ],
                    ],
                  ),
                  if (next != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: FilledButton.tonalIcon(
                        onPressed: () => context
                            .read<ShopProvider>()
                            .changeOrderStatus(order, next),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(l10n.advanceNext(statusLabel(context, next))),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(categoryTitle,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.event, size: 18),
                      const SizedBox(width: 8),
                      Text(
                          '${l10n.deliveryDate}: ${displayDate(context, delivery)}'),
                    ],
                  ),
                  if (order.fabric.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.checkroom, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${l10n.fabric}: ${order.fabric}'),
                        ),
                      ],
                    ),
                  ],
                  // The photographed fabric sample chosen for this order.
                  if (shop.fabricSampleById(order.fabricSampleId)
                          ?.photoPath
                          .isNotEmpty ==
                      true) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: Image.file(
                          File(shop
                              .fabricSampleById(order.fabricSampleId)!
                              .photoPath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                  if (order.assignedTo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.engineering, size: 18),
                        const SizedBox(width: 8),
                        Text('${l10n.assignedTailor}: ${order.assignedTo}'),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n.orderDate}: ${displayDate(context, order.createdAt)}'
                        ' ${displayTime(context, order.createdAt)}',
                      ),
                    ],
                  ),
                  if (order.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(order.notes),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (items.isNotEmpty) ...[
            Text(l10n.orderItems,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final item in items) _itemCard(context, order, item, isAm),
          ],
          const SizedBox(height: 16),
          Text(l10n.payments, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _moneyRow(l10n.totalPrice,
                      '${money(order.totalPrice)} ${l10n.currencyBirr}'),
                  const SizedBox(height: 8),
                  _moneyRow(l10n.totalPaid,
                      '${money(paid)} ${l10n.currencyBirr}'),
                  const Divider(),
                  const SizedBox(height: 4),
                  _moneyRow(
                    l10n.balance,
                    '${money(balance < 0 ? 0 : balance)} ${l10n.currencyBirr}',
                    valueColor: fullyPaid ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (shop.paymentsFor(order.id).isEmpty)
            Text(l10n.noPayments)
          else
            for (final payment in shop.paymentsFor(order.id))
              Card(
                child: ListTile(
                  onTap: () => showPaymentEditor(context, order, payment: payment),
                  title: Text('${money(payment.amount)} ${l10n.currencyBirr}'),
                  subtitle: Text(
                    payment.note.isEmpty
                        ? displayDate(context, payment.paidAt)
                        : '${displayDate(context, payment.paidAt)} · ${payment.note}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.delete,
                    onPressed: () async {
                      final shopProvider = context.read<ShopProvider>();
                      if (await confirmDelete(context, l10n.areYouSure)) {
                        await shopProvider.deletePayment(payment);
                      }
                    },
                  ),
                ),
              ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => showPaymentEditor(context, order),
            icon: const Icon(Icons.payments),
            label: Text(l10n.addPayment),
          ),
          if (history.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(l10n.statusHistory,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final entry in history)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColors(entry.status).$1,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(statusLabel(context, entry.status)),
                subtitle: Text(
                  '${displayDate(context, entry.changedAt)} '
                  '${displayTime(context, entry.changedAt)}'
                  '${entry.note.isEmpty ? '' : ' · ${entry.note}'}',
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _itemCard(
      BuildContext context, ShopOrder order, OrderItem item, bool isAm) {
    final l10n = AppLocalizations.of(context)!;
    final def = garmentByKey(item.garmentKey);
    if (def == null) return const SizedBox.shrink();
    final summary = garmentValuesSummary(
        [...def.measurements, ...def.styles], item.measurement, isAm);

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.checkroom),
        title: Text(
            '${def.label(isAm)}${item.quantity > 1 ? '  ×${item.quantity}' : ''}'),
        subtitle: summary.isEmpty
            ? Text(l10n.noMeasurements)
            : Text(summary, maxLines: 1, overflow: TextOverflow.ellipsis),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (label, value) in garmentValuePairs(def, item.measurement, isAm))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label, style: Theme.of(context).textTheme.bodySmall),
                        Text(value,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                for (final (label, value) in garmentValuePairs(def, item.style, isAm))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label, style: Theme.of(context).textTheme.bodySmall),
                        Text(value,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                if (item.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(item.notes),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _editItem(context, item),
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.editMeasurements),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editItem(BuildContext context, OrderItem item) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.editMeasurements,
                    style: Theme.of(sheetContext).textTheme.titleLarge),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    GarmentMeasurementForm(
                      def: garmentByKey(item.garmentKey)!,
                      values: item.measurement,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        item.measurement
                            .removeWhere((_, v) => v.isEmpty);
                        item.style.removeWhere((_, v) => v.isEmpty);
                        final navigator = Navigator.of(sheetContext);
                        await sheetContext
                            .read<ShopProvider>()
                            .saveItem(item);
                        navigator.pop();
                      },
                      child: Text(l10n.save),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moneyRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w700, color: valueColor),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
