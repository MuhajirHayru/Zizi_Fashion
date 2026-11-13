import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../data/garment_definitions.dart';
import '../data/order_filter.dart';
import '../data/report_service.dart';
import '../models.dart';
import '../state/shop_provider.dart';
import '../util/date_display.dart';
import '../util/format.dart';
import '../util/zizi_colors.dart';
import '../widgets/status_chip.dart';
import 'common.dart';
import 'new_order_wizard.dart';
import 'order_detail.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderFilter _filter = OrderFilter();

  /// Pagination: load the list in pages as the user scrolls.
  int _shown = 20;

  /// Quick tabs (spec section 4): all / recent / pending / in progress /
  /// completed / delivered, each with its own sorting rule.
  String _quickTab = 'all';

  static const Map<String, List<OrderStatus>> _tabStatuses = {
    'pending': [
      OrderStatus.newOrder,
      OrderStatus.measurementCompleted,
      OrderStatus.fabricPreparation,
    ],
    'progress': [
      OrderStatus.inProduction,
      OrderStatus.sewingInProgress,
      OrderStatus.readyForFitting,
      OrderStatus.modificationRequired,
    ],
    'completed': [OrderStatus.completed],
    'delivered': [OrderStatus.delivered],
  };

  List<ShopOrder> _tabList(List<ShopOrder> orders) {
    List<ShopOrder> list;
    if (_quickTab == 'all') {
      list = orders.where((o) => o.status != OrderStatus.cancelled).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // oldest first
    } else if (_quickTab == 'recent') {
      list = List.of(orders); // newest first (provider order)
    } else {
      final statuses = _tabStatuses[_quickTab]!;
      list = orders.where((o) => statuses.contains(o.status)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  Future<void> _openFilterSheet() async {
    final applied = await showOrderFilterSheet(context, _filter);
    if (applied) {
      setState(() => _shown = 20);
    }
  }

  Future<void> _export({required bool asPdf}) async {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.read<ShopProvider>();
    final filtered = _filter.apply(shop.orders, shop);
    try {
      final path = asPdf
          ? await ReportService.saveOrdersPdf(filtered, shop)
          : await ReportService.saveOrdersCsv(filtered, shop);
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(asPdf ? l10n.exportPdf : l10n.exportExcel),
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
      if (mounted) showSnack(context, l10n.exportFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();

    final list = _filter.apply(_tabList(shop.orders), shop);
    final shown = list.take(_shown).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabOrders),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: l10n.filters,
                onPressed: _openFilterSheet,
              ),
              if (_filter.isActive)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'csv') _export(asPdf: false);
              if (value == 'pdf') _export(asPdf: true);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'csv', child: Text(l10n.exportExcel)),
              PopupMenuItem(value: 'pdf', child: Text(l10n.exportPdf)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewOrderWizard()),
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.newOrder),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() {
                _filter.text = v;
                _shown = 20;
              }),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                for (final tab in [
                  ('all', l10n.allStatuses),
                  ('recent', l10n.sortNewest),
                  ('pending', l10n.statusPending),
                  ('progress', l10n.statInProgress),
                  ('completed', l10n.statusFinished),
                  ('delivered', l10n.statusCollected),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(tab.$2),
                      selected: _quickTab == tab.$1,
                      onSelected: (_) => setState(() {
                        _quickTab = tab.$1;
                        _shown = 20;
                      }),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                        _filter.isActive ? l10n.noResults : l10n.noOrders))
                : NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollEndNotification &&
                          notification.metrics.extentAfter < 200 &&
                          _shown < list.length) {
                        setState(() => _shown = _shown + 20);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount:
                          shown.length + (list.length > _shown ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= shown.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child:
                                Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _orderTile(context, shown[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _garmentIcon() => Container(
        width: 46,
        height: 46,
        color: const Color(0xFFE7DBF5),
        child: const Icon(Icons.checkroom, color: ZiziColors.purple),
      );

  Widget _orderTile(BuildContext context, ShopOrder order) {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();
    final customer = shop.customerById(order.customerId);
    final customerName = customer?.name ?? l10n.unknownCustomer;
    final customerPhone = customer?.phone ?? '';
    final balance = shop.balanceFor(order);
    final fullyPaid = order.totalPrice > 0 && balance <= 0;
    final isAm = Localizations.localeOf(context).languageCode == 'am';
    final categoryTitle =
        categoryValueLabel(order.category, isAm, styleKey: order.style);

    final images = shop.designImagesFor(order.id);
    final hasPhoto = images.isNotEmpty && File(images.first.path).existsSync();

    return Card(
      child: ListTile(
        isThreeLine: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
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
        title: Text('${order.orderNo.isEmpty ? '' : '${order.orderNo} · '}$categoryTitle'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customerName),
            if (customerPhone.isNotEmpty) Text(customerPhone),
            const SizedBox(height: 4),
            StatusChip(status: order.status, dense: true),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            fullyPaid
                ? const Icon(Icons.check_circle, color: Colors.green)
                : Text(
                    '${money(balance)} ${l10n.currencyBirr}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
            const SizedBox(height: 2),
            Text(
              displayDate(context, order.deliveryDate),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with the combined order filters (requirement section 7).
Future<bool> showOrderFilterSheet(
  BuildContext context,
  OrderFilter filter,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _OrderFilterForm(filter: filter),
  );
  return result ?? false;
}

class _OrderFilterForm extends StatefulWidget {
  const _OrderFilterForm({required this.filter});

  final OrderFilter filter;

  @override
  State<_OrderFilterForm> createState() => _OrderFilterFormState();
}

class _OrderFilterFormState extends State<_OrderFilterForm> {
  late final _text =
      TextEditingController(text: widget.filter.text);
  late final _tailor =
      TextEditingController(text: widget.filter.tailor);
  late final _fabric =
      TextEditingController(text: widget.filter.fabric);
  late final _color =
      TextEditingController(text: widget.filter.fabricColor);

  @override
  void dispose() {
    _text.dispose();
    _tailor.dispose();
    _fabric.dispose();
    _color.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isDelivery, bool isFrom) async {
    final current = isDelivery
        ? (isFrom ? widget.filter.deliveryFrom : widget.filter.deliveryTo)
        : (isFrom ? widget.filter.orderFrom : widget.filter.orderTo);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isDelivery) {
        if (isFrom) {
          widget.filter.deliveryFrom = picked;
        } else {
          widget.filter.deliveryTo = picked;
        }
      } else {
        if (isFrom) {
          widget.filter.orderFrom = picked;
        } else {
          widget.filter.orderTo = picked;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final f = widget.filter;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.filters,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  TextButton(
                    onPressed: () {
                      f.clear();
                      _text.clear();
                      _tailor.clear();
                      _fabric.clear();
                      _color.clear();
                      setState(() {});
                    },
                    child: Text(l10n.clear),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  TextFormField(
                    controller: _text,
                    decoration: InputDecoration(
                      labelText: '${l10n.searchHint} / ${l10n.orderId}',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => f.text = v,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<OrderStatus>(
                    value: f.status,
                    decoration: InputDecoration(
                      labelText: l10n.status,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      for (final status in OrderStatus.values)
                        DropdownMenuItem(
                          value: status,
                          child: Text(statusLabel(context, status)),
                        ),
                    ],
                    onChanged: (v) => setState(() => f.status = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: f.garmentKey.isEmpty ? null : f.garmentKey,
                    decoration: InputDecoration(
                      labelText: l10n.garment,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      for (final g in allGarments)
                        DropdownMenuItem(
                          value: g.key,
                          child: Text(g.label(Localizations.localeOf(context)
                                      .languageCode ==
                                  'am')),
                        ),
                    ],
                    onChanged: (v) => setState(() => f.garmentKey = v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tailor,
                    decoration: InputDecoration(
                      labelText: l10n.assignedTailor,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => f.tailor = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fabric,
                    decoration: InputDecoration(
                      labelText: l10n.fabric,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => f.fabric = v,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: f.gender.isEmpty ? null : f.gender,
                    decoration: InputDecoration(
                      labelText: l10n.fieldGender,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      for (final o in genderOptions)
                        DropdownMenuItem(
                          value: o.value,
                          child: Text(optionLabel(genderOptions, o.value,
                              Localizations.localeOf(context).languageCode ==
                                  'am')),
                        ),
                    ],
                    onChanged: (v) => setState(() => f.gender = v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: f.wear.isEmpty ? null : f.wear,
                    decoration: InputDecoration(
                      labelText: l10n.stepGarments,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: 'male', child: Text(l10n.maleWear)),
                      DropdownMenuItem(
                          value: 'female', child: Text(l10n.femaleWear)),
                    ],
                    onChanged: (v) => setState(() => f.wear = v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _color,
                    decoration: InputDecoration(
                      labelText: l10n.fabricColor,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => f.fabricColor = v,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.orderDate,
                      style: Theme.of(context).textTheme.titleSmall),
                  _dateRow(context, l10n.orderDate, isDelivery: false),
                  const SizedBox(height: 8),
                  Text(l10n.deliveryDate,
                      style: Theme.of(context).textTheme.titleSmall),
                  _dateRow(context, l10n.deliveryDate, isDelivery: true),
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
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.apply),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateRow(BuildContext context, String label,
      {required bool isDelivery}) {
    final l10n = AppLocalizations.of(context)!;
    final f = widget.filter;
    final from = isDelivery ? f.deliveryFrom : f.orderFrom;
    final to = isDelivery ? f.deliveryTo : f.orderTo;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDate(isDelivery, true),
            child: Text(
              '${l10n.from}: ${from == null ? '—' : displayDate(context, from)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDate(isDelivery, false),
            child: Text(
              '${l10n.to}: ${to == null ? '—' : displayDate(context, to)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
