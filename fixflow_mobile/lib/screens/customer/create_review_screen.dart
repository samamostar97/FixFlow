import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/constants/app_spacing.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_form_sections.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_snackbar.dart';
import 'package:fixflow_mobile/widgets/shared/star_rating_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CreateReviewScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final String technicianName;

  const CreateReviewScreen({
    super.key,
    required this.bookingId,
    required this.technicianName,
  });

  @override
  ConsumerState<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends ConsumerState<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int? _rating;
  bool _isSubmitting = false;
  bool _hasAttemptedSubmit = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _hasAttemptedSubmit = true);

    if (!_formKey.currentState!.validate() || _rating == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(reviewServiceProvider).create(
            CreateReviewRequest(
              bookingId: widget.bookingId,
              rating: _rating!,
              comment: _commentController.text.trim().isEmpty
                  ? null
                  : _commentController.text.trim(),
            ),
          );

      if (!mounted) return;
      MobileSnackbar.success(context, 'Ocjena je uspjesno poslana.');
      Navigator.of(context).pop(true);
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
    return MobilePageScaffold(
      title: 'Ostavi ocjenu',
      subtitle: 'Majstor: ${widget.technicianName}',
      scrollable: true,
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: MobileFormSectionCard(
        title: 'Recenzija',
        subtitle: 'Ocijenite kvalitet usluge.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StarRatingInput(
              value: _rating,
              onChanged: (value) => setState(() => _rating = value),
              errorText: _hasAttemptedSubmit && _rating == null
                  ? 'Ocjena je obavezna.'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCommentField(),
            const SizedBox(height: AppSpacing.lg),
            MobileFormSubmitButton(
              isLoading: _isSubmitting,
              label: 'Posalji ocjenu',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentField() {
    return TextFormField(
      controller: _commentController,
      maxLines: 4,
      maxLength: 1000,
      decoration: const InputDecoration(
        labelText: 'Komentar (opcionalno)',
        hintText: 'Opisite vase iskustvo...',
        prefixIcon: Icon(LucideIcons.messageSquare),
        alignLabelWithHint: true,
      ),
      validator: (value) => FormValidators.length(value, max: 1000),
    );
  }
}
