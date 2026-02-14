enum OfferStatus {
  pending,
  accepted,
  rejected,
  withdrawn;

  static OfferStatus fromJson(dynamic value) {
    if (value is int) {
      return OfferStatus.values[value];
    }
    return OfferStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      orElse: () => OfferStatus.pending,
    );
  }

  int toJson() => index;

  String get displayName => switch (this) {
        OfferStatus.pending => 'Na čekanju',
        OfferStatus.accepted => 'Prihvaćena',
        OfferStatus.rejected => 'Odbijena',
        OfferStatus.withdrawn => 'Povučena',
      };
}
