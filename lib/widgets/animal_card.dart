import 'package:flutter/material.dart';
import '../models/animal.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onLike;
  final VoidCallback onAdopt;
  final VoidCallback onDislike;

  AnimalCard({
    required this.animal,
    required this.onLike,
    required this.onAdopt,
    required this.onDislike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(animal.photoUrl),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Centraliza os textos
                  children: [
                    Text(
                      animal.name,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center, // Centraliza o texto
                    ),
                    SizedBox(height: 8),
                    Text('Idade: ${animal.age}', textAlign: TextAlign.center),
                    Text('Raça: ${animal.breed}', textAlign: TextAlign.center),
                    Text('Deficiência: ${animal.hasDisability ? "Sim" : "Não"}',
                        textAlign: TextAlign.center),
                    Text('Vacinado: ${animal.isVaccinated ? "Sim" : "Não"}',
                        textAlign: TextAlign.center),
                    Text('Castrado: ${animal.isNeutered ? "Sim" : "Não"}',
                        textAlign: TextAlign.center),
                    Text('Cidade: ${animal.city}', textAlign: TextAlign.center),
                    Text('Bairro: ${animal.neighborhood}',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: onDislike,
                  icon: Icon(Icons.thumb_down, color: Colors.red),
                  label: Text(''),
                ),
                ElevatedButton.icon(
                  onPressed: onAdopt,
                  icon: Icon(Icons.favorite, color: Colors.green),
                  label: Text(''),
                ),
                ElevatedButton.icon(
                  onPressed: onLike,
                  icon: Icon(Icons.thumb_up, color: Colors.blue),
                  label: Text(''),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
