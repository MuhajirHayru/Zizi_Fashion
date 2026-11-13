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
import '../util/zizi_colors.dart';
import '../widgets/garment_form.dart';
import 'common.dart';
import 'order_success_screen.dart';

class _WizardItem {
  _WizardItem(this.def, this.quantity);
  GarmentDef def;
  int quantity;
  Map<String, String> measurement = {};
  Map<String, String> style = {};
  String measurementId = '';
  String notes = '';

  int get filledCount =>
      measurement.values.where((v) => v.isNotEmpty).length;
}

/// A design reference image captured/uploaded, waiting to be saved with
/// the order.
class _DesignDraft {
  _DesignDraft(this.groupKey, this.filePath);
  final String groupKey;
  final String filePath;
  String description = '';
}

/// ZIZI FASHION new-order wizard with horizontal navigation:
/// Customer → Clothing → Measurements → Design → Fabric → Details → Review.
class NewOrderWizard extends StatefulWidget {
  const NewOrderWizard({super.key, this.existingCustomer});

  final Customer? existingCustomer;

  @override
  State<NewOrderWizard> createState() => _NewOrderWizardState();
}

class _NewOrderWizardState extends State<NewOrderWizard> {
  static const int _stepCount = 7;

  int _step = 0;
  int _itemTab = 0;

  final TextEditingController _phone = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _fabric = TextEditingController();
  final TextEditingController _fabricColor = TextEditingController();
  final TextEditingController _fabricPattern = TextEditingController();
  final TextEditingController _lining = TextEditingController();
  final TextEditingController _accessories = TextEditingController();
  final TextEditingController _instructions = TextEditingController();
  final TextEditingController _total = TextEditingController();
  final TextEditingController _deposit = TextEditingController();

  String _gender = '';
  String _categoryKey = '';
  Customer? _found;
  String? _orderNoPreview;
  DateTime? _delivery;
  String _assignedTo = '';
  String _fabricSampleId = '';
  final List<_WizardItem> _items = [];
  final List<_DesignDraft> _designs = [];

  final DateTime _registeredAt = nowInAddis();

  bool get _isAm =>
      context.read<SettingsProvider>().locale.languageCode == 'am';

