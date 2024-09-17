import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/animal.dart';

class LikedPetsScreen extends StatelessWidget {
  final List<Animal> likedAnimals;
  final ValueChanged<Animal> onAdopt;

  LikedPetsScreen({required this.likedAnimals, required this.onAdopt});

  void _wantToAdoptAnimal(BuildContext context, Animal animal) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        // Buscar dados do adotante do Firestore
        DocumentSnapshot adopterSnapshot = await FirebaseFirestore.instance
            .collection('form_responses')
            .doc(currentUser.uid)
            .get();

        Map<String, dynamic>? adopterData =
            adopterSnapshot.data() as Map<String, dynamic>?;

        if (adopterData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Preencha o formulário de adoção primeiro.')),
          );
          return;
        }

        // Calcular compatibilidade (reaproveitando sua função)
        double compatibility = _calculateCompatibility(animal, adopterData);

        // Verificar se o contato é email ou telefone
        String adopterContact = adopterData['email'] != null &&
                adopterData['email'].isNotEmpty
            ? adopterData['email']
            : adopterData['phone'] != null && adopterData['phone'].isNotEmpty
                ? adopterData['phone']
                : 'Contato não fornecido';

        // Adicionar solicitação de adoção ao Firestore
        await FirebaseFirestore.instance.collection('adoption_requests').add({
          'petId': animal.id,
          'petName': animal.name,
          'petOwnerId': animal.ownerId,
          'adopterId': currentUser.uid,
          'adopterName': adopterData['name'] ?? 'Usuário',
          'adopterContact': adopterContact,
          'compatibility': compatibility,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Solicitação de adoção para ${animal.name} enviada com sucesso!',
            ),
          ),
        );
      } catch (e) {
        print('Erro ao processar solicitação de adoção: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar a solicitação de adoção.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Você precisa estar logado para adotar um pet.'),
        ),
      );
    }
  }

  double _calculateCompatibility(
      Animal animal, Map<String, dynamic> adopterData) {
    double compatibility = 100;

    if (adopterData['city'] != null && adopterData['city'] != animal.city) {
      compatibility -=
          20; // Diminui a compatibilidade se a cidade não corresponder.
    }

    if (adopterData['neighborhood'] != null &&
        adopterData['neighborhood'] != animal.neighborhood) {
      compatibility -=
          15; // Diminui a compatibilidade se o bairro não corresponder.
    }

    if (adopterData['timeAvailable'] != null) {
      int timeAvailable = int.tryParse(adopterData['timeAvailable']) ?? 0;

      if (timeAvailable >= 20) {
        compatibility +=
            10; // Aumenta a compatibilidade se o adotante tem 20 horas ou mais disponíveis.
      } else if (timeAvailable >= 10) {
        compatibility +=
            5; // Aumenta a compatibilidade se o adotante tem 10-19 horas disponíveis.
      } else {
        compatibility -=
            10; // Diminui a compatibilidade se o adotante tem menos de 10 horas disponíveis.
      }
    }

    return compatibility.clamp(
        0, 100); // Garante que a compatibilidade esteja entre 0 e 100.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pets Curtidos'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // AppBar roxo
      ),
      body: likedAnimals.isEmpty
          ? Center(
              child: Text(
                'Nenhum pet curtido ainda.',
                style: TextStyle(
                    fontSize: 18, color: Colors.grey[700]), // Texto mais suave
              ),
            )
          : ListView.builder(
              itemCount: likedAnimals.length,
              itemBuilder: (context, index) {
                final animal = likedAnimals[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        animal.photoUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      animal.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple, // Título com cor roxa
                      ),
                    ),
                    subtitle: Text(
                      'Idade: ${animal.age}\nCidade: ${animal.city}',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors
                              .grey[600]), // Cor mais suave para o subtítulo
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () => _wantToAdoptAnimal(context, animal),
                      icon: Icon(Icons.check_circle),
                      label: Text('Adotar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green, // Botão verde para adotar
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
