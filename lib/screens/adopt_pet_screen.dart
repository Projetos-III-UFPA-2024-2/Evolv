import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/animal.dart';
import '../widgets/animal_card.dart';
import 'liked_pets_screen.dart';
import 'interested_users_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdoptPetScreen extends StatefulWidget {
  final String city;
  final String neighborhood;

  AdoptPetScreen({required this.city, required this.neighborhood});

  @override
  _AdoptPetScreenState createState() => _AdoptPetScreenState();
}

class _AdoptPetScreenState extends State<AdoptPetScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Animal> animals = [];
  List<Animal> likedAnimals = [];
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendedAnimals();
  }

  Future<void> _fetchRecommendedAnimals() async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Obter recomendações da API Flask
        List<Animal> recommendations = await fetchRecommendations(
          currentUser.uid,
          widget.city,
          widget.neighborhood,
        );

        setState(() {
          animals = recommendations;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Você precisa estar logado para ver as recomendações.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Erro ao carregar recomendações: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar recomendações.')),
      );
    }
  }

  Future<List<Animal>> fetchRecommendations(
      String userId, String city, String neighborhood) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'city': city,
        'neighborhood': neighborhood,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // Adicionar prints para verificar os dados recebidos
      for (var animalData in data) {
        print('Dados do animal recebido: $animalData');
      }

      return data.map((animalData) => Animal.fromMap(animalData)).toList();
    } else {
      throw Exception('Falha ao carregar recomendações');
    }
  }

  double _calculateCompatibility(
      Animal animal, Map<String, dynamic> adopterData) {
    double compatibility = 100;

    // Verificação da cidade
    if (adopterData['city'] != null && adopterData['city'] != animal.city) {
      compatibility -=
          20; // Diminui a compatibilidade se a cidade não corresponder.
    }

    // Verificação do bairro
    if (adopterData['neighborhood'] != null &&
        adopterData['neighborhood'] != animal.neighborhood) {
      compatibility -=
          15; // Diminui a compatibilidade se o bairro não corresponder.
    }

    // Verificação do tempo disponível
    if (adopterData['timeAvailable'] != null) {
      int timeAvailable = int.tryParse(adopterData['timeAvailable']) ?? 0;

      if (timeAvailable >= 20) {
        compatibility +=
            10; // Aumenta a compatibilidade se o adotante tem 20 horas ou mais disponíveis por semana.
      } else if (timeAvailable >= 10) {
        compatibility +=
            5; // Aumenta a compatibilidade se o adotante tem 10-19 horas disponíveis por semana.
      } else {
        compatibility -=
            10; // Diminui a compatibilidade se o adotante tem menos de 10 horas disponíveis por semana.
      }
    }

    return compatibility.clamp(
        0, 100); // Garante que a compatibilidade esteja entre 0 e 100.
  }

  void _wantToAdoptAnimal() async {
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

        // Calcular compatibilidade
        double compatibility =
            _calculateCompatibility(animals[currentIndex], adopterData!);

        // Verificar se o contato é email ou telefone
        String adopterContact = adopterData['email'] != null &&
                adopterData['email'].isNotEmpty
            ? adopterData['email']
            : adopterData['phone'] != null && adopterData['phone'].isNotEmpty
                ? adopterData['phone']
                : 'Contato não fornecido';

        // Adicionar prints para depuração
        print('Animal ID: ${animals[currentIndex].id}');
        print('Animal Owner ID: ${animals[currentIndex].ownerId}');
        print('Adopter ID: ${currentUser.uid}');
        print('Adopter Data: $adopterData');

        // Adicionar solicitação de adoção ao Firestore
        await FirebaseFirestore.instance.collection('adoption_requests').add({
          'petId': animals[currentIndex].id,
          'petName': animals[currentIndex].name,
          'petOwnerId': animals[currentIndex].ownerId,
          'adopterId': currentUser.uid,
          'adopterName': adopterData['name'] ?? 'Usuário',
          'adopterContact': adopterContact,
          'compatibility': compatibility,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Solicitação de adoção para ${animals[currentIndex].name} enviada com sucesso!',
            ),
          ),
        );
        _nextAnimal();
      } catch (e) {
        print('Erro ao processar solicitação de adoção: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar a solicitação de adoção.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Você precisa estar logado para adotar um pet.')),
      );
    }
  }

  void _likeAnimal() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        // Salvar a curtida no Firestore
        await _firestore.collection('liked_pets').add({
          'userId': currentUser.uid,
          'petId': animals[currentIndex].id,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Você curtiu ${animals[currentIndex].name}!')),
        );

        setState(() {
          likedAnimals.add(animals[currentIndex]);
          _nextAnimal();
        });
      } catch (e) {
        print('Erro ao curtir o animal: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao curtir o animal.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Você precisa estar logado para curtir um pet.')),
      );
    }
  }

  void _nextAnimal() {
    setState(() {
      if (currentIndex < animals.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
    });
  }

  void _showLikedPets() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LikedPetsScreen(
          likedAnimals: likedAnimals,
          onAdopt: (animal) {
            setState(() {
              likedAnimals.remove(animal);
            });
          },
        ),
      ),
    );
  }

  void _showInterestedUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterestedUsersScreen(
          animal: animals[currentIndex],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adote um Pet'),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: _showLikedPets,
              ),
              if (likedAnimals.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${likedAnimals.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : animals.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum animal encontrado nas suas recomendações.',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: AnimalCard(
                        animal: animals[currentIndex],
                        onLike: _likeAnimal,
                        onNext: _nextAnimal,
                        onAdopt: _wantToAdoptAnimal,
                        onDislike: _nextAnimal,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _nextAnimal,
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            label: Text('Próximo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              textStyle: TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _likeAnimal,
                            icon: Icon(Icons.thumb_up, color: Colors.white),
                            label: Text('Curtir'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              textStyle: TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _wantToAdoptAnimal,
                            icon: Icon(Icons.pets, color: Colors.white),
                            label: Text('Adotar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              textStyle: TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
