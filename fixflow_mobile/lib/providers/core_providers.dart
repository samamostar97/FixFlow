import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/config/env_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(baseUrl: EnvConfig.apiBaseUrl, tokenStorage: tokenStorage);
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    client: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(client: ref.watch(apiClientProvider));
});

final technicianProfileServiceProvider = Provider<TechnicianProfileService>((
  ref,
) {
  return TechnicianProfileService(client: ref.watch(apiClientProvider));
});

final repairRequestServiceProvider = Provider<RepairRequestService>((ref) {
  return RepairRequestService(client: ref.watch(apiClientProvider));
});

final repairCategoryServiceProvider = Provider<RepairCategoryService>((ref) {
  return RepairCategoryService(client: ref.watch(apiClientProvider));
});

final offerServiceProvider = Provider<OfferService>((ref) {
  return OfferService(client: ref.watch(apiClientProvider));
});

final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService(client: ref.watch(apiClientProvider));
});

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService(client: ref.watch(apiClientProvider));
});

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(client: ref.watch(apiClientProvider));
});
