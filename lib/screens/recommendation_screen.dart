import 'package:flutter/material.dart';

class RecommendationScreen extends StatelessWidget {
  final List<dynamic> recommendedPets;

  RecommendationScreen({required this.recommendedPets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pets Recomendados')),
      body: ListView.builder(
        itemCount: recommendedPets.length,
        itemBuilder: (context, index) {
          final pet = recommendedPets[index];

          // Verifica se os dados do pet estão presentes, se não, usa valores padrão.
          final name = pet['name'] ?? 'Nome não disponível';
          final age = pet['age'] ?? 'Idade desconhecida';
          final breed = pet['breed'] ?? 'Raça desconhecida';
          final isVaccinated =
              pet['isVaccinated'] == true ? 'Vacinado' : 'Não vacinado';
          final photoUrl = pet['photoUrl'] ?? '';

          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              leading: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.pets, size: 50),
              title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Idade: $age anos'),
                  Text('Raça: $breed'),
                  Text('Vacinação: $isVaccinated'),
                ],
              ),
              onTap: () {
                // Ação ao tocar no item (caso queira adicionar algo, como abrir detalhes)
              },
            ),
          );
        },
      ),
    );
  }
}
