import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../data/garment_definitions.dart';
import '../models.dart';
import '../state/settings_provider.dart';
import '../state/shop_provider.dart';
import '../util/date_display.dart';
import '../util/ethiopian_calendar.dart';
import '../util/format.dart';
import '../widgets/garment_form.dart';
import 'common.dart';

class _WizardItem {
  _WizardItem(this.def, this.quantity);
  GarmentDef def;
  int quantity;
  Map<String, String> measurement = {};
  Map<String, String> style = {};
  String measurementId = '';
  String notes = '';
}

/// ZIZI FASHION new-order flow:
/// 1. phone number first (finds returning customers)
/// 2. full customer profile
/// 3. garment selection (Male Graduation Wear)
/// 4. garment-specific measurements + style selections
/// 5. fabric & design details
/// 6. delivery, price, tailor — with automatic registration info.
class NewOrderWizard extends StatefulWidget {
  const NewOrderWizard({super.key, this.existingCustomer});

  final Customer? existingCustomer;

  @override
  State<NewOrderWizard> createState() => _NewOrderWizardState();
}

class _NewOrderWizardState extends State<NewOrderWizard> {
  int _step = 0;

  final _phone = TextEditingController();
  final _name = TextEditingController();
  final _altPhone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _subCity = TextEditingController();
  final _kebele = TextEditingController();
  final _customerNotes = TextEditingController();
  final _fabric = TextEditingController();
  final _fabricColor = TextEditingController();
  final _fabricPattern = TextEditingController();
  final _accessories = TextEditingController();
  final _instructions = TextEditingController();
  final _total = TextEditingController();
  final _deposit = TextEditingController();

  String _gender = '';
  String _region = '';
  String _customerType = '';
  Customer? _found;
  String? _orderNoPreview;
  DateTime? _delivery;
  String _assignedTo = '';
  String _fabricSampleId = '';
  String _categoryKey = 'suits'; // Suits is the shop's primary work
  final List<_WizardItem> _items = [];

  final DateTime _registeredAt = nowInAddis();

