import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'adopt_pet_screen.dart';

class PreAdoptionFormScreen extends StatefulWidget {
  @override
  _PreAdoptionFormScreenState createState() => _PreAdoptionFormScreenState();
}

class _PreAdoptionFormScreenState extends State<PreAdoptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String timeAvailable = '';
  String specificBreed = '';
  String city = '';
  String neighborhood = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('form_responses')
          .doc(user!.uid)
          .set({
        'name': name,
        'timeAvailable': timeAvailable,
        'specificBreed': specificBreed,
        'city': city,
        'neighborhood': neighborhood,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Informações salvas com sucesso!'),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdoptPetScreen(
            city: city,
            neighborhood: neighborhood,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário de Pré-Adoção'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Por favor preencha o formulário abaixo para encontrar seu pet ideal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Por favor digite seu nome'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Quanto tempo você tem disponível para dedicar ao pet? (Semanal)',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.start,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Ex: 10 horas',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira o tempo disponível';
                  }
                  return null;
                },
                onSaved: (value) {
                  timeAvailable = value!;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Procura alguma raça de pet específica? Em caso de sim, qual seria?',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.start,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Ex: Labrador',
                ),
                onSaved: (value) {
                  specificBreed = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cidade'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira sua cidade';
                  }
                  return null;
                },
                onSaved: (value) {
                  city = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Bairro'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira seu bairro';
                  }
                  return null;
                },
                onSaved: (value) {
                  neighborhood = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Concluir formulário'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
