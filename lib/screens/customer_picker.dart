import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../models.dart';
import '../state/shop_provider.dart';

/// Searchable customer list that pops with the chosen [Customer].
class CustomerPickerScreen extends StatefulWidget {
  const CustomerPickerScreen({super.key});

  @override
  State<CustomerPickerScreen> createState() => _CustomerPickerScreenState();
}

class _CustomerPickerScreenState extends State<CustomerPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();

    final q = _query.trim().toLowerCase();
    final list = shop.customers
        .where((c) =>
            q.isEmpty ||
            c.name.toLowerCase().contains(q) ||
            c.phone.contains(q))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pickCustomer)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text(l10n.noCustomers))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final customer = list[index];
                      return ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(customer.name),
                        subtitle:
                            customer.phone.isEmpty ? null : Text(customer.phone),
                        onTap: () => Navigator.pop(context, customer),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
