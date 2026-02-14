import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_spacing.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_form_sections.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class JobDetailActionsCard extends StatelessWidget {
  final BookingResponse booking;
  final ValueChanged<JobStatus> onUpdateStatus;
  final VoidCallback onAddPart;

  const JobDetailActionsCard({
    super.key,
    required this.booking,
    required this.onUpdateStatus,
    required this.onAddPart,
  });

  @override
  Widget build(BuildContext context) {
    final transitions = booking.jobStatus.allowedTransitions;
    if (transitions.isEmpty && booking.jobStatus != JobStatus.diagnostics) {
      return const SizedBox.shrink();
    }

    return MobileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Akcije', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          if (transitions.isNotEmpty)
            ...transitions.map(
              (next) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FilledButton.icon(
                  onPressed: () => onUpdateStatus(next),
                  icon: const Icon(LucideIcons.arrowRight),
                  label: Text('Postavi: ${next.displayName}'),
                ),
              ),
            ),
          if (booking.jobStatus == JobStatus.diagnostics &&
              booking.partsDescription == null)
            OutlinedButton.icon(
              onPressed: onAddPart,
              icon: const Icon(LucideIcons.plus),
              label: const Text('Dodaj dio'),
            ),
        ],
      ),
    );
  }
}

Future<String?> showStatusUpdateBottomSheet({
  required BuildContext context,
  required JobStatus currentStatus,
  required JobStatus nextStatus,
}) {
  final noteController = TextEditingController();

  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _BottomSheetContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MobileFormSectionCard(
            title: 'Promijeni status',
            subtitle:
                '${currentStatus.displayName} -> ${nextStatus.displayName}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Napomena (opcionalno)',
                    hintText: 'Unesite napomenu',
                    prefixIcon: Icon(LucideIcons.messageSquare),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                MobileFormSubmitButton(
                  isLoading: false,
                  label: 'Potvrdi',
                  onPressed: () =>
                      Navigator.of(ctx).pop(noteController.text.trim()),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class PartsInput {
  final String description;
  final double cost;

  const PartsInput({required this.description, required this.cost});
}

Future<PartsInput?> showAddPartsBottomSheet(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  final costController = TextEditingController();

  return showModalBottomSheet<PartsInput?>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _BottomSheetContent(
      child: Form(
        key: formKey,
        child: MobileFormSectionCard(
          title: 'Dodaj dio',
          subtitle: 'Unesite opis i cijenu rezervnog dijela.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Opis dijela',
                  hintText: 'Unesite opis dijela',
                  prefixIcon: Icon(LucideIcons.fileText),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Opis mora imati najmanje 2 karaktera.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: costController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Cijena (KM)',
                  hintText: '0.00',
                  prefixIcon: Icon(LucideIcons.wallet),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Cijena je obavezna.';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed < 0.01 || parsed > 100000) {
                    return 'Cijena mora biti izmedju 0.01 i 100000.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              MobileFormSubmitButton(
                isLoading: false,
                label: 'Dodaj',
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  Navigator.of(ctx).pop(
                    PartsInput(
                      description: descriptionController.text.trim(),
                      cost: double.parse(costController.text.trim()),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _BottomSheetContent extends StatelessWidget {
  final Widget child;

  const _BottomSheetContent({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
          MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
        ),
        child: child,
      ),
    );
  }
}
