enum JobStatus {
  received,
  diagnostics,
  waitingForPart,
  repaired,
  completed;

  static JobStatus fromJson(dynamic value) {
    if (value is int) {
      return JobStatus.values[value];
    }
    return JobStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      orElse: () => JobStatus.received,
    );
  }

  int toJson() => index;

  String get displayName => switch (this) {
        JobStatus.received => 'Primljeno',
        JobStatus.diagnostics => 'Dijagnostika',
        JobStatus.waitingForPart => 'Čeka dio',
        JobStatus.repaired => 'Popravljeno',
        JobStatus.completed => 'Završeno',
      };

  List<JobStatus> get allowedTransitions => switch (this) {
        JobStatus.received => [JobStatus.diagnostics],
        JobStatus.diagnostics => [JobStatus.waitingForPart, JobStatus.repaired],
        JobStatus.waitingForPart => [JobStatus.repaired],
        JobStatus.repaired => [JobStatus.completed],
        JobStatus.completed => [],
      };
}
