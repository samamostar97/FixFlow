class RequestImageResponse {
  final int id;
  final String imagePath;
  final String originalFileName;
  final int fileSize;

  RequestImageResponse({
    required this.id,
    required this.imagePath,
    required this.originalFileName,
    required this.fileSize,
  });

  factory RequestImageResponse.fromJson(Map<String, dynamic> json) {
    return RequestImageResponse(
      id: json['id'] as int,
      imagePath: json['imagePath'] as String,
      originalFileName: json['originalFileName'] as String,
      fileSize: json['fileSize'] as int,
    );
  }
}
