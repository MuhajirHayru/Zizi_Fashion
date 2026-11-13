import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../data/auth_service.dart';
import '../state/settings_provider.dart';
import '../state/shop_provider.dart';
import 'auth_edit.dart';
import 'common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _addStaffDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addStaff),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.staffName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.fieldPhone,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                showSnack(context, l10n.nameRequired);
                return;
              }
              context
                  .read<ShopProvider>()
                  .addStaff(name, phoneController.text.trim());
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthService>();
    final shop = context.watch<ShopProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'en',
                  groupValue: settings.locale.languageCode,
                  title: const Text('English'),
                  onChanged: (value) =>
                      settings.setLocale(const Locale('en')),
                ),
                RadioListTile<String>(
                  value: 'am',
                  groupValue: settings.locale.languageCode,
                  title: const Text('አማርኛ'),
                  onChanged: (value) =>
                      settings.setLocale(const Locale('am')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.staff, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final member in shop.staff)
                  ListTile(
                    leading: Icon(
                      member.id == shop.activeStaffId
                          ? Icons.check_circle
                          : Icons.person_outline,
                      color: member.id == shop.activeStaffId
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(member.name),
                    subtitle: member.phone.isEmpty ? null : Text(member.phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final shopProvider = context.read<ShopProvider>();
                        if (await confirmDelete(
                            context, l10n.areYouSure)) {
                          await shopProvider.deleteStaff(member);
                        }
                      },
                    ),
                    onTap: () =>
                        context.read<ShopProvider>().setActiveStaff(member.id),
                  ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: Text(l10n.addStaff),
                  onTap: () => _addStaffDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.activeStaff,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          Text(l10n.security, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.lock_outline),
                  title: Text(l10n.appLock),
                  subtitle: Text(l10n.appLockDesc),
                  value: auth.enabled,
                  onChanged: auth.isSetUp
                      ? (value) =>
                          context.read<AuthService>().setEnabled(value)
                      : (value) async {
                          // First time: create username & password, which
                          // also turns the lock on.
                          if (value) await showAuthSetupSheet(context);
                        },
                ),
                if (auth.isSetUp)
                  ListTile(
                    leading: const Icon(Icons.key),
                    title: Text(l10n.changeCredentials),
                    onTap: () => showAuthSetupSheet(
                      context,
                      currentUsername: auth.username,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: Icon(Icons.cloud_off,
                  color: Theme.of(context).colorScheme.primary),
              title: Text(l10n.dataStoredLocally),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () async {
              try {
                final path = await shop.exportBackup();
                if (context.mounted) {
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n.exportData),
                      content: SelectableText(l10n.exportDone(path)),
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
            icon: const Icon(Icons.ios_share),
            label: Text(l10n.exportData),
          ),
          const SizedBox(height: 24),
          Text(l10n.developers, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Muhajir Hayru'),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('muhajirhayru18@gmail.com'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
