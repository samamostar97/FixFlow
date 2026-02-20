class ConfirmPaymentRequest {
  final int bookingId;
  final String paymentIntentId;

  ConfirmPaymentRequest({
    required this.bookingId,
    required this.paymentIntentId,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'paymentIntentId': paymentIntentId,
      };
}
