class UserProfile {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String city;
  final String role;
  final DateTime? dob;
  final bool isVerified;
  final String bio;

  UserProfile({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.role,
    this.dob,
    required this.isVerified,
    required this.bio,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      city: json['city'] ?? '',
      role: json['role'] ?? 'User',
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      isVerified: json['is_verified'] ?? false,
      bio: json['bio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'city': city,
      'role': role,
      'dob': dob?.toIso8601String().split('T')[0], // Send YYYY-MM-DD
      'is_verified': isVerified,
      'bio': bio,
    };
  }
}
