import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../data/garment_definitions.dart';
import '../models.dart';
import '../state/shop_provider.dart';
import '../util/date_display.dart';
import '../util/format.dart';
import 'order_detail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));

    final overdue = <ShopOrder>[];
    final dueSoon = <ShopOrder>[];
    for (final order in shop.orders) {
      if (!orderIsOpen(order.status)) continue;
      final d = order.deliveryDate;
      if (d == null) continue;
      final day = DateTime(d.year, d.month, d.day);
      if (day.isBefore(today)) {
        overdue.add(order);
      } else if (day.isBefore(weekEnd)) {
        dueSoon.add(order);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.checkroom,
                  value: shop.openOrderCount.toString(),
                  label: l10n.openOrders,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet,
                  value: '${money(shop.totalOwed)} ${l10n.currencyBirr}',
                  label: l10n.totalOwed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (overdue.isNotEmpty) ...[
            Text(l10n.overdue, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            for (final order in overdue) _OrderRow(order: order, overdue: true),
            const SizedBox(height: 16),
          ],
          Text(l10n.dueThisWeek, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          if (dueSoon.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.noOrders),
              ),
            )
          else
            for (final order in dueSoon) _OrderRow(order: order),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: colors.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, this.overdue = false});

  final ShopOrder order;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();
    final customerName =
        shop.customerById(order.customerId)?.name ?? l10n.unknownCustomer;
    final isAm = Localizations.localeOf(context).languageCode == 'am';
    final categoryTitle =
        categoryValueLabel(order.category, isAm, styleKey: order.style);

    return Card(
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
        ),
        title: Text(
            '${order.orderNo.isEmpty ? '' : '${order.orderNo} · '}$categoryTitle'),
        subtitle: Text(customerName),
        trailing: Text(
          displayDate(context, order.deliveryDate),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: overdue ? Theme.of(context).colorScheme.error : null,
          ),
        ),
      ),
    );
  }
}
