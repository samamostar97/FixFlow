enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded;

  static PaymentStatus fromJson(dynamic value) {
    if (value is int) {
      return PaymentStatus.values[value];
    }
    return PaymentStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      orElse: () => PaymentStatus.pending,
    );
  }

  int toJson() => index;

  String get displayName => switch (this) {
        PaymentStatus.pending => 'Na čekanju',
        PaymentStatus.completed => 'Završena',
        PaymentStatus.failed => 'Neuspješna',
        PaymentStatus.refunded => 'Refundirana',
      };
}
