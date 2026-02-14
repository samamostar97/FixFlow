import 'package:fixflow_core/fixflow_core.dart';
import 'package:flutter/material.dart';

Future<void> showRepairCategoryFormDialog({
  required BuildContext context,
  required Future<void> Function(String name) onCreate,
  required Future<void> Function(int id, String name) onUpdate,
  RepairCategoryResponse? category,
}) async {
  final controller = TextEditingController(text: category?.name ?? '');
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(category == null ? 'Nova kategorija' : 'Uredi kategoriju'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Naziv'),
            validator: FormValidators.compose([
              (value) => FormValidators.required(value, 'Naziv'),
              (value) => FormValidators.length(value, min: 2, max: 100),
            ]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Otkazi'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              Navigator.of(ctx).pop();
              final name = controller.text.trim();

              try {
                if (category == null) {
                  await onCreate(name);
                } else {
                  await onUpdate(category.id, name);
                }
              } on ApiException catch (e) {
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(e.message)));
              }
            },
            child: Text(category == null ? 'Spremi' : 'Azuriraj'),
          ),
        ],
      );
    },
  );
}

Future<void> showRepairCategoryDeleteDialog({
  required BuildContext context,
  required RepairCategoryResponse category,
  required Future<void> Function(int id) onDelete,
}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Obrisi kategoriju'),
        content: Text(
          'Jeste li sigurni da zelite obrisati "${category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Otkazi'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await onDelete(category.id);
              } on ApiException catch (e) {
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(e.message)));
              }
            },
            child: const Text('Obrisi'),
          ),
        ],
      );
    },
  );
}
