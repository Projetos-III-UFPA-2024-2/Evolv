// lib/models/user.dart
class User {
  String id;
  String name;
  String email;
  String phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
