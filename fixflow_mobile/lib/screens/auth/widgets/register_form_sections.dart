import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegisterNameFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const RegisterNameFields({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [
              _FirstNameField(controller: firstNameController),
              const SizedBox(height: AppSpacing.md),
              _LastNameField(controller: lastNameController),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _FirstNameField(controller: firstNameController)),
            const SizedBox(width: 12),
            Expanded(child: _LastNameField(controller: lastNameController)),
          ],
        );
      },
    );
  }
}

class RegisterPasswordFields extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;

  const RegisterPasswordFields({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: passwordController,
          obscureText: true,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Lozinka',
            prefixIcon: Icon(LucideIcons.lock),
          ),
          validator: (value) => FormValidators.password(value, minLength: 6),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: confirmPasswordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Potvrdi lozinku',
            prefixIcon: Icon(LucideIcons.lock),
          ),
          validator: (value) =>
              FormValidators.confirmPassword(value, passwordController.text),
          onFieldSubmitted: (_) => onSubmit(),
        ),
      ],
    );
  }
}

class RegisterRoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const RegisterRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registrujem se kao:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<UserRole>(
          segments: [
            const ButtonSegment(
              value: UserRole.customer,
              label: Text('Korisnik'),
              icon: Icon(LucideIcons.user),
            ),
            const ButtonSegment(
              value: UserRole.technician,
              label: Text('Majstor'),
              icon: Icon(LucideIcons.wrench),
            ),
          ],
          selected: {selectedRole},
          onSelectionChanged: (selected) => onRoleChanged(selected.first),
        ),
      ],
    );
  }
}

class _FirstNameField extends StatelessWidget {
  final TextEditingController controller;

  const _FirstNameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Ime',
        prefixIcon: Icon(LucideIcons.user),
      ),
      validator: FormValidators.compose([
        (value) => FormValidators.required(value, 'Ime'),
        (value) => FormValidators.length(value, min: 2, max: 100),
      ]),
    );
  }
}

class _LastNameField extends StatelessWidget {
  final TextEditingController controller;

  const _LastNameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Prezime',
        prefixIcon: Icon(LucideIcons.user),
      ),
      validator: FormValidators.compose([
        (value) => FormValidators.required(value, 'Prezime'),
        (value) => FormValidators.length(value, min: 2, max: 100),
      ]),
    );
  }
}
