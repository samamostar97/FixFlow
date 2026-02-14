import 'dart:convert';
import 'package:fixflow_core/api/api_client.dart';
import 'package:fixflow_core/models/requests/login_request.dart';
import 'package:fixflow_core/models/requests/register_request.dart';
import 'package:fixflow_core/models/responses/auth_response.dart';
import 'package:fixflow_core/storage/token_storage.dart';

class AuthService {
  final ApiClient _client;
  final TokenStorage _tokenStorage;

  AuthService({
    required ApiClient client,
    required TokenStorage tokenStorage,
  })  : _client = client,
        _tokenStorage = tokenStorage;

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _client.post('/api/auth/register', body: request.toJson());
    final authResponse = AuthResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    await _tokenStorage.saveToken(authResponse.token);
    return authResponse;
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _client.post('/api/auth/login', body: request.toJson());
    final authResponse = AuthResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    await _tokenStorage.saveToken(authResponse.token);
    return authResponse;
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getToken();
    return token != null;
  }
}
