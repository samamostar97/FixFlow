import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_spacing.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_form_sections.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomerProfileDisplayBody extends StatelessWidget {
  final UserResponse user;

  const CustomerProfileDisplayBody({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        MobileSectionCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Text(
                  '${user.firstName[0]}${user.lastName[0]}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${user.firstName} ${user.lastName}',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        MobileSectionCard(
          child: Column(
            children: [
              _buildInfoRow(
                theme,
                LucideIcons.phone,
                'Telefon',
                user.phone ?? 'Nije uneseno',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                theme,
                LucideIcons.calendar,
                'Clan od',
                DateFormatter.format(user.createdAt),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class CustomerProfileEditForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const CustomerProfileEditForm({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: MobileFormSectionCard(
          title: 'Uredite profil',
          subtitle: 'Azurirajte vase licne podatke.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Ime',
                  prefixIcon: Icon(LucideIcons.user),
                ),
                validator: FormValidators.compose([
                  (value) => FormValidators.required(value, 'Ime'),
                  (value) => FormValidators.length(value, min: 2, max: 50),
                ]),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Prezime',
                  prefixIcon: Icon(LucideIcons.user),
                ),
                validator: FormValidators.compose([
                  (value) => FormValidators.required(value, 'Prezime'),
                  (value) => FormValidators.length(value, min: 2, max: 50),
                ]),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon (opcionalno)',
                  prefixIcon: Icon(LucideIcons.phone),
                ),
                validator: (value) =>
                    value != null && value.trim().isNotEmpty
                        ? FormValidators.phone(value)
                        : null,
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
    );
  }
}
