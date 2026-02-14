import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_spacing.dart';
import 'package:fixflow_mobile/providers/auth_provider.dart';
import 'package:fixflow_mobile/screens/auth/register_screen.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_auth_shell.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .login(
          LoginRequest(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );

    if (!mounted || success) {
      return;
    }

    final error = ref.read(authProvider).error;
    if (error != null) {
      MobileSnackbar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileAuthShell(
      title: 'Dobrodosli u FixFlow',
      subtitle: 'Prijavite se i nastavite upravljanje zahtjevima i poslovima.',
      badgeText: 'Sigurna prijava',
      footer: _buildRegisterLink(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailField(),
            const SizedBox(height: AppSpacing.md),
            _buildPasswordField(),
            const SizedBox(height: AppSpacing.lg),
            _buildSubmitButton(),
          ],
        ),
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

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Lozinka',
        prefixIcon: Icon(LucideIcons.lock),
      ),
      validator: (value) => FormValidators.required(value, 'Lozinka'),
      onFieldSubmitted: (_) => _submit(),
    );
  }

  Widget _buildSubmitButton() {
    final authState = ref.watch(authProvider);

    return FilledButton(
      onPressed: authState.isLoading ? null : _submit,
      child: authState.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Prijavi se'),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
        },
        icon: const Icon(LucideIcons.userPlus, size: 16),
        label: const Text('Nemate nalog? Registrujte se'),
      ),
    );
  }
}
