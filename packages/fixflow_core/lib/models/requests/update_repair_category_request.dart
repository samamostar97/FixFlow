class UpdateRepairCategoryRequest {
  final String? name;

  UpdateRepairCategoryRequest({this.name});

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
      };
}
