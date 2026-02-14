import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fixflow_core/api/api_exception.dart';
import 'package:fixflow_core/storage/token_storage.dart';

class ApiClient {
  final String baseUrl;
  final TokenStorage _tokenStorage;
  final http.Client _client;
  void Function()? onUnauthorized;

  ApiClient({
    required this.baseUrl,
    required TokenStorage tokenStorage,
    http.Client? client,
    this.onUnauthorized,
  })  : _tokenStorage = tokenStorage,
        _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await _tokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    final response = await _client.get(uri, headers: await _headers());
    return _handleResponse(response);
  }

  Future<http.Response> post(String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.post(
      uri,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<http.Response> put(String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.put(
      uri,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<http.Response> patch(String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.patch(
      uri,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.delete(uri, headers: await _headers());
    return _handleResponse(response);
  }

  Future<http.Response> multipartPost(
    String path, {
    required List<http.MultipartFile> files,
    String fileField = 'files',
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final token = await _tokenStorage.getToken();
    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.addAll(files);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      final exception = ApiException.fromResponse(response.statusCode, response.body);
      _tokenStorage.clearToken();
      onUnauthorized?.call();
      throw exception;
    }

    if (response.statusCode >= 400) {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }

    return response;
  }
}
