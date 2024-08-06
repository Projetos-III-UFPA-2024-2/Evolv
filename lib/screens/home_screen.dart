// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/animal.dart';
import '../widgets/animal_card.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Animal>> _getAnimals() {
    return _firestore.collection('animals').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Animal.fromMap(doc.data())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iPet - Adoção de Animais'),
      ),
      body: StreamBuilder<List<Animal>>(
        stream: _getAnimals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar animais'));
          }
          final animals = snapshot.data ?? [];
          return ListView.builder(
            itemCount: animals.length,
            itemBuilder: (context, index) {
              final animal = animals[index];
              return AnimalCard(
                animal: animal,
                onLike: () {
                  // Lógica para curtir
                },
                onAdopt: () {
                  // Lógica para adotar
                },
                onDislike: () {
                  // Lógica para passar
                },
              );
            },
          );
        },
      ),
    );
  }
}