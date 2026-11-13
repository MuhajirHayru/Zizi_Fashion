import 'package:flutter/material.dart';
import 'package:tailor_shop/l10n/app_localizations.dart';

/// Style keys stored in the database; shown through [styleLabel].
const List<String> orderStyleKeys = [
  'suit',
  'shirt',
  'trousers',
  'dress',
  'traditional',
  'other',
];

String styleLabel(BuildContext context, String style) {
  final l10n = AppLocalizations.of(context)!;
  return switch (style) {
    'suit' => l10n.styleSuit,
    'shirt' => l10n.styleShirt,
    'trousers' => l10n.styleTrousers,
    'dress' => l10n.styleDress,
    'traditional' => l10n.styleTraditional,
    'other' => l10n.styleOther,
    _ => style,
  };
}

Future<bool> confirmDelete(BuildContext context, String message) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.areYouSure),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
