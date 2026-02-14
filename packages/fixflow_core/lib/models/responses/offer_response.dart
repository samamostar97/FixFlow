import 'package:fixflow_core/enums/offer_status.dart';
import 'package:fixflow_core/enums/service_type.dart';

class OfferResponse {
  final int id;
  final int repairRequestId;
  final String repairRequestCategoryName;
  final int technicianId;
  final String technicianFirstName;
  final String technicianLastName;
  final double price;
  final int estimatedDays;
  final ServiceType serviceType;
  final String? note;
  final OfferStatus status;
  final DateTime createdAt;

  OfferResponse({
    required this.id,
    required this.repairRequestId,
    required this.repairRequestCategoryName,
    required this.technicianId,
    required this.technicianFirstName,
    required this.technicianLastName,
    required this.price,
    required this.estimatedDays,
    required this.serviceType,
    this.note,
    required this.status,
    required this.createdAt,
  });

  String get technicianFullName => '$technicianFirstName $technicianLastName';

  factory OfferResponse.fromJson(Map<String, dynamic> json) {
    return OfferResponse(
      id: json['id'] as int,
      repairRequestId: json['repairRequestId'] as int,
      repairRequestCategoryName: json['repairRequestCategoryName'] as String,
      technicianId: json['technicianId'] as int,
      technicianFirstName: json['technicianFirstName'] as String,
      technicianLastName: json['technicianLastName'] as String,
      price: (json['price'] as num).toDouble(),
      estimatedDays: json['estimatedDays'] as int,
      serviceType: ServiceType.fromJson(json['serviceType']),
      note: json['note'] as String?,
      status: OfferStatus.fromJson(json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
