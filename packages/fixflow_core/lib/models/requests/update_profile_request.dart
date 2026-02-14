class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? profileImage;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phone,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phone != null) 'phone': phone,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }
}
