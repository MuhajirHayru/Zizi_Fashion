import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../data/report_service.dart';
import '../models.dart';
import '../state/shop_provider.dart';
import '../util/format.dart';
import '../util/zizi_colors.dart';
import 'common.dart';

/// Reports hub: live shop statistics plus Excel/PDF/backup exports.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();

    final completed = shop.orders
        .where((o) =>
            o.status == OrderStatus.completed ||
            o.status == OrderStatus.delivered)
        .length;
    final inProgress =
        shop.orders.where((o) => orderIsOpen(o.status)).length;
    final totalPaid =
        shop.payments.fold<double>(0, (sum, p) => sum + p.amount);

    Future<void> export(Future<String> Function() task, String title) async {
      try {
        final path = await task();
        if (context.mounted) {
          showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(title),
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
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabReports)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                  child: _stat(context, Icons.shopping_bag,
                      shop.orders.length.toString(), l10n.statTotalOrders)),
              const SizedBox(width: 10),
              Expanded(
                  child: _stat(context, Icons.people,
                      shop.customers.length.toString(), l10n.statCustomers)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _stat(context, Icons.check_circle,
                      completed.toString(), l10n.statCompleted)),
              const SizedBox(width: 10),
              Expanded(
                  child: _stat(context, Icons.timelapse, inProgress.toString(),
                      l10n.statInProgress)),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet,
                  color: ZiziColors.gold),
              title: Text(l10n.totalPaid),
              subtitle: Text(
                  '${money(shop.totalOwed)} ${l10n.currencyBirr} ${l10n.balance.toLowerCase()}'),
              trailing: Text(
                '${money(totalPaid)} ${l10n.currencyBirr}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: ZiziColors.success),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.exportData,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: Text(l10n.exportExcel),
                  subtitle: Text(l10n.tabOrders),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => export(
                      () => ReportService.saveOrdersCsv(shop.orders, shop),
                      l10n.exportExcel),
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(l10n.exportPdf),
                  subtitle: Text(l10n.tabOrders),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => export(
                      () => ReportService.saveOrdersPdf(shop.orders, shop),
                      l10n.exportPdf),
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: Text(l10n.exportExcel),
                  subtitle: Text(l10n.tabCustomers),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => export(
                      () => ReportService.saveCustomersCsv(
                          shop.customers, shop),
                      l10n.exportExcel),
                ),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: Text(l10n.exportData),
                  subtitle: Text(l10n.dataStoredLocally),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => export(() => shop.exportBackup(),
                      l10n.exportData),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(
      BuildContext context, IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZiziColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: ZiziColors.purple, size: 26),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
