import 'dart:convert';
import 'package:fixflow_core/api/api_client.dart';
import 'package:fixflow_core/models/requests/update_profile_request.dart';
import 'package:fixflow_core/models/responses/user_response.dart';

class UserService {
  final ApiClient _client;

  UserService({required ApiClient client}) : _client = client;

  Future<UserResponse> getProfile() async {
    final response = await _client.get('/api/users/me');
    return UserResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<UserResponse> updateProfile(UpdateProfileRequest request) async {
    final response = await _client.put('/api/users/me', body: request.toJson());
    return UserResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
