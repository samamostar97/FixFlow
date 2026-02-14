class UpdateJobStatusRequest {
  final int newStatus;
  final String? note;

  UpdateJobStatusRequest({
    required this.newStatus,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'newStatus': newStatus,
        if (note != null) 'note': note,
      };
}
