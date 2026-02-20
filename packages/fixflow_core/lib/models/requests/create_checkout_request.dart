class CreateCheckoutRequest {
  final int bookingId;

  CreateCheckoutRequest({required this.bookingId});

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
      };
}
