import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../state/settings_provider.dart';

/// Bilingual labels for the full 10-step order pipeline.
String statusLabel(BuildContext context, OrderStatus status) {
  final isAm =
      context.read<SettingsProvider>().locale.languageCode == 'am';
  return switch (status) {
    OrderStatus.newOrder => isAm ? 'አዲስ ትእዛዝ' : 'New order',
    OrderStatus.measurementCompleted =>
      isAm ? 'መጠን ተመዝግቧል' : 'Measurement completed',
    OrderStatus.fabricPreparation => isAm ? 'ጨርቅ ዝግጅት' : 'Fabric preparation',
    OrderStatus.inProduction => isAm ? 'በሥራ ላይ' : 'In production',
    OrderStatus.sewingInProgress => isAm ? 'በስፌት ላይ' : 'Sewing in progress',
    OrderStatus.readyForFitting => isAm ? 'ለፊቲንግ ዝግጁ' : 'Ready for fitting',
    OrderStatus.modificationRequired =>
      isAm ? 'ማስተካከያ ያስፈልጋል' : 'Modification required',
    OrderStatus.completed => isAm ? 'ተጠናቋል' : 'Completed',
    OrderStatus.delivered => isAm ? 'ደርሷል' : 'Delivered',
    OrderStatus.cancelled => isAm ? 'ተሰርዟል' : 'Cancelled',
  };
}

/// English label independent of the app locale (PDF / CSV reports).
String statusLabelEn(OrderStatus status) => switch (status) {
      OrderStatus.newOrder => 'New order',
      OrderStatus.measurementCompleted => 'Measurement completed',
      OrderStatus.fabricPreparation => 'Fabric preparation',
      OrderStatus.inProduction => 'In production',
      OrderStatus.sewingInProgress => 'Sewing in progress',
      OrderStatus.readyForFitting => 'Ready for fitting',
      OrderStatus.modificationRequired => 'Modification required',
      OrderStatus.completed => 'Completed',
      OrderStatus.delivered => 'Delivered',
      OrderStatus.cancelled => 'Cancelled',
    };

(Color, Color) statusColors(OrderStatus status) => switch (status) {
      OrderStatus.newOrder => (Colors.blueGrey.shade100, Colors.blueGrey.shade800),
      OrderStatus.measurementCompleted => (Colors.indigo.shade100, Colors.indigo.shade800),
      OrderStatus.fabricPreparation => (Colors.deepPurple.shade100, Colors.deepPurple.shade800),
      OrderStatus.inProduction => (Colors.amber.shade100, Colors.amber.shade900),
      OrderStatus.sewingInProgress => (Colors.orange.shade100, Colors.orange.shade900),
      OrderStatus.readyForFitting => (Colors.blue.shade100, Colors.blue.shade800),
      OrderStatus.modificationRequired => (Colors.red.shade100, Colors.red.shade900),
      OrderStatus.completed => (Colors.green.shade100, Colors.green.shade900),
      OrderStatus.delivered => (Colors.teal.shade100, Colors.teal.shade900),
      OrderStatus.cancelled => (Colors.grey.shade300, Colors.grey.shade800),
    };

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.dense = false});

  final OrderStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = statusColors(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statusLabel(context, status),
        style: TextStyle(
          color: foreground,
          fontSize: dense ? 11 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
