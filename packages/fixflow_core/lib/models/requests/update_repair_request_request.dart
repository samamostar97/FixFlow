class UpdateRepairRequestRequest {
  final int? categoryId;
  final String? description;
  final int? preferenceType;
  final double? latitude;
  final double? longitude;
  final String? address;

  UpdateRepairRequestRequest({
    this.categoryId,
    this.description,
    this.preferenceType,
    this.latitude,
    this.longitude,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        if (categoryId != null) 'categoryId': categoryId,
        if (description != null) 'description': description,
        if (preferenceType != null) 'preferenceType': preferenceType,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (address != null) 'address': address,
      };
}
