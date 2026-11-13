import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../data/garment_definitions.dart';
import '../models.dart';
import '../state/shop_provider.dart';
import '../util/date_display.dart';
import '../util/zizi_colors.dart';
import '../widgets/status_chip.dart';
import 'new_order_wizard.dart';
import 'order_detail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onGoToOrders});

  final VoidCallback? onGoToOrders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();

    final completedCount = shop.orders
        .where((o) =>
            o.status == OrderStatus.completed ||
            o.status == OrderStatus.delivered)
        .length;
    final recent = shop.orders.take(5).toList();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Hero header (purple gradient + gold brand + curved accent).
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ZiziColors.purpleDark, ZiziColors.purpleLight],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  bottom: -40,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: ZiziColors.gold.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 16 + MediaQuery.of(context).padding.top, 20, 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.welcome(shop.activeStaff?.name ?? ''),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications,
                                  color: ZiziColors.gold),
                              onPressed: () => _showNotifications(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Icon(Icons.checkroom,
                          color: ZiziColors.gold, size: 34),
                      const SizedBox(height: 4),
                      const Text(
                        'ZIZU FASHION',
                        style: TextStyle(
                          color: ZiziColors.gold,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.tagline,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Three stat cards.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.shopping_bag,
                    value: shop.orders.length.toString(),
                    label: l10n.statTotalOrders,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.people,
                    value: shop.customers.length.toString(),
                    label: l10n.statCustomers,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    value: completedCount.toString(),
                    label: l10n.statCompleted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _StatCard(
              icon: Icons.timelapse,
              value: shop.openOrderCount.toString(),
              label: l10n.statInProgress,
            ),
          ),
          const SizedBox(height: 16),
          // Gold New Order button.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: Material(
                color: ZiziColors.gold,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NewOrderWizard()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: ZiziColors.purpleDark),
                        const SizedBox(width: 8),
                        Text(
                          l10n.newOrder,
                          style: const TextStyle(
                            color: ZiziColors.purpleDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Recent orders.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(l10n.recentOrders,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                InkWell(
                  onTap: onGoToOrders,
                  child: Row(
                    children: [
                      Text(l10n.viewAll,
                          style: const TextStyle(
                              color: ZiziColors.purple,
                              fontWeight: FontWeight.w600)),
                      const Icon(Icons.arrow_forward,
                          size: 16, color: ZiziColors.purple),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.noOrders),
            )
          else
            for (final order in recent)
              _RecentOrderCard(order: order),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Notification bell: shows real overdue orders (nothing fake).
  void _showNotifications(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.read<ShopProvider>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final overdue = shop.orders
        .where((o) =>
            orderIsOpen(o.status) &&
            o.deliveryDate != null &&
            DateTime(o.deliveryDate!.year, o.deliveryDate!.month,
                    o.deliveryDate!.day)
                .isBefore(today))
        .toList();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.overdue),
        content: overdue.isEmpty
            ? Text(l10n.noResults)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final o in overdue.take(6))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.warning,
                          color: ZiziColors.warning),
                      title: Text(o.orderNo),
                      subtitle: Text(displayDate(context, o.deliveryDate)),
                    ),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
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
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800)),
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

class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard({required this.order});

  final ShopOrder order;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final isAm = Localizations.localeOf(context).languageCode == 'am';
    final images = shop.designImagesFor(order.id);
    final hasPhoto = images.isNotEmpty && File(images.first.path).existsSync();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Card(
        child: ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => OrderDetailScreen(orderId: order.id)),
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasPhoto
                ? Image.file(
                    File(images.first.path),
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _garmentIcon(),
                  )
                : _garmentIcon(),
          ),
          title: Text(
              order.orderNo.isEmpty ? order.id.substring(0, 8) : order.orderNo,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(
            '${categoryValueLabel(order.category, isAm, styleKey: order.style)}\n'
            '${displayDate(context, order.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          isThreeLine: true,
          trailing: StatusChip(status: order.status, dense: true),
        ),
      ),
    );
  }

  Widget _garmentIcon() => Container(
        width: 46,
        height: 46,
        color: const Color(0xFFE7DBF5),
        child: const Icon(Icons.checkroom, color: ZiziColors.purple),
      );
}
