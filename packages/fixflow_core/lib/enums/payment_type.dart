enum PaymentType {
  deposit,
  full,
  parts,
  final_;

  static PaymentType fromJson(dynamic value) {
    if (value is int) {
      return PaymentType.values[value];
    }
    return PaymentType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      orElse: () => PaymentType.full,
    );
  }

  int toJson() => index;

  String get displayName => switch (this) {
        PaymentType.deposit => 'Depozit',
        PaymentType.full => 'Puni iznos',
        PaymentType.parts => 'Dijelovi',
        PaymentType.final_ => 'Finalna uplata',
      };
}
