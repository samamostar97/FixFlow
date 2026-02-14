class CreateOfferRequest {
  final int repairRequestId;
  final double price;
  final int estimatedDays;
  final int serviceType;
  final String? note;

  CreateOfferRequest({
    required this.repairRequestId,
    required this.price,
    required this.estimatedDays,
    required this.serviceType,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'repairRequestId': repairRequestId,
        'price': price,
        'estimatedDays': estimatedDays,
        'serviceType': serviceType,
        if (note != null) 'note': note,
      };
}
