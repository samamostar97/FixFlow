enum UserRole {
  customer,
  technician,
  admin;

  static UserRole fromJson(dynamic value) {
    if (value is int) {
      return UserRole.values[value];
    }
    return UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      orElse: () => UserRole.customer,
    );
  }

  int toJson() => index;
}
