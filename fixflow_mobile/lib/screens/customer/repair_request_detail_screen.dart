import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:fixflow_mobile/providers/customer/request_offers_provider.dart';
import 'package:fixflow_mobile/widgets/shared/confirmation_dialog.dart';
import 'package:fixflow_mobile/widgets/shared/image_picker_section.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_async_state_view.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_snackbar.dart';
import 'package:fixflow_mobile/widgets/shared/repair_request_detail_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RepairRequestDetailScreen extends ConsumerStatefulWidget {
  final int requestId;

  const RepairRequestDetailScreen({super.key, required this.requestId});

  @override
  ConsumerState<RepairRequestDetailScreen> createState() =>
      _RepairRequestDetailScreenState();
}

class _RepairRequestDetailScreenState
    extends ConsumerState<RepairRequestDetailScreen> {
  RepairRequestResponse? _request;
  bool _isLoading = true;
  String? _error;
  bool _changed = false;
  List<XFile> _pickedImages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(repairRequestServiceProvider)
          .getById(widget.requestId);
      if (!mounted) {
        return;
      }
      setState(() {
        _request = result;
        _isLoading = false;
      });
      _loadOffers(result.status);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  void _loadOffers(RepairRequestStatus status) {
    if (status == RepairRequestStatus.offered ||
        status == RepairRequestStatus.accepted) {
      ref.read(requestOffersProvider(widget.requestId).notifier).load();
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Otkazi zahtjev',
      message: 'Da li ste sigurni da zelite otkazati zahtjev?',
      confirmLabel: 'Da, otkazi',
      destructive: true,
    );
    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(repairRequestServiceProvider).cancel(widget.requestId);
      _changed = true;
      ref.invalidate(requestOffersProvider(widget.requestId));
      if (!mounted) {
        return;
      }
      MobileSnackbar.success(context, 'Zahtjev je otkazan.');
      await _load();
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      MobileSnackbar.error(context, e.message);
    }
  }

  Future<void> _uploadPickedImages() async {
    if (_pickedImages.isEmpty) return;
    try {
      final service = ref.read(repairRequestServiceProvider);
      final files = await Future.wait(
        _pickedImages.map((xf) async {
          final bytes = await xf.readAsBytes();
          return http.MultipartFile.fromBytes(
            'files',
            bytes,
            filename: xf.name,
          );
        }),
      );
      await service.uploadImages(widget.requestId, files);
      _changed = true;
      _pickedImages = [];
      if (!mounted) return;
      MobileSnackbar.success(context, 'Slike su uspjesno uploadovane.');
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      MobileSnackbar.error(context, e.message);
    }
  }

  Future<void> _deleteImage(int imageId) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Ukloni sliku',
      message: 'Da li ste sigurni da zelite ukloniti sliku?',
      confirmLabel: 'Da, ukloni',
      destructive: true,
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(repairRequestServiceProvider)
          .deleteImage(widget.requestId, imageId);
      _changed = true;
      if (!mounted) return;
      MobileSnackbar.success(context, 'Slika je uklonjena.');
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      MobileSnackbar.error(context, e.message);
    }
  }

  Future<void> _acceptOffer(OfferResponse offer) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Prihvati ponudu',
      message:
          'Prihvatiti ponudu od ${offer.technicianFullName} za ${CurrencyFormatter.format(offer.price)}?',
      confirmLabel: 'Da, prihvati',
    );
    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(requestOffersProvider(widget.requestId).notifier)
          .acceptOffer(offer.id);
      _changed = true;
      if (!mounted) {
        return;
      }
      MobileSnackbar.success(context, 'Ponuda je prihvacena.');
      await _load();
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      MobileSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobilePageScaffold(
      title: 'Detalji zahtjeva',
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: () => Navigator.of(context).pop(_changed ? true : null),
      ),
      onRefresh: _load,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return MobileAsyncStateView<RepairRequestResponse>(
      isLoading: _isLoading,
      error: _error,
      data: _request,
      onRetry: _load,
      builder: _buildLoadedBody,
      emptyMessage: 'Detalji zahtjeva nisu dostupni.',
    );
  }

  Widget _buildLoadedBody(RepairRequestResponse request) {
    final offersState = ref.watch(requestOffersProvider(widget.requestId));
    final showOffers =
        request.status == RepairRequestStatus.offered ||
        request.status == RepairRequestStatus.accepted;
    final isOpen = request.status == RepairRequestStatus.open;
    final canCancel = isOpen ||
        request.status == RepairRequestStatus.offered;
    final canAccept = request.status == RepairRequestStatus.offered;
    final apiClient = ref.read(apiClientProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        RepairRequestHeaderCard(request: request),
        const SizedBox(height: 12),
        RepairRequestInfoCard(request: request),
        if (isOpen || request.images.isNotEmpty) ...[
          const SizedBox(height: 12),
          if (isOpen)
            MobileSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImagePickerSection(
                    pickedFiles: _pickedImages,
                    existingImages: request.images,
                    baseUrl: apiClient.baseUrl,
                    onPickedChanged: (files) =>
                        setState(() => _pickedImages = files),
                    onExistingRemoved: _deleteImage,
                  ),
                  if (_pickedImages.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _uploadPickedImages,
                        icon: const Icon(LucideIcons.upload, size: 16),
                        label: const Text('Uploaduj slike'),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            RepairRequestImagesCard(
              images: request.images,
              baseUrl: apiClient.baseUrl,
            ),
        ],
        if (showOffers) ...[
          const SizedBox(height: 12),
          RepairRequestOffersCard(
            isLoading: offersState.isLoading,
            error: offersState.error,
            offers: offersState.items,
            canAccept: canAccept,
            onAccept: _acceptOffer,
          ),
        ],
        if (canCancel) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _cancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
            child: const Text('Otkazi zahtjev'),
          ),
        ],
      ],
    );
  }
}
