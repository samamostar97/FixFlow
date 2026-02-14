class CreateRepairRequestRequest {
  final int categoryId;
  final String description;
  final int preferenceType;
  final double? latitude;
  final double? longitude;
  final String? address;

  CreateRepairRequestRequest({
    required this.categoryId,
    required this.description,
    required this.preferenceType,
    this.latitude,
    this.longitude,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'description': description,
        'preferenceType': preferenceType,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (address != null) 'address': address,
      };
}
