import 'package:flutter/material.dart';
import 'package:projetoipet/screens/login_screen.dart';
import 'pre_adoption_form_screen.dart';
import 'register_pet_screen.dart';
import 'adopt_pet_check_screen.dart';
import 'veterinarians_menu_screen.dart';
import 'donation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/animal.dart';
import 'ManagePetsScreen.dart' as manage; // Use prefixo para ManagePetsScreen
import 'interested_users_screen.dart'
    as interested; // Use prefixo para InterestedUsersScreen

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
              onTap: () async {
                Navigator.pop(context); // Fechar o modal
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        interested.InterestedUsersScreen(animal: animal),
                  ),
                );

                // Se o animal foi removido, removê-lo da lista de userAnimals
                if (result == true) {
                  setState(() {
                    userAnimals.removeWhere((a) => a.id == animal.id);
                  });
                }
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

  Future<void> _refreshMainScreen() async {
    await _fetchOwnerAnimals();
    setState(() {}); // Garante que a UI seja atualizada após o fetch.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iPet'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
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
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdoptPetCheckScreen(),
                      ),
                    );
                    _refreshMainScreen(); // Atualiza a tela ao voltar
                  },
                  icon: Icon(Icons.pets),
                  label: Text('Adote um pet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPetScreen(),
                      ),
                    );
                    _refreshMainScreen(); // Atualiza após cadastrar um animal
                  },
                  icon: Icon(Icons.add),
                  label: Text('Cadastrar animal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => manage.ManagePetsScreen(
                            ownerId: user.uid, // Use prefixo correto
                          ),
                        ),
                      );
                      _refreshMainScreen(); // Atualiza a tela ao voltar de "Gerenciar animais"
                    }
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Gerenciar animais cadastrados'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
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
                              color: Colors.red.shade800,
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
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    backgroundColor: userAnimals.isEmpty
                        ? Colors.grey.shade400
                        : Colors.blueAccent.shade700,
                    foregroundColor: Colors.white,
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
                    backgroundColor: Colors.deepPurple.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
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
                    backgroundColor: Colors.deepPurple.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
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
