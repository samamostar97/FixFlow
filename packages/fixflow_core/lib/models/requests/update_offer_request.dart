class UpdateOfferRequest {
  final double? price;
  final int? estimatedDays;
  final int? serviceType;
  final String? note;

  UpdateOfferRequest({
    this.price,
    this.estimatedDays,
    this.serviceType,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        if (price != null) 'price': price,
        if (estimatedDays != null) 'estimatedDays': estimatedDays,
        if (serviceType != null) 'serviceType': serviceType,
        if (note != null) 'note': note,
      };
}
