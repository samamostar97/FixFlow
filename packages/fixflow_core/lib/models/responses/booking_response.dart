import 'package:fixflow_core/enums/job_status.dart';
import 'package:fixflow_core/enums/service_type.dart';
import 'package:fixflow_core/models/responses/job_status_history_response.dart';

class BookingResponse {
  final int id;

  final int repairRequestId;
  final String repairRequestDescription;
  final String repairRequestCategoryName;

  final int offerId;
  final double offerPrice;
  final int offerEstimatedDays;
  final ServiceType offerServiceType;

  final int customerId;
  final String customerFirstName;
  final String customerLastName;
  final String? customerPhone;

  final int technicianId;
  final String technicianFirstName;
  final String technicianLastName;
  final String? technicianPhone;

  final DateTime? scheduledDate;
  final String? scheduledTime;

  final JobStatus jobStatus;

  final String? partsDescription;
  final double? partsCost;

  final double totalAmount;

  final List<JobStatusHistoryResponse> statusHistory;

  final DateTime createdAt;

  BookingResponse({
    required this.id,
    required this.repairRequestId,
    required this.repairRequestDescription,
    required this.repairRequestCategoryName,
    required this.offerId,
    required this.offerPrice,
    required this.offerEstimatedDays,
    required this.offerServiceType,
    required this.customerId,
    required this.customerFirstName,
    required this.customerLastName,
    this.customerPhone,
    required this.technicianId,
    required this.technicianFirstName,
    required this.technicianLastName,
    this.technicianPhone,
    this.scheduledDate,
    this.scheduledTime,
    required this.jobStatus,
    this.partsDescription,
    this.partsCost,
    required this.totalAmount,
    required this.statusHistory,
    required this.createdAt,
  });

  String get customerFullName => '$customerFirstName $customerLastName';
  String get technicianFullName => '$technicianFirstName $technicianLastName';

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: json['id'] as int,
      repairRequestId: json['repairRequestId'] as int,
      repairRequestDescription: json['repairRequestDescription'] as String,
      repairRequestCategoryName: json['repairRequestCategoryName'] as String,
      offerId: json['offerId'] as int,
      offerPrice: (json['offerPrice'] as num).toDouble(),
      offerEstimatedDays: json['offerEstimatedDays'] as int,
      offerServiceType: ServiceType.fromJson(json['offerServiceType']),
      customerId: json['customerId'] as int,
      customerFirstName: json['customerFirstName'] as String,
      customerLastName: json['customerLastName'] as String,
      customerPhone: json['customerPhone'] as String?,
      technicianId: json['technicianId'] as int,
      technicianFirstName: json['technicianFirstName'] as String,
      technicianLastName: json['technicianLastName'] as String,
      technicianPhone: json['technicianPhone'] as String?,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String).toLocal()
          : null,
      scheduledTime: json['scheduledTime'] as String?,
      jobStatus: JobStatus.fromJson(json['jobStatus']),
      partsDescription: json['partsDescription'] as String?,
      partsCost: (json['partsCost'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map((e) => JobStatusHistoryResponse.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          <JobStatusHistoryResponse>[],
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
