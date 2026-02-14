enum RepairRequestStatus {
  open,
  offered,
  accepted,
  inProgress,
  completed,
  cancelled;

  static RepairRequestStatus fromJson(dynamic value) {
    if (value is int) {
      return RepairRequestStatus.values[value];
    }
    return RepairRequestStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      orElse: () => RepairRequestStatus.open,
    );
  }

  int toJson() => index;

  String get displayName => switch (this) {
        RepairRequestStatus.open => 'Otvoren',
        RepairRequestStatus.offered => 'Ima ponude',
        RepairRequestStatus.accepted => 'Prihvaćen',
        RepairRequestStatus.inProgress => 'U toku',
        RepairRequestStatus.completed => 'Završen',
        RepairRequestStatus.cancelled => 'Otkazan',
      };
}
