enum ServiceType {
  onSite,
  inShop;

  static ServiceType fromJson(dynamic value) {
    if (value is int) {
      return ServiceType.values[value];
    }
    return ServiceType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      orElse: () => ServiceType.onSite,
    );
  }

  int toJson() => index;

  String get displayName => switch (this) {
        ServiceType.onSite => 'Na licu mjesta',
        ServiceType.inShop => 'U servisu',
      };
}
