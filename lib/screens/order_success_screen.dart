import 'package:flutter/material.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';
import '../util/ethiopian_calendar.dart' show todayInAddis;
import '../util/zizi_colors.dart';

import 'new_order_wizard.dart';
import 'order_detail.dart';

/// Full-screen order confirmation (confetti + green check + gold Order ID
/// chip + customer name + View Order / New Order buttons), matching the
/// approved ZIZU FASHION mockup.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
    required this.orderNo,
    required this.orderId,
    required this.customerName,
  });

  final String orderNo;
  final String orderId;
  final String customerName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Decorative confetti dots.
    const confetti = [
      (0.12, 0.10, ZiziColors.gold, 14.0),
      (0.30, 0.06, Color(0xFF6B278A), 10.0),
      (0.72, 0.08, Color(0xFF218B55), 12.0),
      (0.86, 0.16, Color(0xFFD64A4A), 10.0),
      (0.10, 0.22, Color(0xFF2F80ED), 10.0),
      (0.90, 0.28, ZiziColors.gold, 14.0),
      (0.06, 0.36, Color(0xFFBB6BD9), 10.0),
      (0.93, 0.44, Color(0xFF218B55), 12.0),
      (0.14, 0.52, ZiziColors.gold, 10.0),
      (0.88, 0.62, Color(0xFF6B278A), 10.0),
    ];
    final n = todayInAddis();
    final registered =
        '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: ZiziColors.cream,
      body: Stack(
        children: [
          for (final (dx, dy, color, size) in confetti)
            Positioned(
              left: MediaQuery.of(context).size.width * dx,
              top: MediaQuery.of(context).size.height * dy,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                      color: ZiziColors.success, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 56),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.orderSuccessTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ZiziColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.orderId, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    color: ZiziColors.gold,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    orderNo,
                    style: const TextStyle(
                      color: ZiziColors.purpleDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(customerName,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(registered,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Text(l10n.thankYou),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: orderId),
                    ),
                  ),
                  icon: const Icon(Icons.visibility),
                  label: Text(l10n.viewOrder),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const NewOrderWizard()),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.newOrder),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
