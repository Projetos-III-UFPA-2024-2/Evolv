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
  String gender; // Novo campo: Macho ou Fêmea

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
    required this.gender, // Inicializando o campo gender
  });

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Sem nome',
      breed: map['breed'] ?? 'Desconhecido',
      age: map['age'] ?? 'Desconhecida',
      hasDisability: map['hasDisability'] == true,
      isVaccinated: map['isVaccinated'] == true,
      isNeutered: map['isNeutered'] == true,
      photoUrl: map['photoUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
      city: map['city'] ?? 'Desconhecida',
      neighborhood: map['neighborhood'] ?? 'Desconhecido',
      gender: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Opcional: remova se o ID não for necessário dentro do documento
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
      'gender': gender, // Incluindo gender no Map
    };
  }
}
