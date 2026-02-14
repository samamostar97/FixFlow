import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/auth_provider.dart';
import 'package:fixflow_mobile/providers/technician/technician_profile_provider.dart';
import 'package:fixflow_mobile/screens/technician/widgets/technician_profile_sections.dart';
import 'package:fixflow_mobile/widgets/shared/loading_skeleton.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_error_state.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TechnicianProfileScreen extends ConsumerStatefulWidget {
  const TechnicianProfileScreen({super.key});

  @override
  ConsumerState<TechnicianProfileScreen> createState() =>
      _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState
    extends ConsumerState<TechnicianProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _specialtiesController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _zoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(technicianProfileProvider.notifier).load());
  }

  @override
  void dispose() {
    _bioController.dispose();
    _specialtiesController.dispose();
    _workingHoursController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  void _startEdit(TechnicianProfileResponse profile) {
    _bioController.text = profile.bio ?? '';
    _specialtiesController.text = profile.specialties ?? '';
    _workingHoursController.text = profile.workingHours ?? '';
    _zoneController.text = profile.zone ?? '';
    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    setState(() => _isEditing = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = UpdateTechnicianProfileRequest(
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      specialties: _specialtiesController.text.trim().isEmpty
          ? null
          : _specialtiesController.text.trim(),
      workingHours: _workingHoursController.text.trim().isEmpty
          ? null
          : _workingHoursController.text.trim(),
      zone: _zoneController.text.trim().isEmpty
          ? null
          : _zoneController.text.trim(),
    );

    final success = await ref
        .read(technicianProfileProvider.notifier)
        .update(request);
    if (!mounted) {
      return;
    }

    if (success) {
      setState(() => _isEditing = false);
      MobileSnackbar.success(context, 'Profil je uspjesno azuriran.');
      return;
    }

    final error = ref.read(technicianProfileProvider).error;
    if (error != null) {
      MobileSnackbar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(technicianProfileProvider);
    final profile = state.profile;

    return MobilePageScaffold(
      title: 'Moj profil',
      actions: [
        if (!_isEditing && profile != null)
          IconButton(
            onPressed: () => _startEdit(profile),
            icon: const Icon(LucideIcons.pencil),
          ),
        IconButton(
          onPressed: () => ref.read(authProvider.notifier).logout(),
          icon: const Icon(LucideIcons.logOut),
        ),
      ],
      onRefresh: () => ref.read(technicianProfileProvider.notifier).load(),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(TechnicianProfileState state) {
    if (state.isLoading && state.profile == null) {
      return const AppListSkeleton(itemCount: 4, padding: EdgeInsets.zero);
    }

    if (state.error != null && state.profile == null) {
      return MobileErrorState(
        message: state.error!,
        onRetry: () => ref.read(technicianProfileProvider.notifier).load(),
      );
    }

    final profile = state.profile;
    if (profile == null) {
      return MobileErrorState(
        message: 'Profil nije dostupan.',
        onRetry: () => ref.read(technicianProfileProvider.notifier).load(),
      );
    }

    if (!_isEditing) {
      return TechnicianProfileViewBody(profile: profile);
    }

    return TechnicianProfileEditForm(
      formKey: _formKey,
      bioController: _bioController,
      specialtiesController: _specialtiesController,
      workingHoursController: _workingHoursController,
      zoneController: _zoneController,
      isSubmitting: state.isLoading,
      onCancel: _cancelEdit,
      onSave: _save,
    );
  }
}
