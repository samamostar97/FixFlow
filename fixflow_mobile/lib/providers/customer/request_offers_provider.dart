import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestOffersState {
  final List<OfferResponse> items;
  final bool isLoading;
  final String? error;

  RequestOffersState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });
}

class RequestOffersNotifier extends FamilyNotifier<RequestOffersState, int> {
  @override
  RequestOffersState build(int arg) => RequestOffersState();

  Future<void> load() async {
    state = RequestOffersState(isLoading: true);
    try {
      final service = ref.read(offerServiceProvider);
      final items = await service.getOffersForRequest(arg);
      state = RequestOffersState(items: items);
    } on ApiException catch (e) {
      state = RequestOffersState(error: e.message);
    }
  }

  Future<void> acceptOffer(int offerId) async {
    final service = ref.read(offerServiceProvider);
    await service.accept(offerId);
    await load();
  }
}

final requestOffersProvider =
    NotifierProvider.family<RequestOffersNotifier, RequestOffersState, int>(
      RequestOffersNotifier.new,
    );
