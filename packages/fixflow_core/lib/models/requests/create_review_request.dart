class CreateReviewRequest {
  final int bookingId;
  final int rating;
  final String? comment;

  CreateReviewRequest({
    required this.bookingId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'rating': rating,
        if (comment != null) 'comment': comment,
      };
}
