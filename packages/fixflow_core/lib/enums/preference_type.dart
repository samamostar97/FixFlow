enum PreferenceType {
  onSite,
  dropOff;

  static PreferenceType fromJson(dynamic value) {
    if (value is int) {
      return PreferenceType.values[value];
    }
    return PreferenceType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      orElse: () => PreferenceType.onSite,
    );
  }

  int toJson() => index;

  String get displayName => switch (this) {
        PreferenceType.onSite => 'Na licu mjesta',
        PreferenceType.dropOff => 'Donijeti u servis',
      };
}
