class CreateTechnicianProfileRequest {
  final int userId;
  final String? bio;
  final String? specialties;
  final String? workingHours;
  final String? zone;

  CreateTechnicianProfileRequest({
    required this.userId,
    this.bio,
    this.specialties,
    this.workingHours,
    this.zone,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        if (bio != null) 'bio': bio,
        if (specialties != null) 'specialties': specialties,
        if (workingHours != null) 'workingHours': workingHours,
        if (zone != null) 'zone': zone,
      };
}
