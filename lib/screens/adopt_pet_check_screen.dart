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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_hasFilledForm)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Você já preencheu o formulário. Deseja preenchê-lo novamente ou pular para a adoção de pets?',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PreAdoptionFormScreen()),
                            );
                          },
                          child: Text('Preencher Formulário Novamente'),
                        ),
                        ElevatedButton(
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
                          child: Text('Pular para Adoção'),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PreAdoptionFormScreen()),
                      );
                    },
                    child: Text('Preencher Formulário de Pré-Adoção'),
                  ),
              ],
            ),
    );
  }
}
