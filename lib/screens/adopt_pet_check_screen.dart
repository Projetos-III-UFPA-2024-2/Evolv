import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pre_adoption_form_screen.dart';
import 'adopt_pet_screen.dart';

class AdoptPetCheckScreen extends StatefulWidget {
  @override
  _AdoptPetCheckScreenState createState() => _AdoptPetCheckScreenState();
}

class _AdoptPetCheckScreenState extends State<AdoptPetCheckScreen> {
  bool _isLoading = true;
  bool _hasFilledForm = false;
  String? _city;
  String? _neighborhood;

  @override
  void initState() {
    super.initState();
    _checkForm();
  }

  Future<void> _checkForm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('form_responses')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _hasFilledForm = true;
          _city = doc['city'];
          _neighborhood = doc['neighborhood'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adote um Pet'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade700, // Cor roxa para o AppBar
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _hasFilledForm
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors
                                .deepPurple.shade700, // Icone com cor roxa
                            size: 80,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Você já preencheu o formulário. Deseja preenchê-lo novamente ou pular para a adoção de pets?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800], // Texto com cor suave
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PreAdoptionFormScreen()),
                              );
                            },
                            icon: Icon(Icons.edit),
                            label: Text('Preencher Formulário Novamente'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .deepPurple.shade700, // Botão roxo escuro
                              foregroundColor: Colors.white,
                              minimumSize:
                                  Size(double.infinity, 50), // Largura total
                              padding: EdgeInsets.symmetric(vertical: 14),
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
                                  builder: (context) => AdoptPetScreen(
                                    city: _city!,
                                    neighborhood: _neighborhood!,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.pets),
                            label: Text('Pular para Adoção'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple
                                  .shade700, // Tom mais claro de roxo
                              foregroundColor: Colors.white,
                              minimumSize:
                                  Size(double.infinity, 50), // Largura total
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PreAdoptionFormScreen()),
                          );
                        },
                        icon: Icon(Icons.assignment),
                        label: Text('Preencher Formulário de Pré-Adoção'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.deepPurple.shade700, // Botão com cor roxa
                          foregroundColor: Colors.white,
                          minimumSize:
                              Size(double.infinity, 50), // Largura total
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
              ),
            ),
    );
  }
}
