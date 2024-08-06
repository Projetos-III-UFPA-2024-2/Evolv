// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/animal.dart';
import '../models/user.dart';
import '../models/veterinarian.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAnimal(Animal animal) async {
    await _firestore.collection('animals').doc(animal.id).set(animal.toMap());
  }

  Future<void> addUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> addVeterinarian(Veterinarian veterinarian) async {
    await _firestore
        .collection('veterinarians')
        .doc(veterinarian.id)
        .set(veterinarian.toMap());
  }

  Stream<List<Animal>> getAnimals() {
    return _firestore.collection('animals').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Animal.fromMap(doc.data())).toList();
    });
  }

  // Outros métodos para lidar com a lógica de adoção, notificações, etc.
}
