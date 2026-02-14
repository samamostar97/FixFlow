import 'package:fixflow_core/enums/user_role.dart';

class UserResponse {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;

  UserResponse({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    this.profileImage,
    required this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      role: UserRole.fromJson(json['role']),
      profileImage: json['profileImage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
