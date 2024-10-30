import 'package:flutter/material.dart';
import '../models/animal.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  // final VoidCallback onLike; // Não será usado
  // final VoidCallback onNext; // Não será usado
  // final VoidCallback onAdopt; // Não será usado
  // final VoidCallback onDislike; // Não será usado

  AnimalCard({
    required this.animal,
    // required this.onLike, // Não será usado
    // required this.onNext, // Não será usado
    // required this.onAdopt, // Não será usado
    // required this.onDislike, // Não será usado
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(animal.photoUrl),
            SizedBox(height: 20),
            Text(
              animal.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text('Gênero: ${animal.gender}',
                textAlign: TextAlign.center), // Exibindo o gênero do animal
            Text('Idade: ${animal.age}', textAlign: TextAlign.center),
            Text('Raça: ${animal.breed}', textAlign: TextAlign.center),
            Text('Deficiência: ${animal.hasDisability ? 'Sim' : 'Não'}',
                textAlign: TextAlign.center),
            Text('Vacinado: ${animal.isVaccinated ? 'Sim' : 'Não'}',
                textAlign: TextAlign.center),
            Text('Castrado: ${animal.isNeutered ? 'Sim' : 'Não'}',
                textAlign: TextAlign.center),
            Text('Cidade: ${animal.city}', textAlign: TextAlign.center),
            Text('Bairro: ${animal.neighborhood}', textAlign: TextAlign.center),
            SizedBox(height: 20),
            // Comentando a seção de botões
            /*
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: onNext, // Comentado
                  icon: Icon(Icons.skip_next, color: Colors.white),
                  label: Text('Próximo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onLike, // Comentado
                  icon: Icon(Icons.thumb_up, color: Colors.white),
                  label: Text('Curtir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onAdopt, // Comentado
                  icon: Icon(Icons.pets, color: Colors.white),
                  label: Text('Adotar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            */
          ],
        ),
      ),
    );
  }
}