  @override
  void initState() {
    super.initState();
    final prefill = widget.existingCustomer;
    if (prefill != null) {
      _found = prefill;
      _phone.text = prefill.phone;
      _name.text = prefill.name;
      _address.text = prefill.address;
      _gender = prefill.gender;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final no = await context.read<ShopProvider>().nextOrderNumber();
        if (mounted) setState(() => _orderNoPreview = no);
      } catch (_) {
        // Environments without the database plugin (e.g. widget tests).
      }
    });
  }

  @override
  void dispose() {
    for (final c in [
      _phone, _name, _address, _fabric, _fabricColor, _fabricPattern,
      _lining, _accessories, _instructions, _total, _deposit,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- navigation ----------

  Future<bool> _validateStep(int step) async {
    final l10n = AppLocalizations.of(context)!;
    switch (step) {
      case 0:
        if (_phone.text.trim().isEmpty ||
            _name.text.trim().isEmpty ||
            _gender.isEmpty) {
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
      case 2:
        final missing =
            _items.where((i) => i.filledCount == 0).toList();
        if (missing.isNotEmpty) {
          final goOn = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(l10n.areYouSure),
              content: Text(l10n.noMeasurements),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(l10n.apply),
                ),
              ],
            ),
          );
          return goOn ?? false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _goNext() async {
    if (_step < _stepCount - 1) {
      if (await _validateStep(_step)) {
        setState(() => _step = _step + 1);
      }
    } else {
      await _save();
    }
  }

  List<String> _stepLabels(AppLocalizations l10n) => [
        l10n.stepCustomer,
        l10n.stepGarments,
        l10n.stepMeasurements,
        l10n.stepDesign,
        l10n.stepFabric,
        l10n.stepDelivery,
        l10n.stepReview,
      ];

  Widget _stepHeader(AppLocalizations l10n) {
    final labels = _stepLabels(l10n);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? ZiziColors.purple
                          : Colors.white,
                      border: Border.all(
                        color: i <= _step
                            ? ZiziColors.purple
                            : ZiziColors.cardBorder,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: i < _step
                          ? const Icon(Icons.check,
                              size: 18, color: Colors.white)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: i == _step
                                    ? Colors.white
                                    : ZiziColors.ink,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: i == _step
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: i == _step
                          ? ZiziColors.purple
                          : ZiziColors.ink
                              .withOpacity(0.55),
                    ),
                  ),
                ],
              ),
              if (i < labels.length - 1)
                Container(
                  width: 26,
                  height: 2,
                  margin: const EdgeInsets.only(top: 16),
                  color: i < _step
                      ? ZiziColors.purple
                      : ZiziColors.cardBorder,
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------- step 0: customer ----------

  Widget _customerStep() {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();
    final query = _phone.text.trim();
    final matches = query.isEmpty
        ? const <Customer>[]
        : shop.customers
            .where((c) => c.phone
                .replaceAll(RegExp(r'\D'), '')
                .contains(query.replaceAll(RegExp(r'\D'), '')))
            .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: '${l10n.fieldPhone} *',
                    helperText: l10n.searchPhoneHint,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (matches.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  for (final match in matches.take(3))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_search),
                      title: Text(match.name),
                      subtitle: Text(match.phone),
                      trailing: Text(l10n.customerFound,
                          style: Theme.of(context).textTheme.labelSmall),
                      onTap: () {
                        setState(() {
                          _found = match;
                          _phone.text = match.phone;
                          _name.text = match.name;
                          _address.text = match.address;
                          _gender = match.gender;
                        });
                      },
                    ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: '${l10n.fieldName} *',
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _gender.isEmpty ? null : _gender,
                  decoration: InputDecoration(
                    labelText: '${l10n.fieldGender} *',
                    prefixIcon: const Icon(Icons.people),
                  ),
                  items: [
                    for (final o in genderOptions)
                      DropdownMenuItem(
                          value: o.value,
                          child: Text(_isAm ? o.am : o.en)),
                  ],
                  onChanged: (v) {
                    setState(() {
                      if (_gender != (v ?? '')) {
                        // Garments belong to the selected gender.
                        _gender = v ?? '';
                        _categoryKey = '';
                        _items.clear();
                        _designs.clear();
                        _itemTab = 0;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _address,
                  decoration: InputDecoration(
                    labelText: l10n.fieldAddress,
                    prefixIcon: const Icon(Icons.place),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _autoInfoCard(),
      ],
    );
  }

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
                    color: Theme.of(context).colorScheme.secondary),
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
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ---------- step 1: clothing ----------

  Widget _clothingStep() {
    final l10n = AppLocalizations.of(context)!;
    final categories = clothingCategories
        .where((c) =>
            _gender.isEmpty ||
            (c.wearGroup == WearGroup.male && _gender == 'male') ||
            (c.wearGroup == WearGroup.female && _gender == 'female'))
        .toList();
    final selected = categoryByKey(_categoryKey);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final c in categories)
              ChoiceChip(
                label: Text(c.label(_isAm)),
                selected: _categoryKey == c.key,
                onSelected: (_) => setState(() => _categoryKey = c.key),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (selected != null) ...[
          FilledButton.tonalIcon(
            onPressed: () => setState(() {
              for (final g in selected.garments) {
                _addGarment(g);
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
              for (final g in selected.garments)
                ActionChip(
                  label: Text(g.label(_isAm)),
                  avatar: const Icon(Icons.add, size: 18),
                  onPressed: () => setState(() => _addGarment(g)),
                ),
            ],
          ),
        ],
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
                    onPressed: () => setState(() {
                      _items.remove(item);
                      _itemTab = 0;
                    }),
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

  void _addGarment(GarmentDef def) {
    if (def.isBundle) {
      for (final key in def.bundleKeys) {
        final g = garmentByKey(key);
        if (g != null && !_items.any((i) => i.def.key == g.key)) {
          _items.add(_WizardItem(g, 1));
        }
      }
    } else if (!_items.any((i) => i.def.key == def.key)) {
      _items.add(_WizardItem(def, 1));
    }
  }

  // ---------- step 2: measurements (horizontal garment tabs) ----------

  Widget _measurementsStep() {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.read<ShopProvider>();
    if (_items.isEmpty) {
      return Center(child: Text(l10n.noGarments));
    }
    if (_itemTab >= _items.length) _itemTab = _items.length - 1;
    final item = _items[_itemTab];
    final def = item.def;
    final customerId = _found?.id;

    final totalAll = _items.fold<int>(
        0, (sum, i) => sum + i.def.measurements.length);
    final filledAll =
        _items.fold<int>(0, (sum, i) => sum + i.filledCount);
    final progress = totalAll == 0 ? 0.0 : filledAll / totalAll;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: LinearProgressIndicator(value: progress)),
            const SizedBox(width: 12),
            Text('$filledAll/$totalAll',
                style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 12),
        // Horizontal, scrollable garment tabs with completion dots.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _garmentTab(_items[i], i),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(def.label(_isAm),
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    IconButton(
                      tooltip: l10n.copyLastMeasurement,
                      icon: const Icon(Icons.content_copy),
                      onPressed: customerId == null
                          ? null
                          : () {
                              final last = shop.latestMeasurement(
                                  customerId, def.key);
                              if (last == null) {
                                showSnack(context,
                                    l10n.noPreviousMeasurement);
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
                const SizedBox(height: 8),
                GarmentMeasurementForm(
                  def: def,
                  values: item.measurement,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: _itemTab == 0
                  ? null
                  : () => setState(() => _itemTab = _itemTab - 1),
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.back),
            ),
            Text('${_itemTab + 1} / ${_items.length}'),
            FilledButton.icon(
              onPressed: _itemTab == _items.length - 1
                  ? null
                  : () => setState(() => _itemTab = _itemTab + 1),
              icon: const Icon(Icons.arrow_forward),
              label: Text(l10n.next),
            ),
          ],
        ),
      ],
    );
  }

  Widget _garmentTab(_WizardItem item, int index) {
    final total = item.def.measurements.length;
    final filled = item.filledCount;
    final selected = index == _itemTab;
    final dot = filled == 0
        ? Colors.grey.shade400
        : filled >= total
            ? Colors.green
            : Colors.orange;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(item.def.label(_isAm)),
        ],
      ),
      selected: selected,
      onSelected: (_) => setState(() => _itemTab = index),
    );
  }

  // ---------- step 3: design samples (camera) ----------

  Widget _designStep() {
    final l10n = AppLocalizations.of(context)!;
    final groups = <String>[];
    for (final item in _items) {
      if (!groups.contains(item.def.designGroup)) {
        groups.add(item.def.designGroup);
      }
    }
    if (!groups.contains('other')) groups.add('other');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.designReference,
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final group in groups)
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
                        child: Text(designGroupLabel(group, _isAm),
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                      IconButton(
                        tooltip: l10n.openCamera,
                        icon: const Icon(Icons.photo_camera),
                        onPressed: () => _addDesignImage(group,
                            fromCamera: true),
                      ),
                      IconButton(
                        tooltip: l10n.uploadImage,
                        icon: const Icon(Icons.photo_library),
                        onPressed: () => _addDesignImage(group,
                            fromCamera: false),
                      ),
                    ],
                  ),
                  for (final draft in _designs
                      .where((d) => d.groupKey == group)
                      .toList())
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(draft.filePath),
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: draft.description,
                            decoration: InputDecoration(
                              labelText: l10n.imageDescription,
                              isDense: true,
                            ),
                            onChanged: (v) => draft.description = v.trim(),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.removeImage,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              setState(() => _designs.remove(draft)),
                        ),
                      ],
                    ),
                if (!_designs.any((d) => d.groupKey == group))
                  Text(l10n.noSamples,
                      style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addDesignImage(String group, {required bool fromCamera}) async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    XFile? photo;
    try {
      photo = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
      );
    } catch (_) {
      if (mounted) showSnack(context, l10n.cameraError);
      return;
    }
    if (photo == null || !mounted) return;
    setState(() => _designs.add(_DesignDraft(group, photo!.path)));
  }

  // ---------- step 4: fabric ----------

  Widget _fabricStep() {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
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
          decoration: InputDecoration(labelText: l10n.fabric),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _fabricColor,
          decoration: InputDecoration(labelText: l10n.fabricColor),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _fabricPattern,
          decoration: InputDecoration(labelText: l10n.fabricPattern),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _lining,
          decoration: InputDecoration(labelText: l10n.lining),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _accessories,
          decoration: InputDecoration(labelText: l10n.accessories),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _instructions,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n.specialInstructions),
        ),
      ],
    );
  }

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
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: l10n.fabric),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: colorController,
              decoration: InputDecoration(labelText: l10n.fabricColor),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: patternController,
              decoration: InputDecoration(labelText: l10n.fabricPattern),
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

  // ---------- step 5: order details ----------

  Widget _detailsStep() {
    final l10n = AppLocalizations.of(context)!;
    final shop = context.watch<ShopProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
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
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.totalPrice,
            suffixText: l10n.currencyBirr,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _deposit,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.depositOptional,
            suffixText: l10n.currencyBirr,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _assignedTo.isEmpty ? null : _assignedTo,
          decoration: InputDecoration(labelText: l10n.assignedTailor),
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

  // ---------- step 6: review ----------

  Widget _reviewStep() {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.stepCustomer,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                _infoRow(l10n.fieldName, _name.text.trim()),
                _infoRow(l10n.fieldPhone, _phone.text.trim()),
                _infoRow(l10n.fieldGender,
                    optionLabel(genderOptions, _gender, _isAm)),
                if (_address.text.trim().isNotEmpty)
                  _infoRow(l10n.fieldAddress, _address.text.trim()),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.stepGarments,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                for (final item in _items)
                  _infoRow(item.def.label(_isAm),
                      '${l10n.quantity}: ${item.quantity} · '
                      '${l10n.measurements}: ${item.filledCount}'),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.designReference,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                for (final group in _designs
                    .map((d) => d.groupKey)
                    .toSet())
                  _infoRow(designGroupLabel(group, _isAm),
                      '${_designs.where((d) => d.groupKey == group).length}'),
                if (_designs.isEmpty) const Text('—'),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.stepFabric,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                _infoRow(l10n.fabric, _fabric.text.trim()),
                _infoRow(l10n.fabricColor, _fabricColor.text.trim()),
                _infoRow(l10n.fabricPattern, _fabricPattern.text.trim()),
                if (_lining.text.trim().isNotEmpty)
                  _infoRow(l10n.lining, _lining.text.trim()),
                if (_accessories.text.trim().isNotEmpty)
                  _infoRow(l10n.accessories, _accessories.text.trim()),
                if (_instructions.text.trim().isNotEmpty)
                  _infoRow(l10n.specialInstructions,
                      _instructions.text.trim()),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.stepDelivery,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                _infoRow(l10n.deliveryDate, displayDate(context, _delivery)),
                _infoRow(l10n.totalPrice,
                    '${money(parseAmount(_total.text) ?? 0)} ${l10n.currencyBirr}'),
                _infoRow(l10n.assignedTailor,
                    _assignedTo.isEmpty ? '—' : _assignedTo),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _autoInfoCard(),
      ],
    );
  }

  // ---------- save ----------

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final total = parseAmount(_total.text);
    if (total == null || total < 0) {
      showSnack(context, l10n.enterValidAmount);
      return;
    }
    final shop = context.read<ShopProvider>();
    final staffMember = shop.activeStaff;
    final registeredBy =
        _assignedTo.isNotEmpty ? _assignedTo : (staffMember?.name ?? '');

    final customer = Customer.create(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      gender: _gender,
      address: _address.text.trim(),
      customerType: _found == null ? 'new' : 'returning',
      registeredBy: registeredBy,
    );

    final order = ShopOrder.create(
      customerId: _found?.id ?? '',
      style: 'custom',
      totalPrice: total,
      fabric: _fabric.text.trim(),
      deliveryDate: _delivery,
      notes: _instructions.text.trim(),
      orderNo: _orderNoPreview ?? '',
      category: _categoryKey,
      assignedTo: registeredBy,
      fabricSampleId: _fabricSampleId,
      fabricColor: _fabricColor.text.trim(),
      fabricPattern: _fabricPattern.text.trim(),
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

    for (final draft in _designs) {
      await shop.saveOrderImage(
        orderId: saved.id,
        groupKey: draft.groupKey,
        tempPath: draft.filePath,
        description: draft.description,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(orderNo: saved.orderNo),
      ),
    );
  }

  // ---------- build ----------

  Widget _buildStep(int step) => switch (step) {
        0 => _customerStep(),
        1 => _clothingStep(),
        2 => _measurementsStep(),
        3 => _designStep(),
        4 => _fabricStep(),
        5 => _detailsStep(),
        _ => _reviewStep(),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newOrder)),
      body: Column(
        children: [
          _stepHeader(l10n),
          Expanded(child: _buildStep(_step)),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: 10 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                if (_step > 0)
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _step = _step - 1),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.back),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _goNext,
                  icon: Icon(_step == _stepCount - 1
                      ? Icons.check
                      : Icons.arrow_forward),
                  label: Text(_step == _stepCount - 1
                      ? l10n.save
                      : l10n.next),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
