class RepairCategoryResponse {
  final int id;
  final String name;
  final DateTime createdAt;

  RepairCategoryResponse({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory RepairCategoryResponse.fromJson(Map<String, dynamic> json) {
    return RepairCategoryResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
