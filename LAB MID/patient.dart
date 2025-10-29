class Patient {
  final String id;
  String name;
  String phoneNumber;
  String diagnosis;
  String? imagePath;
  DateTime? dateOfBirth;
  String? gender;
  String? address;
  String? email;
  String? recommendedMedicine;
  String? referredDoctor;
  String? precautions;
  DateTime? nextAppointment;

  Patient({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.diagnosis,
    this.imagePath,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.email,
    this.recommendedMedicine,
    this.referredDoctor,
    this.precautions,
    this.nextAppointment,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'diagnosis': diagnosis,
        'imagePath': imagePath,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'address': address,
        'email': email,
        'recommendedMedicine': recommendedMedicine,
        'referredDoctor': referredDoctor,
        'precautions': precautions,
      };

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: json['id'] as String,
        name: json['name'] as String,
        phoneNumber: json['phoneNumber'] as String? ?? 'N/A',
        diagnosis: json['diagnosis'] as String? ?? 'No diagnosis',
        imagePath: json['imagePath'] as String?,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.parse(json['dateOfBirth'] as String)
            : null,
        gender: json['gender'] as String?,
        address: json['address'] as String?,
        email: json['email'] as String?,
        recommendedMedicine: json['recommendedMedicine'] as String?,
        referredDoctor: json['referredDoctor'] as String?,
        precautions: json['precautions'] as String?,
        nextAppointment: json['nextAppointment'] != null
            ? DateTime.parse(json['nextAppointment'] as String)
            : null,
      );
}
