import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../data/garment_definitions.dart';
import '../data/report_service.dart';
import '../util/zizi_colors.dart';
import '../models.dart';
import '../state/shop_provider.dart';
import '../util/date_display.dart';
import '../util/format.dart';
import '../widgets/garment_form.dart';
import '../widgets/measurement_labels.dart';
import 'common.dart';
import 'customer_edit.dart';
import 'measurement_edit.dart';
import 'new_order_wizard.dart';
import 'order_detail.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();
    final customer = shop.customerById(customerId);
    if (customer == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.unknownCustomer)),
      );
    }

    final measurements = shop.measurementsFor(customerId);
    // Profile shows the order history oldest first (mockup).
    final orders = shop.ordersFor(customerId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final isAm = Localizations.localeOf(context).languageCode == 'am';

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: l10n.printSheet,
            onPressed: () async {
              try {
                final path = await ReportService.saveMeasurementSheet(
                    customer, shop, isAm);
                if (context.mounted) {
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n.printSheet),
                      content: SelectableText(l10n.savedPath(path)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(l10n.save),
                        ),
                      ],
                    ),
                  );
                }
              } catch (_) {
                if (context.mounted) showSnack(context, l10n.exportFailed);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.note_add),
            tooltip: l10n.newOrder,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewOrderWizard(existingCustomer: customer),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.edit,
            onPressed: () => showCustomerEditor(context, customer: customer),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.delete,
            onPressed: () async {
              final shopProvider = context.read<ShopProvider>();
              if (await confirmDelete(context, l10n.confirmDeleteCustomer)) {
                await shopProvider.deleteCustomer(customer);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header (mockup style).
          Column(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFE7DBF5),
                child: Icon(Icons.person, size: 40, color: ZiziColors.purple),
              ),
              const SizedBox(height: 8),
              Text(customer.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              if (customer.phone.isNotEmpty)
                Text(customer.phone,
                    style: Theme.of(context).textTheme.bodySmall),
              if (customer.address.isNotEmpty)
                Text(customer.address,
                    style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          if (customer.altPhone.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone),
              title: Text(customer.phone),
            ),
          if (customer.altPhone.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone_android),
              title: Text(customer.altPhone),
            ),
          if (customer.gender.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: Text(optionLabel(genderOptions, customer.gender, isAm)),
            ),
          if (customer.region.isNotEmpty ||
              customer.city.isNotEmpty ||
              customer.subCity.isNotEmpty ||
              customer.kebele.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place),
              title: Text([
                regionLabel(customer.region, isAm),
                customer.city,
                customer.subCity,
                customer.kebele,
              ].where((part) => part.isNotEmpty).join(' · ')),
            ),
          if (customer.customerType.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.loyalty),
              title: Text(optionLabel(customerTypeOptions, customer.customerType, isAm)),
            ),
          if (customer.notes.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notes),
              title: Text(customer.notes),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_available),
            title: Text(
                '${l10n.regDate}: ${displayDate(context, customer.createdAt)}'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(l10n.measurements,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: l10n.addMeasurement,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MeasurementEditScreen(customerId: customerId),
                  ),
                ),
              ),
            ],
          ),
          if (measurements.isEmpty)
            Text(l10n.noMeasurements)
          else
            for (final m in measurements)
              Card(
                child: ListTile(
                  onTap: m.category == 'general'
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MeasurementEditScreen(
                              customerId: customerId,
                              existing: m,
                            ),
                          ),
                        )
                      : null,
                  title: _measurementTitle(context, m),
                  subtitle: _measurementSummary(context, m),
                ),
              ),
          const SizedBox(height: 16),
          Text(l10n.orders, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          if (orders.isEmpty)
            Text(l10n.noOrders)
          else
            for (final order in orders)
              Card(
                child: ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: order.id),
                    ),
                  ),
                  title: Text(
                      '${order.orderNo.isEmpty ? '' : '${order.orderNo} · '}'
                      '${categoryValueLabel(order.category, isAm, styleKey: order.style)}'),
                  subtitle: Text(
                      '${l10n.deliveryDate}: ${displayDate(context, order.deliveryDate)}'),
                  trailing: order.totalPrice > 0 && shop.balanceFor(order) <= 0
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : Text(
                          '${money(shop.balanceFor(order))} ${l10n.currencyBirr}',
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _measurementTitle(BuildContext context, Measurement m) {
    final isAm = Localizations.localeOf(context).languageCode == 'am';
    final def = garmentByKey(m.category);
    final label = def == null
        ? (isAm ? 'ጠቅላላ' : 'General')
        : def.label(isAm);
    return Text('$label — ${displayDate(context, m.dateTaken)}');
  }

  Widget? _measurementSummary(BuildContext context, Measurement m) {
    final l10n = AppLocalizations.of(context)!;
    final isAm = Localizations.localeOf(context).languageCode == 'am';
    final def = garmentByKey(m.category);
    if (def != null) {
      final summary =
          garmentValuesSummary(def.measurements, m.fields, isAm);
      return summary.isEmpty ? null : Text(summary);
    }
    final parts = <String>[];
    for (final entry in measurementFields.entries) {
      final value = m.getField(entry.key);
      if (value != null) {
        parts.add('${entry.value(l10n)} ${numStr(value)}');
      }
      if (parts.length == 4) break;
    }
    if (parts.isEmpty) {
      return m.notes.isEmpty ? null : Text(m.notes);
    }
    return Text(parts.join(' · '));
  }
}
