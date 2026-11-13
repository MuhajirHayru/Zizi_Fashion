import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

import '../data/auth_service.dart';
import 'common.dart';

/// Bottom sheet to create or change the app-lock username & password.
/// Returns true when credentials were saved.
Future<bool> showAuthSetupSheet(
  BuildContext context, {
  String? currentUsername,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AuthSetupForm(currentUsername: currentUsername),
  );
  return result ?? false;
}

class _AuthSetupForm extends StatefulWidget {
  const _AuthSetupForm({this.currentUsername});

  final String? currentUsername;

  @override
  State<_AuthSetupForm> createState() => _AuthSetupFormState();
}

class _AuthSetupFormState extends State<_AuthSetupForm> {
  late final TextEditingController _username =
      TextEditingController(text: widget.currentUsername ?? '');
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final username = _username.text.trim();
    final password = _password.text;
    if (username.length < 3) {
      showSnack(context, l10n.usernameTooShort);
      return;
    }
    if (password.length < 4) {
      showSnack(context, l10n.passwordTooShort);
      return;
    }
    if (password != _confirm.text) {
      showSnack(context, l10n.passwordsDoNotMatch);
      return;
    }
    await context.read<AuthService>().setUp(username, password);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.currentUsername == null
                ? l10n.createUsernamePassword
                : l10n.changeCredentials,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _username,
            autofocus: widget.currentUsername == null,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.fieldUsername,
              prefixIcon: const Icon(Icons.person_outline),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.fieldPassword,
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: _obscure,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: l10n.fieldConfirmPassword,
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(l10n.save),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
