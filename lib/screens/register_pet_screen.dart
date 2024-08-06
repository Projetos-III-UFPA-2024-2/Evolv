import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/animal.dart';

class RegisterPetScreen extends StatefulWidget {
  @override
  _RegisterPetScreenState createState() => _RegisterPetScreenState();
}

class _RegisterPetScreenState extends State<RegisterPetScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String breed = '';
  String age = '';
  bool hasDisability = false;
  bool isVaccinated = false;
  bool isNeutered = false;
  String city = '';
  String neighborhood = '';
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _image != null) {
      _formKey.currentState!.save();

      try {
        final user = FirebaseAuth.instance.currentUser;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('animal_images')
            .child('${DateTime.now().toIso8601String()}.jpg');
        await storageRef.putFile(_image!);
        final imageUrl = await storageRef.getDownloadURL();

        final newAnimal = Animal(
          id: FirebaseFirestore.instance.collection('animals').doc().id,
          name: name,
          breed: breed,
          age: age,
          hasDisability: hasDisability,
          isVaccinated: isVaccinated,
          isNeutered: isNeutered,
          photoUrl: imageUrl,
          ownerId: user!.uid,
          city: city,
          neighborhood: neighborhood,
        );

        await FirebaseFirestore.instance
            .collection('animals')
            .doc(newAnimal.id)
            .set(newAnimal.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pet cadastrado com sucesso!'),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar animal.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Por favor, preencha todos os campos e selecione uma imagem.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Animal'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome do animal'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira o nome do animal';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Raça'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira a raça do animal';
                  }
                  return null;
                },
                onSaved: (value) {
                  breed = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Idade'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira a idade do animal';
                  }
                  return null;
                },
                onSaved: (value) {
                  age = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cidade'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira a cidade do animal';
                  }
                  return null;
                },
                onSaved: (value) {
                  city = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Bairro'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira o bairro do animal';
                  }
                  return null;
                },
                onSaved: (value) {
                  neighborhood = value!;
                },
              ),
              SwitchListTile(
                title: Text('Possui alguma deficiência'),
                value: hasDisability,
                onChanged: (value) {
                  setState(() {
                    hasDisability = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Vacinado'),
                value: isVaccinated,
                onChanged: (value) {
                  setState(() {
                    isVaccinated = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Castrado'),
                value: isNeutered,
                onChanged: (value) {
                  setState(() {
                    isNeutered = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextButton.icon(
                icon: Icon(Icons.image),
                label: Text('Anexar Foto'),
                onPressed: _pickImage,
              ),
              if (_image != null)
                Image.file(
                  _image!,
                  height: 150,
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Cadastrar Animal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
