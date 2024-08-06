import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/animal.dart';
import '../widgets/animal_card.dart';

class AdoptPetScreen extends StatefulWidget {
  final String city;
  final String neighborhood; // Adicionar bairro como informação adicional

  AdoptPetScreen({required this.city, required this.neighborhood});

  @override
  _AdoptPetScreenState createState() => _AdoptPetScreenState();
}

class _AdoptPetScreenState extends State<AdoptPetScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Animal> animals = [];
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
  }

  Future<void> _fetchAnimals() async {
    try {
      final snapshot = await _firestore
          .collection('animals')
          .where('city', isEqualTo: widget.city)
          .get();

      // Convert Firestore snapshot to a list of Animal objects
      final List<Animal> allAnimals = snapshot.docs.map((doc) {
        print('Document data: ${doc.data()}'); // Debug: Print document data
        return Animal.fromMap(doc.data());
      }).toList();

      setState(() {
        animals = allAnimals;
        isLoading = false;
      });

      print(
          'Animals fetched: ${animals.length}'); // Debug: Print number of animals fetched
    } catch (e) {
      print('Error fetching animals: $e'); // Debug: Print any errors
    }
  }

  void _likeAnimal() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Você curtiu ${animals[currentIndex].name}')),
    );
  }

  void _wantToAdoptAnimal() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Você quer adotar ${animals[currentIndex].name}')),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adote um Pet'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : animals.isEmpty
              ? Center(child: Text('Nenhum animal encontrado na sua cidade.'))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AnimalCard(
                        animal: animals[currentIndex],
                        onLike: _likeAnimal,
                        onAdopt: _wantToAdoptAnimal,
                        onDislike: _nextAnimal,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: _nextAnimal,
                            child: Text('Próximo'),
                          ),
                          ElevatedButton(
                            onPressed: _wantToAdoptAnimal,
                            child: Text('Quero Adotar'),
                          ),
                          ElevatedButton(
                            onPressed: _likeAnimal,
                            child: Text('Curtir'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
