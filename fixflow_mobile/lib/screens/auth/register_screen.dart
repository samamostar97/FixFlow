import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_spacing.dart';
import 'package:fixflow_mobile/providers/auth_provider.dart';
import 'package:fixflow_mobile/screens/auth/widgets/register_form_sections.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_auth_shell.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .register(
          RegisterRequest(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            role: _selectedRole,
          ),
        );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final error = ref.read(authProvider).error;
    if (error != null) {
      MobileSnackbar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return MobileAuthShell(
      title: 'Kreirajte novi nalog',
      subtitle: 'Unesite osnovne podatke i odaberite svoju ulogu.',
      badgeText: 'Brza registracija',
      showBackButton: true,
      footer: _buildBackToLogin(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegisterNameFields(
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildEmailField(),
            const SizedBox(height: AppSpacing.md),
            _buildPhoneField(),
            const SizedBox(height: AppSpacing.md),
            RegisterPasswordFields(
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              onSubmit: _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            RegisterRoleSelector(
              selectedRole: _selectedRole,
              onRoleChanged: (role) => setState(() => _selectedRole = role),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: authState.isLoading ? null : _submit,
              child: authState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Registruj se'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToLogin(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(LucideIcons.arrowLeft, size: 16),
        label: const Text('Nazad na prijavu'),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'ime.prezime@email.com',
        prefixIcon: Icon(LucideIcons.mail),
      ),
      validator: FormValidators.compose([
        (value) => FormValidators.required(value, 'Email'),
        FormValidators.email,
      ]),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Telefon',
        hintText: 'Opcionalno',
        prefixIcon: Icon(LucideIcons.phone),
      ),
      validator: FormValidators.phone,
    );
  }
}
