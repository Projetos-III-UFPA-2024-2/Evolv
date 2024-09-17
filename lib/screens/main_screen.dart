import 'package:flutter/material.dart';
import 'package:projetoipet/screens/login_screen.dart';
import 'pre_adoption_form_screen.dart';
import 'register_pet_screen.dart';
import 'adopt_pet_check_screen.dart';
import 'interested_users_screen.dart';
import 'veterinarians_menu_screen.dart';
import 'donation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/animal.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Animal> userAnimals = [];
  int interestedUsersCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchOwnerAnimals();
  }

  Future<void> _fetchOwnerAnimals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('animals')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<Animal> animals = [];
        for (var doc in snapshot.docs) {
          final animalData = doc.data();
          animalData['id'] = doc.id; // Adicionar o ID do documento
          animals.add(Animal.fromMap(animalData));
        }

        setState(() {
          userAnimals = animals;
          _fetchInterestedUsersCount();
        });
      }
    } catch (e) {
      print('Erro ao buscar dados: $e');
    }
  }

  Future<void> _fetchInterestedUsersCount() async {
    int totalInterested = 0;
    for (var animal in userAnimals) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('adoption_requests')
            .where('petId', isEqualTo: animal.id)
            .get();
        totalInterested += snapshot.docs.length;
      } catch (e) {
        print('Erro ao buscar interessados: $e');
      }
    }
    setState(() {
      interestedUsersCount = totalInterested;
    });
  }

  void _showUserAnimals() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: userAnimals.length,
          itemBuilder: (context, index) {
            final animal = userAnimals[index];
            return ListTile(
              leading: animal.photoUrl.isNotEmpty
                  ? Image.network(animal.photoUrl, width: 50, height: 50)
                  : Icon(Icons.pets),
              title: Text(animal.name),
              subtitle: Text('Raça: ${animal.breed}'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InterestedUsersScreen(animal: animal),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iPet'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // Cor do AppBar roxa
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdoptPetCheckScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.pets),
                  label: Text('Adote um pet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple.shade700, // Botão roxo mais escuro
                    foregroundColor: Colors.white, // Texto branco
                    minimumSize: Size(double.infinity, 50), // Largura total
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterPetScreen()),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text('Cadastrar animal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple.shade700, // Botão roxo mais escuro
                    foregroundColor: Colors.white, // Texto branco
                    minimumSize: Size(double.infinity, 50), // Largura total
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: userAnimals.isEmpty
                      ? null
                      : () {
                          _showUserAnimals();
                        },
                  icon: Icon(Icons.check_circle),
                  label: Stack(
                    children: [
                      Text('Escolher Adotante'),
                      if (interestedUsersCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color:
                                  Colors.red.shade800, // Vermelho mais escuro
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '$interestedUsersCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Largura total
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    backgroundColor: userAnimals.isEmpty
                        ? Colors.grey.shade400 // Cinza para desabilitado
                        : Colors
                            .blueAccent.shade700, // Azul escuro para habilitado
                    foregroundColor: Colors.white, // Texto branco
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VeterinariansMenuScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.local_hospital),
                  label: Text('Veterinários'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple.shade700, // Botão roxo mais escuro
                    foregroundColor: Colors.white, // Texto branco
                    minimumSize: Size(double.infinity, 50), // Largura total
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonationScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.volunteer_activism),
                  label: Text('Ajude o iPet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple.shade700, // Botão roxo mais escuro
                    foregroundColor: Colors.white, // Texto branco
                    minimumSize: Size(double.infinity, 50), // Largura total
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
