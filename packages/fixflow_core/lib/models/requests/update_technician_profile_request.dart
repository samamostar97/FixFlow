class UpdateTechnicianProfileRequest {
  final String? bio;
  final String? specialties;
  final String? workingHours;
  final String? zone;

  UpdateTechnicianProfileRequest({
    this.bio,
    this.specialties,
    this.workingHours,
    this.zone,
  });

  Map<String, dynamic> toJson() => {
        if (bio != null) 'bio': bio,
        if (specialties != null) 'specialties': specialties,
        if (workingHours != null) 'workingHours': workingHours,
        if (zone != null) 'zone': zone,
      };
}
