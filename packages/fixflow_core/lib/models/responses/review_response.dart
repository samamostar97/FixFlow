class ReviewResponse {
  final int id;
  final int bookingId;

  final int customerId;
  final String customerFirstName;
  final String customerLastName;

  final int technicianId;
  final String technicianFirstName;
  final String technicianLastName;

  final int rating;
  final String? comment;

  final DateTime createdAt;

  ReviewResponse({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.customerFirstName,
    required this.customerLastName,
    required this.technicianId,
    required this.technicianFirstName,
    required this.technicianLastName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  String get customerFullName => '$customerFirstName $customerLastName';
  String get technicianFullName => '$technicianFirstName $technicianLastName';

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: json['id'] as int,
      bookingId: json['bookingId'] as int,
      customerId: json['customerId'] as int,
      customerFirstName: json['customerFirstName'] as String,
      customerLastName: json['customerLastName'] as String,
      technicianId: json['technicianId'] as int,
      technicianFirstName: json['technicianFirstName'] as String,
      technicianLastName: json['technicianLastName'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
