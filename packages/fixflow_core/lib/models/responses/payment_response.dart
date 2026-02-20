import 'package:fixflow_core/enums/payment_status.dart';
import 'package:fixflow_core/enums/payment_type.dart';

class PaymentResponse {
  final int id;
  final int bookingId;
  final int userId;
  final String userFirstName;
  final String userLastName;
  final double amount;
  final PaymentType type;
  final PaymentStatus status;
  final String? stripePaymentIntentId;
  final String? stripeSessionId;
  final DateTime createdAt;

  PaymentResponse({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    required this.amount,
    required this.type,
    required this.status,
    this.stripePaymentIntentId,
    this.stripeSessionId,
    required this.createdAt,
  });

  String get userFullName => '$userFirstName $userLastName';

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      id: json['id'] as int,
      bookingId: json['bookingId'] as int,
      userId: json['userId'] as int,
      userFirstName: json['userFirstName'] as String,
      userLastName: json['userLastName'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: PaymentType.fromJson(json['type']),
      status: PaymentStatus.fromJson(json['status']),
      stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
      stripeSessionId: json['stripeSessionId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
