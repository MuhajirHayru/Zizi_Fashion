import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../data/garment_definitions.dart';
import '../data/order_filter.dart';
import '../data/report_service.dart';
import '../state/shop_provider.dart';
import 'common.dart';
import 'customer_detail.dart';
import 'customer_edit.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerFilter _filter = CustomerFilter();

  /// Pagination: load the list in pages as the user scrolls.
  int _shown = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();
    _filter.text = _query;
    final list = _filter.apply(shop.customers);
    final shown = list.take(_shown).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabCustomers),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.exportExcel,
            onPressed: () async {
              try {
                final path = await ReportService.saveCustomersCsv(list, shop);
                if (context.mounted) {
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n.exportExcel),
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
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.filters,
            onPressed: () async {
              final applied = await _showCustomerFilterSheet();
              if (applied) setState(() => _shown = 20);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCustomerEditor(context),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.newCustomer),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              onChanged: (value) =>
                  setState(() { _query = value; _shown = 20; }),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(_filter.isActive || _query.isNotEmpty
                        ? l10n.noResults
                        : l10n.noCustomers))
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
                        final customer = shown[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(customer.name.isEmpty
                                ? '?'
                                : customer.name.substring(0, 1)),
                          ),
                          title: Text(customer.name),
                          subtitle: customer.phone.isEmpty
                              ? null
                              : Text(customer.phone),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerDetailScreen(
                                  customerId: customer.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _query = '';

  Future<bool> _showCustomerFilterSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final isAm = Localizations.localeOf(context).languageCode == 'am';
    final result = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.filters, style: Theme.of(sheetContext).textTheme.titleLarge),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _filter.gender.isEmpty ? null : _filter.gender,
              decoration: InputDecoration(
                labelText: l10n.fieldGender,
                prefixIcon: const Icon(Icons.people),
              ),
              items: [
                for (final o in genderOptions)
                  DropdownMenuItem(value: o.value, child: Text(isAm ? o.am : o.en)),
              ],
              onChanged: (v) => setState(() => _filter.gender = v ?? ''),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _filter.clear();
                    _query = '';
                    setState(() {});
                    Navigator.pop(sheetContext, true);
                  },
                  child: Text(l10n.clear),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  child: Text(l10n.apply),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(sheetContext).padding.bottom),
          ],
        ),
      ),
    );
    return result ?? false;
  }
}
