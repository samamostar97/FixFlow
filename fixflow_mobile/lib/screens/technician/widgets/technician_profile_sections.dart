import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_spacing.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_form_sections.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:flutter/material.dart';

class TechnicianProfileViewBody extends StatelessWidget {
  final TechnicianProfileResponse profile;

  const TechnicianProfileViewBody({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final badgeColor = profile.isVerified
        ? AppStatusColors.completed
        : AppStatusColors.inProgress;
    final badgeText = profile.isVerified ? 'Verifikovan' : 'Ceka verifikaciju';

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        MobileSectionCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  profile.fullName,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        MobileSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Field(label: 'Biografija', value: profile.bio ?? 'Nije uneseno'),
              const SizedBox(height: 12),
              _Field(
                label: 'Specijalnosti',
                value: profile.specialties ?? 'Nije uneseno',
              ),
              const SizedBox(height: 12),
              _Field(
                label: 'Radno vrijeme',
                value: profile.workingHours ?? 'Nije uneseno',
              ),
              const SizedBox(height: 12),
              _Field(label: 'Zona', value: profile.zone ?? 'Nije uneseno'),
            ],
          ),
        ),
      ],
    );
  }
}

class TechnicianProfileEditForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController bioController;
  final TextEditingController specialtiesController;
  final TextEditingController workingHoursController;
  final TextEditingController zoneController;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const TechnicianProfileEditForm({
    super.key,
    required this.formKey,
    required this.bioController,
    required this.specialtiesController,
    required this.workingHoursController,
    required this.zoneController,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFormList();
  }

  Widget _buildFormList() {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        Form(
          key: formKey,
          child: MobileFormSectionCard(
            title: 'Uredite profil',
            subtitle: 'Azurirajte biografiju, usluge i radnu zonu.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Biografija'),
                  validator: (value) => FormValidators.length(value, max: 1000),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: specialtiesController,
                  decoration: const InputDecoration(
                    labelText: 'Specijalnosti',
                    hintText: 'npr. Ves masine, klima uredjaji',
                  ),
                  validator: (value) => FormValidators.length(value, max: 500),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: workingHoursController,
                  decoration: const InputDecoration(
                    labelText: 'Radno vrijeme',
                    hintText: 'npr. Pon-Pet 08:00-17:00',
                  ),
                  validator: (value) => FormValidators.length(value, max: 200),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: zoneController,
                  decoration: const InputDecoration(
                    labelText: 'Zona',
                    hintText: 'npr. Sarajevo Centar',
                  ),
                  validator: (value) => FormValidators.length(value, max: 200),
                ),
                const SizedBox(height: AppSpacing.lg),
                MobileFormActionRow(
                  isSubmitting: isSubmitting,
                  submitLabel: 'Spremi',
                  onCancel: onCancel,
                  onSubmit: onSave,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;

  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
