import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_desktop/providers/auth_provider.dart';
import 'package:fixflow_desktop/screens/auth/widgets/login_layout.dart';
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
    if (!_formKey.currentState!.validate()) return;

    final request = LoginRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    final success = await ref.read(authProvider.notifier).login(request);

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 5),
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LoginLayout(formPanel: _buildFormPanel(context)));
  }

  Widget _buildFormPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Prijava na sistem',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Unesite pristupne podatke za admin panel.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            _buildEmailField(),
            const SizedBox(height: 12),
            _buildPasswordField(),
            const SizedBox(height: 20),
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
        prefixIcon: Icon(LucideIcons.mail),
      ),
      validator: (v) => FormValidators.required(v, 'Email'),
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
      validator: (v) => FormValidators.required(v, 'Lozinka'),
      onFieldSubmitted: (_) => _submit(),
    );
  }

  Widget _buildSubmitButton() {
    final authState = ref.watch(authProvider);
    return FilledButton.icon(
      onPressed: authState.isLoading ? null : _submit,
      icon: authState.isLoading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(LucideIcons.logIn),
      label: Text(authState.isLoading ? 'Prijava...' : 'Prijavi se'),
    );
  }
}
