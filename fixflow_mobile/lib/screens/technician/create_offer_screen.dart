import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_spacing.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_form_sections.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CreateOfferScreen extends ConsumerStatefulWidget {
  final int repairRequestId;
  final String categoryName;

  const CreateOfferScreen({
    super.key,
    required this.repairRequestId,
    required this.categoryName,
  });

  @override
  ConsumerState<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends ConsumerState<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _daysController = TextEditingController();
  final _noteController = TextEditingController();
  int? _serviceType;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _daysController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final service = ref.read(offerServiceProvider);
      await service.create(
        CreateOfferRequest(
          repairRequestId: widget.repairRequestId,
          price: double.parse(_priceController.text),
          estimatedDays: int.parse(_daysController.text),
          serviceType: _serviceType!,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        ).toJson(),
      );

      if (!mounted) {
        return;
      }
      MobileSnackbar.success(context, 'Ponuda je uspjesno poslana.');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      MobileSnackbar.error(context, e.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobilePageScaffold(
      title: 'Nova ponuda',
      subtitle: 'Zahtjev: ${widget.categoryName}',
      scrollable: true,
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: MobileFormSectionCard(
        title: 'Detalji ponude',
        subtitle: 'Unesite cijenu, rok i tip usluge.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceField(),
            const SizedBox(height: AppSpacing.md),
            _buildDaysField(),
            const SizedBox(height: AppSpacing.md),
            _buildServiceTypeField(),
            const SizedBox(height: AppSpacing.md),
            _buildNoteField(),
            const SizedBox(height: AppSpacing.lg),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Cijena (KM)',
        prefixIcon: Icon(LucideIcons.wallet),
      ),
      validator: FormValidators.compose([
        (value) => FormValidators.required(value, 'Cijena'),
        (value) => FormValidators.range(value, min: 0.01, max: 100000),
      ]),
    );
  }

  Widget _buildDaysField() {
    return TextFormField(
      controller: _daysController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Rok (dani)',
        prefixIcon: Icon(LucideIcons.clock3),
      ),
      validator: FormValidators.compose([
        (value) => FormValidators.required(value, 'Broj dana'),
        (value) => FormValidators.range(value, min: 1, max: 365),
      ]),
    );
  }

  Widget _buildServiceTypeField() {
    return DropdownButtonFormField<int>(
      initialValue: _serviceType,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Tip usluge',
        prefixIcon: Icon(LucideIcons.wrench),
      ),
      items: ServiceType.values
          .map(
            (serviceType) => DropdownMenuItem(
              value: serviceType.index,
              child: Text(serviceType.displayName),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _serviceType = value),
      validator: (value) => value == null ? 'Tip usluge je obavezan.' : null,
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      maxLength: 1000,
      decoration: const InputDecoration(
        labelText: 'Napomena (opcionalno)',
        prefixIcon: Icon(LucideIcons.messageSquare),
        alignLabelWithHint: true,
      ),
      validator: (value) => FormValidators.length(value, max: 1000),
    );
  }

  Widget _buildSubmitButton() {
    return MobileFormSubmitButton(
      isLoading: _isSubmitting,
      label: 'Posalji ponudu',
      onPressed: _submit,
    );
  }
}
