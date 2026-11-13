import 'package:flutter/material.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';
import '../util/zizi_colors.dart';

/// Full-screen order confirmation (confetti + green check + gold Order ID
/// chip), matching the approved mockup.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderNo});

  final String orderNo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Decorative confetti dots.
    const confetti = [
      (0.12, 0.10, ZiziColors.gold, 14.0),
      (0.30, 0.06, Color(0xFF5B2A86), 10.0),
      (0.72, 0.08, Color(0xFF2FA36B), 12.0),
      (0.86, 0.16, Color(0xFFE4572E), 10.0),
      (0.10, 0.22, Color(0xFF2F80ED), 10.0),
      (0.90, 0.28, ZiziColors.gold, 14.0),
      (0.06, 0.36, Color(0xFFBB6BD9), 10.0),
      (0.93, 0.44, Color(0xFF2FA36B), 12.0),
      (0.14, 0.52, ZiziColors.gold, 10.0),
      (0.88, 0.62, Color(0xFF5B2A86), 10.0),
    ];

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
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration:
                      const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
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
                const SizedBox(height: 16),
                Text(l10n.thankYou),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.home),
                  label: Text(l10n.goHome),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
