import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/auth_provider.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:fixflow_mobile/screens/customer/widgets/customer_profile_sections.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomerProfileScreen extends ConsumerStatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  ConsumerState<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState
    extends ConsumerState<CustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _startEdit(UserResponse user) {
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _phoneController.text = user.phone ?? '';
    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    setState(() => _isEditing = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final updated = await ref.read(userServiceProvider).updateProfile(
            UpdateProfileRequest(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
            ),
          );

      if (!mounted) return;
      ref.read(authProvider.notifier).updateUser(updated);
      setState(() => _isEditing = false);
      MobileSnackbar.success(context, 'Profil je uspjesno azuriran.');
    } on ApiException catch (e) {
      if (!mounted) return;
      MobileSnackbar.error(context, e.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    return MobilePageScaffold(
      title: 'Moj profil',
      actions: [
        if (!_isEditing)
          IconButton(
            onPressed: () => _startEdit(user),
            icon: const Icon(LucideIcons.pencil),
          ),
        IconButton(
          onPressed: () => ref.read(authProvider.notifier).logout(),
          icon: const Icon(LucideIcons.logOut),
        ),
      ],
      body: _isEditing
          ? CustomerProfileEditForm(
              formKey: _formKey,
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
              phoneController: _phoneController,
              isSubmitting: _isSubmitting,
              onCancel: _cancelEdit,
              onSave: _save,
            )
          : CustomerProfileDisplayBody(user: user),
    );
  }
}
