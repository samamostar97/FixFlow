import 'package:fixflow_core/enums/job_status.dart';

class JobStatusHistoryResponse {
  final int id;
  final int bookingId;
  final JobStatus previousStatus;
  final JobStatus newStatus;
  final String? note;
  final int changedById;
  final String changedByFirstName;
  final String changedByLastName;
  final DateTime createdAt;

  JobStatusHistoryResponse({
    required this.id,
    required this.bookingId,
    required this.previousStatus,
    required this.newStatus,
    this.note,
    required this.changedById,
    required this.changedByFirstName,
    required this.changedByLastName,
    required this.createdAt,
  });

  String get changedByFullName => '$changedByFirstName $changedByLastName';

  factory JobStatusHistoryResponse.fromJson(Map<String, dynamic> json) {
    return JobStatusHistoryResponse(
      id: json['id'] as int,
      bookingId: json['bookingId'] as int,
      previousStatus: JobStatus.fromJson(json['previousStatus']),
      newStatus: JobStatus.fromJson(json['newStatus']),
      note: json['note'] as String?,
      changedById: json['changedById'] as int,
      changedByFirstName: json['changedByFirstName'] as String,
      changedByLastName: json['changedByLastName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
