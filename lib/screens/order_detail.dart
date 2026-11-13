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
import '../data/report_service.dart';
import '../util/zizi_colors.dart';
import 'common.dart';
import 'order_edit.dart';
import 'payment_edit.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 6, vsync: this);

  String get orderId => widget.orderId;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    final totalQuantity =
        items.fold<int>(0, (sum, i) => sum + i.quantity);
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
      body: Column(
        children: [
          Container(
            color: ZiziColors.purple,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: ZiziColors.gold,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: l10n.stepCustomer),
                Tab(text: l10n.stepGarments),
                Tab(text: l10n.stepMeasurements),
                Tab(text: l10n.designReference),
                Tab(text: l10n.statusTimeline),
                Tab(text: l10n.statusHistory),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [          Card(
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
                  if (order.fabricColor.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.palette, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              Text('${l10n.fabricColor}: ${order.fabricColor}'),
                        ),
                      ],
                    ),
                  ],
                  if (order.fabricPattern.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.texture, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                              '${l10n.fabricPattern}: ${order.fabricPattern}'),
                        ),
                      ],
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
          // Customer information (mockup style).
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.customerInfo,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  _iconRow(context, Icons.person,
                      customer?.name ?? l10n.unknownCustomer),
                  if (customer?.phone.isNotEmpty == true)
                    _iconRow(context, Icons.phone, customer!.phone),
                  if (customer?.address.isNotEmpty == true)
                    _iconRow(context, Icons.place, customer!.address),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Order summary (mockup style).
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.orderSummary,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7DBF5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.checkroom,
                            color: ZiziColors.purple),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(categoryTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      Text('${l10n.quantity}: $totalQuantity',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  if (order.fabric.isNotEmpty)
                    _iconRow(context, Icons.checkroom,
                        '${l10n.fabric}: ${order.fabric}'),
                  if (order.fabricColor.isNotEmpty)
                    _iconRow(context, Icons.palette,
                        '${l10n.fabricColor}: ${order.fabricColor}'),
                  if (order.fabricPattern.isNotEmpty)
                    _iconRow(context, Icons.texture,
                        '${l10n.fabricPattern}: ${order.fabricPattern}'),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () =>
                            _openMeasurementsSheet(context, items, isAm, l10n),
                        icon: const Icon(Icons.straighten),
                        label: Text(l10n.viewMeasurements),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
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
],
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
            Text(l10n.orderItems,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final item in items) _itemCard(context, order, item, isAm),
          ],
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ..._measurementsList(context, items, isAm),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
          const SizedBox(height: 16),
          Text(l10n.designReference,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._designGallery(context, shop, order, isAm, l10n),
],
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [          const SizedBox(height: 12),
          // Order status timeline (mockup style).
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.statusTimeline,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ..._timeline(context, history, l10n),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Update status + Print buttons (mockup style).
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      _showStatusSheet(context, shop, order, l10n),
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.updateStatus),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: customer == null
                      ? null
                      : () => ReportService.printMeasurementSheet(
                          customer, shop, isAm),
                  icon: const Icon(Icons.print),
                  label: Text(l10n.printSheet),
                ),
              ),
            ],
          ),
],
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ..._historyTiles(context, history, isAm, l10n),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ZiziColors.purple),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  List<Widget> _timeline(BuildContext context,
      List<StatusHistoryEntry> history, AppLocalizations l10n) {
    final entries = [...history]..sort((a, b) => a.changedAt.compareTo(b.changedAt));
    if (entries.isEmpty) {
      return [Text(l10n.noResults)];
    }
    final widgets = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final isLast = i == entries.length - 1;
      widgets.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isLast ? ZiziColors.purple : Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLast ? Icons.trip_origin : Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 28,
                  color: ZiziColors.cardBorder,
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statusLabel(context, entries[i].status),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '\${displayDate(context, entries[i].changedAt)} '
                    '\${displayTime(context, entries[i].changedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ));
    }
    return widgets;
  }

  Future<void> _showStatusSheet(
      BuildContext context, ShopProvider shop, ShopOrder order,
      AppLocalizations l10n) async {
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.updateStatus,
                  style: Theme.of(sheetContext).textTheme.titleLarge),
            ),
            for (final status in OrderStatus.values)
              ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColors(status).$1,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(statusLabel(sheetContext, status)),
                trailing: order.status == status
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  final navigator = Navigator.of(sheetContext);
                  shop.changeOrderStatus(order, status);
                  navigator.pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _openMeasurementsSheet(BuildContext context, List<OrderItem> items,
      bool isAm, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.of(sheetContext).size.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.measurements,
                  style: Theme.of(sheetContext).textTheme.titleLarge),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final item in items)
                    ...[
                      Text(
                        '${garmentByKey(item.garmentKey)?.label(isAm) ?? item.garmentKey}'
                        '${item.quantity > 1 ? '  x${item.quantity}' : ''}',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      for (final (label, value) in garmentValuePairs(
                          garmentByKey(item.garmentKey) ?? allGarments.first,
                          item.measurement,
                          isAm))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(label,
                                  style: Theme.of(sheetContext)
                                      .textTheme
                                      .bodySmall),
                              Text(value,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _measurementsList(
      BuildContext context, List<OrderItem> items, bool isAm) {
    return [
      for (final item in items) ...[
        Text(
          '${garmentByKey(item.garmentKey)?.label(isAm) ?? item.garmentKey}'
          '${item.quantity > 1 ? '  x${item.quantity}' : ''}',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        for (final (label, value) in garmentValuePairs(
            garmentByKey(item.garmentKey) ?? allGarments.first,
            item.measurement,
            isAm))
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        if (garmentValuePairs(
                garmentByKey(item.garmentKey) ?? allGarments.first,
                item.style,
                isAm)
            .isNotEmpty) ...[
          const SizedBox(height: 4),
          for (final (label, value) in garmentValuePairs(
              garmentByKey(item.garmentKey) ?? allGarments.first,
              item.style,
              isAm))
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  Text(value,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
        const SizedBox(height: 16),
      ],
    ];
  }

  List<Widget> _historyTiles(BuildContext context,
      List<StatusHistoryEntry> history, bool isAm, AppLocalizations l10n) {
    final entries = [...history]
      ..sort((a, b) => b.changedAt.compareTo(a.changedAt));
    if (entries.isEmpty) {
      return [Text(l10n.noResults)];
    }
    return [
      for (final entry in entries)
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
            '${entry.note.isEmpty ? '' : ' - ${entry.note}'}',
          ),
        ),
    ];
  }

  /// Design reference photos grouped by garment design type, with the
  /// ability to remove a wrongly-captured image.
  List<Widget> _designGallery(BuildContext context, ShopProvider shop,
      ShopOrder order, bool isAm, AppLocalizations l10n) {
    final images = shop.designImagesFor(order.id);
    if (images.isEmpty) {
      return [Text(l10n.noSamples)];
    }
    final groups = <String>[];
    for (final img in images) {
      if (!groups.contains(img.groupKey)) groups.add(img.groupKey);
    }
    final widgets = <Widget>[];
    for (final group in groups) {
      final groupImages =
          images.where((img) => img.groupKey == group).toList();
      widgets.add(Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(designGroupLabel(group, isAm),
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: groupImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final image = groupImages[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(image.path),
                            width: 110,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox(
                              width: 110,
                              height: 90,
                              child: Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: Text(
                            image.description.isEmpty
                                ? '—'
                                : image.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final shopProvider = context.read<ShopProvider>();
                            if (await confirmDelete(
                                context, l10n.areYouSure)) {
                              await shopProvider.deleteOrderImage(image);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 14,
                                  color:
                                      Theme.of(context).colorScheme.error),
                              const SizedBox(width: 4),
                              Text(l10n.removeImage,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ));
    }
    return widgets;
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