  @override
  void initState() {
    super.initState();
    final prefill = widget.existingCustomer;
    if (prefill != null) {
      _found = prefill;
      _fillFromCustomer(prefill);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final no =
          await context.read<ShopProvider>().nextOrderNumber();
      if (mounted) setState(() => _orderNoPreview = no);
    });
  }

  void _fillFromCustomer(Customer c) {
    _phone.text = c.phone;
    _name.text = c.name;
    _altPhone.text = c.altPhone;
    _address.text = c.address;
    _city.text = c.city;
    _subCity.text = c.subCity;
    _kebele.text = c.kebele;
    _customerNotes.text = c.notes;
    _gender = c.gender;
    _region = c.region;
    _customerType =
        c.customerType.isEmpty ? 'returning' : c.customerType;
  }

  @override
  void dispose() {
    for (final c in [
      _phone, _name, _altPhone, _address, _city, _subCity, _kebele,
      _customerNotes, _fabric, _fabricColor, _fabricPattern, _accessories,
      _instructions, _total, _deposit,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isAm =>
      context.read<SettingsProvider>().locale.languageCode == 'am';

  Future<bool> _validateStep(int step) async {
    final l10n = AppLocalizations.of(context)!;
    switch (step) {
      case 0:
        if (_phone.text.trim().isEmpty || _name.text.trim().isEmpty) {
          showSnack(context, l10n.requiredFields);
          return false;
        }
        return true;
      case 1:
        if (_items.isEmpty) {
          showSnack(context, l10n.noGarments);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final total = parseAmount(_total.text);
    if (total == null || total < 0) {
      showSnack(context, l10n.enterValidAmount);
      return;
    }
    final shop = context.read<ShopProvider>();
    final staffMember = shop.activeStaff;
    final registeredBy = _assignedTo.isNotEmpty
        ? _assignedTo
        : (staffMember?.name ?? '');

    final customer = Customer.create(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      notes: _customerNotes.text.trim(),
      gender: _gender,
      altPhone: _altPhone.text.trim(),
      address: _address.text.trim(),
      region: _region,
      city: _city.text.trim(),
      subCity: _subCity.text.trim(),
      kebele: _kebele.text.trim(),
      customerType: _customerType.isEmpty
          ? (_found == null ? 'new' : 'returning')
          : _customerType,
      registeredBy: registeredBy,
    );

    final order = ShopOrder.create(
      customerId: _found?.id ?? '',
      style: 'graduation',
      totalPrice: total,
      fabric: _fabric.text.trim(),
      deliveryDate: _delivery,
      notes: _instructions.text.trim(),
      orderNo: _orderNoPreview ?? '',
      category: _categoryKey,
      assignedTo: registeredBy,
      fabricSampleId: _fabricSampleId,
    );

    final items = [
      for (final item in _items)
        OrderItem.create(
          orderId: '',
          garmentKey: item.def.key,
          quantity: item.quantity,
          measurement: Map.of(item.measurement)
            ..removeWhere((_, v) => v.isEmpty),
          style: Map.of(item.style)..removeWhere((_, v) => v.isEmpty),
          measurementId: item.measurementId,
          notes: item.notes,
        ),
    ];

    final deposit = parseAmount(_deposit.text);
    final saved = await shop.saveNewOrder(
      customer: customer,
      order: order,
      items: items,
      deposit: (deposit != null && deposit > 0) ? deposit : null,
      depositNote: l10n.deposit,
    );

    if (!mounted) return;
    showSnack(
        context,
        '${saved.orderNo} — ${l10n.save}');
    Navigator.of(context).pop(saved);
  }

  // ---------- step widgets ----------

  Widget _autoInfoCard() {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.read<ShopProvider>();
    final staffName = shop.activeStaff?.name ?? '';
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 16,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 6),
                Text(l10n.autoInfo,
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow('${l10n.regDate}:', displayDate(context, _registeredAt)),
            _infoRow('${l10n.regTime}:', displayTime(context, _registeredAt)),
            _infoRow(l10n.customerId, _found?.id ?? '—'),
            _infoRow(l10n.orderId, _orderNoPreview ?? '—'),
            _infoRow(l10n.staff, staffName),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _customerStep() {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();
    final query = _phone.text.trim();
    final matches = query.isEmpty
        ? const <Customer>[]
        : shop.customers
            .where((c) => c.phone.replaceAll(RegExp(r'\D'), '').contains(
                query.replaceAll(RegExp(r'\D'), '')))
            .toList();

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        TextFormField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.fieldPhone,
            helperText: l10n.searchPhoneHint,
            prefixIcon: const Icon(Icons.phone),
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (matches.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final match in matches.take(3))
            Card(
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.person_search),
                title: Text(match.name),
                subtitle: Text(match.phone),
                trailing: Text(l10n.customerFound,
                    style: Theme.of(context).textTheme.labelSmall),
                onTap: () {
                  setState(() {
                    _found = match;
                    _fillFromCustomer(match);
                  });
                },
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _found = null;
                  }),
                  child: Text(l10n.registerNew),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _found == null
                      ? null
                      : () => setState(() {
                            _fillFromCustomer(_found!);
                          }),
                  child: Text(l10n.useExistingProfile),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        TextFormField(
          controller: _name,
          decoration: InputDecoration(
            labelText: l10n.fieldName,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _gender.isEmpty ? null : _gender,
          decoration: InputDecoration(
            labelText: l10n.fieldGender,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final o in genderOptions)
              DropdownMenuItem(value: o.value, child: Text(_isAm ? o.am : o.en)),
          ],
          onChanged: (v) => setState(() => _gender = v ?? ''),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _altPhone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.fieldAltPhone,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _address,
          decoration: InputDecoration(
            labelText: l10n.fieldAddress,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _region.isEmpty ? null : _region,
          decoration: InputDecoration(
            labelText: l10n.fieldRegion,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final o in ethiopianRegions)
              DropdownMenuItem(value: o.value, child: Text(_isAm ? o.am : o.en)),
          ],
          onChanged: (v) => setState(() => _region = v ?? ''),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _city,
          decoration: InputDecoration(
            labelText: l10n.fieldCity,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _subCity,
          decoration: InputDecoration(
            labelText: l10n.fieldSubCity,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _kebele,
          decoration: InputDecoration(
            labelText: l10n.fieldKebele,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _customerType.isEmpty ? null : _customerType,
          decoration: InputDecoration(
            labelText: l10n.fieldCustomerType,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final o in customerTypeOptions)
              DropdownMenuItem(value: o.value, child: Text(_isAm ? o.am : o.en)),
          ],
          onChanged: (v) => setState(() => _customerType = v ?? ''),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _customerNotes,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: l10n.fieldNotes,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        _autoInfoCard(),
      ],
    );
  }

  Widget _garmentsStep() {
    final l10n = AppLocalizations.of(context)!;
    final category = categoryByKey(_categoryKey)!;
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        // Clothing category — Suits (primary) first.
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final c in clothingCategories)
              ChoiceChip(
                label: Text(c.label(_isAm)),
                selected: _categoryKey == c.key,
                onSelected: (_) => setState(() => _categoryKey = c.key),
              ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: () => setState(() {
            for (final g in category.garments) {
              if (!_items.any((i) => i.def.key == g.key)) {
                _items.add(_WizardItem(g, 1));
              }
            }
          }),
          icon: const Icon(Icons.checkroom),
          label: Text(l10n.completeOutfit),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final g in category.garments)
              ActionChip(
                label: Text(g.label(_isAm)),
                avatar: const Icon(Icons.add, size: 18),
                onPressed: () => setState(() {
                  if (!_items.any((i) => i.def.key == g.key)) {
                    _items.add(_WizardItem(g, 1));
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (final item in _items)
          Card(
            child: ListTile(
              leading: const Icon(Icons.checkroom),
              title: Text(item.def.label(_isAm)),
              subtitle: Text('${l10n.quantity}: ${item.quantity}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: item.quantity <= 1
                        ? null
                        : () => setState(() => item.quantity--),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => item.quantity++),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        setState(() => _items.remove(item)),
                  ),
                ],
              ),
            ),
          ),
        if (_items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(child: Text(l10n.noGarments)),
          ),
      ],
    );
  }

  Widget _measurementsStep() {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.read<ShopProvider>();
    final customerId = _found?.id;
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        for (final item in _items)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.def.label(_isAm),
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                      IconButton(
                        tooltip: l10n.copyLastMeasurement,
                        icon: const Icon(Icons.content_copy),
                        onPressed: customerId == null
                            ? null
                            : () {
                                final last = shop.latestMeasurement(
                                    customerId, item.def.key);
                                if (last == null) {
                                  showSnack(
                                      context, l10n.noPreviousMeasurement);
                                } else {
                                  setState(() {
                                    item.measurement
                                      ..clear()
                                      ..addAll(last.fields);
                                    item.measurementId = last.id;
                                  });
                                }
                              },
                      ),
                    ],
                  ),
                  GarmentMeasurementForm(
                    def: item.def,
                    values: item.measurement,
                  ),
                ],
              ),
            ),
          ),
        if (_items.isEmpty) Center(child: Text(l10n.noGarments)),
      ],
    );
  }

  /// Camera capture -> insert into the fabric sample catalog -> select it
  /// for this order. Samples are never modified after being inserted.
  Future<void> _captureSample() async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    XFile? photo;
    try {
      photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 80,
      );
    } catch (_) {
      if (mounted) showSnack(context, l10n.cameraError);
      return;
    }
    if (photo == null || !mounted) return;

    final nameController = TextEditingController();
    final typeController = TextEditingController(text: _fabric.text);
    final colorController = TextEditingController(text: _fabricColor.text);
    final patternController = TextEditingController(text: _fabricPattern.text);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.captureNewSample),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(photo!.path), height: 120, fit: BoxFit.cover),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.sampleName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: typeController,
              decoration: InputDecoration(
                labelText: l10n.fabric,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: colorController,
              decoration: InputDecoration(
                labelText: l10n.fabricColor,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: patternController,
              decoration: InputDecoration(
                labelText: l10n.fabricPattern,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (saved != true || !mounted) return;

    final shop = context.read<ShopProvider>();
    final sample = await shop.saveFabricSample(
      name: nameController.text.trim().isEmpty
          ? l10n.sampleWears
          : nameController.text.trim(),
      tempPhotoPath: photo.path,
      fabricType: typeController.text.trim(),
      color: colorController.text.trim(),
      pattern: patternController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _fabricSampleId = sample.id;
      _fabric.text = sample.fabricType;
      _fabricColor.text = sample.color;
      _fabricPattern.text = sample.pattern;
    });
  }

  Widget _fabricStep() {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        Text(l10n.sampleWears, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(l10n.pickFabricSample,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        if (shop.fabricSamples.isEmpty)
          Text(l10n.noSamples)
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shop.fabricSamples.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final sample = shop.fabricSamples[index];
                final selected = _fabricSampleId == sample.id;
                return GestureDetector(
                  onTap: () => setState(() {
                    _fabricSampleId = sample.id;
                    _fabric.text = sample.fabricType;
                    _fabricColor.text = sample.color;
                    _fabricPattern.text = sample.pattern;
                  }),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(sample.photoPath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                          Positioned(
                            left: 4,
                            right: 4,
                            bottom: 4,
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.all(2),
                              child: Text(
                                sample.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ),
                          if (selected)
                            const Positioned(
                              top: 4,
                              right: 4,
                              child: Icon(Icons.check_circle,
                                  color: Colors.white, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _captureSample,
          icon: const Icon(Icons.photo_camera),
          label: Text(l10n.captureNewSample),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _fabric,
          decoration: InputDecoration(
            labelText: l10n.fabric,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _fabricColor,
          decoration: InputDecoration(
            labelText: l10n.fabricColor,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _fabricPattern,
          decoration: InputDecoration(
            labelText: l10n.fabricPattern,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _accessories,
          decoration: InputDecoration(
            labelText: l10n.accessories,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _instructions,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.specialInstructions,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _deliveryStep() {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.event),
            title: Text(l10n.deliveryDate),
            subtitle: Text(displayDate(context, _delivery)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _delivery ?? todayInAddis(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _delivery = picked);
            },
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _total,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.totalPrice,
            suffixText: l10n.currencyBirr,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _deposit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.depositOptional,
            suffixText: l10n.currencyBirr,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _assignedTo.isEmpty ? null : _assignedTo,
          decoration: InputDecoration(
            labelText: l10n.assignedTailor,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final s in shop.staff)
              DropdownMenuItem(value: s.name, child: Text(s.name)),
          ],
          onChanged: (v) => setState(() => _assignedTo = v ?? ''),
        ),
        const SizedBox(height: 12),
        for (final item in _items)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.checkroom, size: 18),
            title: Text(item.def.label(_isAm)),
            trailing: Text('${l10n.quantity}: ${item.quantity}'),
          ),
        const SizedBox(height: 12),
        _autoInfoCard(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = [
      Step(
        title: Text(l10n.stepCustomer),
        content: _customerStep(),
        isActive: _step >= 0,
      ),
      Step(
        title: Text(l10n.stepGarments),
        content: _garmentsStep(),
        isActive: _step >= 1,
      ),
      Step(
        title: Text(l10n.stepMeasurements),
        content: _measurementsStep(),
        isActive: _step >= 2,
      ),
      Step(
        title: Text(l10n.stepFabric),
        content: _fabricStep(),
        isActive: _step >= 3,
      ),
      Step(
        title: Text(l10n.stepDelivery),
        content: _deliveryStep(),
        isActive: _step >= 4,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newOrder)),
      body: Stepper(
        currentStep: _step,
        steps: steps,
        physics: const ClampingScrollPhysics(),
        onStepTapped: (i) => setState(() => _step = i),
        controlsBuilder: (context, details) {
          final isLast = _step == steps.length - 1;
          return Row(
            children: [
              FilledButton(
                onPressed: () async {
                  if (isLast) {
                    await _save();
                  } else {
                    if (await _validateStep(_step)) {
                      setState(() => _step = _step + 1);
                    }
                  }
                },
                child: Text(isLast ? l10n.save : l10n.apply),
              ),
              if (_step > 0) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(() => _step = _step - 1),
                  child: Text(l10n.cancel),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
