class CheckoutResponse {
  final String clientSecret;
  final String paymentIntentId;
  final double amount;

  CheckoutResponse({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.amount,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      clientSecret: json['clientSecret'] as String,
      paymentIntentId: json['paymentIntentId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
