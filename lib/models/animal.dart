import 'package:cloud_firestore/cloud_firestore.dart';

class Animal {
  String id;
  String name;
  String breed;
  String age;
  bool hasDisability;
  bool isVaccinated;
  bool isNeutered;
  String photoUrl;
  String ownerId;
  String city;
  String neighborhood;

  Animal({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.hasDisability,
    required this.isVaccinated,
    required this.isNeutered,
    required this.photoUrl,
    required this.ownerId,
    required this.city,
    required this.neighborhood,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'hasDisability': hasDisability,
      'isVaccinated': isVaccinated,
      'isNeutered': isNeutered,
      'photoUrl': photoUrl,
      'ownerId': ownerId,
      'city': city,
      'neighborhood': neighborhood,
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      name: map['name'],
      breed: map['breed'],
      age: map['age'],
      hasDisability: map['hasDisability'],
      isVaccinated: map['isVaccinated'],
      isNeutered: map['isNeutered'],
      photoUrl: map['photoUrl'],
      ownerId: map['ownerId'],
      city: map['city'],
      neighborhood: map['neighborhood'],
    );
  }
}
