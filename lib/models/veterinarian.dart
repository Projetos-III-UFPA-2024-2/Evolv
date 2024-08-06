// lib/models/veterinarian.dart
class Veterinarian {
  String id;
  String name;
  String clinicName;
  String phoneNumber;
  String email;

  Veterinarian({
    required this.id,
    required this.name,
    required this.clinicName,
    required this.phoneNumber,
    required this.email,
  });

  factory Veterinarian.fromMap(Map<String, dynamic> data) {
    return Veterinarian(
      id: data['id'],
      name: data['name'],
      clinicName: data['clinicName'],
      phoneNumber: data['phoneNumber'],
      email: data['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'clinicName': clinicName,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}
