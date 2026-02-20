class TechnicianProfileResponse {
  final int id;
  final int userId;
  final String userFirstName;
  final String userLastName;
  final String userEmail;
  final String? userPhone;
  final String? bio;
  final String? specialties;
  final String? workingHours;
  final String? zone;
  final bool isVerified;
  final double averageRating;
  final DateTime createdAt;

  TechnicianProfileResponse({
    required this.id,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    required this.userEmail,
    this.userPhone,
    this.bio,
    this.specialties,
    this.workingHours,
    this.zone,
    required this.isVerified,
    required this.averageRating,
    required this.createdAt,
  });

  String get fullName => '$userFirstName $userLastName';

  List<String> get specialtyList =>
      specialties?.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList() ?? <String>[];

  factory TechnicianProfileResponse.fromJson(Map<String, dynamic> json) {
    return TechnicianProfileResponse(
      id: json['id'] as int,
      userId: json['userId'] as int,
      userFirstName: json['userFirstName'] as String,
      userLastName: json['userLastName'] as String,
      userEmail: json['userEmail'] as String,
      userPhone: json['userPhone'] as String?,
      bio: json['bio'] as String?,
      specialties: json['specialties'] as String?,
      workingHours: json['workingHours'] as String?,
      zone: json['zone'] as String?,
      isVerified: json['isVerified'] as bool,
      averageRating: (json['averageRating'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}
