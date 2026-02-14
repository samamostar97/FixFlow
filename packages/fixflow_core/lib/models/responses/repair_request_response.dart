import 'package:fixflow_core/enums/preference_type.dart';
import 'package:fixflow_core/enums/repair_request_status.dart';
import 'package:fixflow_core/models/responses/request_image_response.dart';

class RepairRequestResponse {
  final int id;
  final int categoryId;
  final String categoryName;
  final int customerId;
  final String customerFirstName;
  final String customerLastName;
  final String customerEmail;
  final String? customerPhone;
  final String description;
  final PreferenceType preferenceType;
  final double? latitude;
  final double? longitude;
  final String? address;
  final RepairRequestStatus status;
  final List<RequestImageResponse> images;
  final DateTime createdAt;

  RepairRequestResponse({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.customerId,
    required this.customerFirstName,
    required this.customerLastName,
    required this.customerEmail,
    this.customerPhone,
    required this.description,
    required this.preferenceType,
    this.latitude,
    this.longitude,
    this.address,
    required this.status,
    required this.images,
    required this.createdAt,
  });

  String get customerFullName => '$customerFirstName $customerLastName';

  factory RepairRequestResponse.fromJson(Map<String, dynamic> json) {
    return RepairRequestResponse(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
      customerId: json['customerId'] as int,
      customerFirstName: json['customerFirstName'] as String,
      customerLastName: json['customerLastName'] as String,
      customerEmail: json['customerEmail'] as String,
      customerPhone: json['customerPhone'] as String?,
      description: json['description'] as String,
      preferenceType: PreferenceType.fromJson(json['preferenceType']),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      status: RepairRequestStatus.fromJson(json['status']),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) =>
                  RequestImageResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <RequestImageResponse>[],
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
