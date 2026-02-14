import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_spacing.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:fixflow_mobile/screens/customer/widgets/preference_type_selector.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_form_sections.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CreateRepairRequestScreen extends ConsumerStatefulWidget {
  const CreateRepairRequestScreen({super.key});

  @override
  ConsumerState<CreateRepairRequestScreen> createState() =>
      _CreateRepairRequestScreenState();
}

class _CreateRepairRequestScreenState
    extends ConsumerState<CreateRepairRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  int? _selectedCategoryId;
  int _preferenceType = 0;
  bool _isSubmitting = false;
  List<LookupResponse>? _categories;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ref
          .read(repairCategoryServiceProvider)
          .getLookup();
      if (mounted) {
        setState(() => _categories = categories);
      }
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      MobileSnackbar.error(context, e.message);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategoryId == null) {
      MobileSnackbar.error(context, 'Odaberite kategoriju.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final service = ref.read(repairRequestServiceProvider);
      await service.create(
        CreateRepairRequestRequest(
          categoryId: _selectedCategoryId!,
          description: _descriptionController.text.trim(),
          preferenceType: _preferenceType,
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
        ).toJson(),
      );
      if (!mounted) {
        return;
      }
      MobileSnackbar.success(context, 'Zahtjev je uspjesno kreiran.');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      MobileSnackbar.error(
        context,
        e.message,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobilePageScaffold(
      title: 'Novi zahtjev',
      subtitle: 'Unesite osnovne informacije o kvaru.',
      scrollable: true,
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: MobileFormSectionCard(
        title: 'Podaci o kvaru',
        subtitle: 'Odaberite kategoriju i opisite problem.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCategoryDropdown(),
            const SizedBox(height: AppSpacing.md),
            _buildDescriptionField(),
            const SizedBox(height: AppSpacing.md),
            PreferenceTypeSelector(
              value: _preferenceType,
              onChanged: (value) => setState(() => _preferenceType = value),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildAddressField(),
            const SizedBox(height: AppSpacing.lg),
            MobileFormSubmitButton(
              isLoading: _isSubmitting,
              label: 'Kreiraj zahtjev',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    if (_categories == null) return const LinearProgressIndicator();

    return DropdownButtonFormField<int>(
      initialValue: _selectedCategoryId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Kategorija *',
        prefixIcon: Icon(LucideIcons.tag),
      ),
      items: _categories!
          .map(
            (category) => DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedCategoryId = value),
      validator: (value) => value == null ? 'Kategorija je obavezna.' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      maxLength: 2000,
      decoration: const InputDecoration(
        labelText: 'Opis problema *',
        hintText: 'Opisite problem detaljno...',
        prefixIcon: Icon(LucideIcons.fileText),
        alignLabelWithHint: true,
      ),
      validator: FormValidators.compose([
        (value) => FormValidators.required(value, 'Opis'),
        (value) => FormValidators.length(value, min: 10, max: 2000),
      ]),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: const InputDecoration(
        labelText: 'Adresa',
        hintText: 'Unesite adresu (opcionalno)',
        prefixIcon: Icon(LucideIcons.mapPin),
      ),
      validator: (value) => value != null && value.trim().length > 500
          ? 'Adresa ne moze biti duza od 500 karaktera.'
          : null,
    );
  }
}
