class CreateRepairCategoryRequest {
  final String name;

  CreateRepairCategoryRequest({required this.name});

  Map<String, dynamic> toJson() => {'name': name};
}
