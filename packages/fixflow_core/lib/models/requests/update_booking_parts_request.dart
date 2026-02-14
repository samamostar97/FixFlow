class UpdateBookingPartsRequest {
  final String partsDescription;
  final double partsCost;

  UpdateBookingPartsRequest({
    required this.partsDescription,
    required this.partsCost,
  });

  Map<String, dynamic> toJson() => {
        'partsDescription': partsDescription,
        'partsCost': partsCost,
      };
}
