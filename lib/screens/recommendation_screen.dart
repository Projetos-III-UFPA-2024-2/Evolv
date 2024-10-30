import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final String city;
  final String neighborhood;

  HomePage({required this.city, required this.neighborhood});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> recommendedPets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    final String apiUrl =
        'http://ipet-env.eba-ummbhmx6.us-east-1.elasticbeanstalk.com/recommend';

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Obter a preferência do Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('form_responses')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          // Verifica se o documento existe e obtém a preferência do pet
          final userData = userDoc.data()!;
          final String petPreference =
              userData['petPreference'] ?? 'Cachorro'; // Padrão para 'Cachorro'

          // Validação de cidade e bairro
          if (widget.city.isEmpty || widget.neighborhood.isEmpty) {
            print('Cidade ou bairro inválidos.');
            setState(() {
              isLoading = false;
            });
            return;
          }

          final response = await http.post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': currentUser.uid,
              'city': widget.city,
              'neighborhood': widget.neighborhood,
              'petPreference':
                  petPreference, // Enviar a preferência do pet do Firestore
            }),
          );

          if (response.statusCode == 200) {
            try {
              final decodedResponse = jsonDecode(response.body);
              setState(() {
                recommendedPets = decodedResponse;
                isLoading = false;
              });
            } catch (e) {
              print('Erro ao decodificar resposta: $e');
              setState(() {
                isLoading = false;
              });
            }
          } else {
            print('Erro na requisição: ${response.statusCode}');
            setState(() {
              isLoading = false;
            });
          }
        } else {
          print('Preferências do usuário não encontradas.');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Usuário não autenticado.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exceção ao fazer a requisição: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: isLoading
          ? Center(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Carregando recomendações..."),
              ],
            ))
          : recommendedPets.isEmpty
              ? Center(child: Text('Nenhum pet recomendado encontrado.'))
              : RecommendationScreen(recommendedPets: recommendedPets),
    );
  }
}

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
                // Ação ao tocar no item
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Você selecionou $name'),
                ));
              },
            ),
          );
        },
      ),
    );
  }
}
