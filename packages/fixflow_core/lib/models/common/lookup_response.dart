class LookupResponse {
  final int id;
  final String name;

  LookupResponse({required this.id, required this.name});

  factory LookupResponse.fromJson(Map<String, dynamic> json) {
    return LookupResponse(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
    );
  }
}
