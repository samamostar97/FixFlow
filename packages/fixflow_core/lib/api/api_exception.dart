import 'dart:convert';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  factory ApiException.fromResponse(int statusCode, String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return ApiException(
        statusCode: statusCode,
        message: json['error'] as String? ??
            json['message'] as String? ??
            'Greška: $statusCode',
      );
    } catch (_) {
      return ApiException(
        statusCode: statusCode,
        message: 'Greška: $statusCode',
      );
    }
  }

  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isForbidden => statusCode == 403;
  bool get isUnauthorized => statusCode == 401;
  bool get isBadRequest => statusCode == 400;
  bool get isServerError => statusCode >= 500;

  @override
  String toString() => message;
}
