import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TechnicianProfileState {
  final TechnicianProfileResponse? profile;
  final bool isLoading;
  final String? error;

  const TechnicianProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  TechnicianProfileState copyWith({
    TechnicianProfileResponse? profile,
    bool? isLoading,
    String? error,
  }) {
    return TechnicianProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TechnicianProfileNotifier extends Notifier<TechnicianProfileState> {
  @override
  TechnicianProfileState build() => const TechnicianProfileState();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(technicianProfileServiceProvider);
      final profile = await service.getMyProfile();
      state = TechnicianProfileState(profile: profile);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<bool> update(UpdateTechnicianProfileRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(technicianProfileServiceProvider);
      final profile = await service.updateMyProfile(request);
      state = TechnicianProfileState(profile: profile);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }
}

final technicianProfileProvider =
    NotifierProvider<TechnicianProfileNotifier, TechnicianProfileState>(
      TechnicianProfileNotifier.new,
    );
