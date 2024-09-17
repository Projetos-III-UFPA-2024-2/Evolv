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

  // Controladores para os campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();

  String breed = 'Não tenho';
  String gender = 'Macho'; // Novo campo para gênero
  bool hasDisability = false;
  bool isVaccinated = false;
  bool isNeutered = false;
  String petType = 'Cachorro'; // Tipo de animal
  File? _image;
  final picker = ImagePicker();

  final List<String> dogBreeds = [
    'Não tenho',
    'Outro',
    'Labrador Retriever',
    'Golden Retriever',
    'Pastor Alemão',
    'Bulldog',
    'Beagle',
    'Poodle',
    'Yorkshire Terrier',
    'Boxer',
    'Dachshund',
    'Chihuahua',
    'Schnauzer',
    'Shih Tzu',
    'Cocker Spaniel',
  ];

  final List<String> catBreeds = [
    'Não tenho',
    'Outro',
    'Persa',
    'Siamês',
    'Maine Coon',
    'Ragdoll',
    'Bengal',
    'Sphynx',
    'British Shorthair',
    'Abyssinian',
    'Sibirian',
    'Oriental',
    'Scottish Fold',
    'Devon Rex',
    'Manx',
  ];

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('Nenhuma imagem selecionada.');
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _image != null) {
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
          name: _nameController.text,
          breed: breed,
          age: _ageController.text,
          hasDisability: hasDisability,
          isVaccinated: isVaccinated,
          isNeutered: isNeutered,
          photoUrl: imageUrl,
          ownerId: user!.uid,
          city: _cityController.text,
          neighborhood: _neighborhoodController.text,
          gender: gender, // Incluindo o campo de gênero
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
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Animal'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // Cor do AppBar
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Por favor, preencha os detalhes do animal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              SwitchListTile(
                title: Text('Cachorro'),
                value: petType == 'Cachorro',
                onChanged: (value) {
                  setState(() {
                    petType = 'Cachorro';
                    breed = 'Não tenho';
                  });
                },
                secondary: Icon(Icons.pets),
              ),
              SwitchListTile(
                title: Text('Gato'),
                value: petType == 'Gato',
                onChanged: (value) {
                  setState(() {
                    petType = 'Gato';
                    breed = 'Não tenho';
                  });
                },
                secondary: Icon(Icons.pets),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gênero',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                value: gender,
                items: ['Macho', 'Fêmea'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    gender = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do animal',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira o nome do animal';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Raça',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                value: breed,
                items: (petType == 'Cachorro' ? dogBreeds : catBreeds)
                    .map((breed) => DropdownMenuItem<String>(
                          child: Text(breed),
                          value: breed,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    breed = value!;
                  });
                },
              ),
              if (breed == 'Outro')
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Digite a raça',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onSaved: (value) {
                      breed = value!;
                    },
                  ),
                ),
              SizedBox(height: 20),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Idade (meses/anos)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  prefixIcon: Icon(Icons.cake),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira a idade do animal';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira a cidade do animal';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _neighborhoodController,
                decoration: InputDecoration(
                  labelText: 'Bairro',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira o bairro do animal';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              SwitchListTile(
                title: Text('Possui alguma deficiência'),
                value: hasDisability,
                onChanged: (value) {
                  setState(() {
                    hasDisability = value;
                  });
                },
                secondary: Icon(Icons.accessible),
              ),
              SwitchListTile(
                title: Text('Vacinado'),
                value: isVaccinated,
                onChanged: (value) {
                  setState(() {
                    isVaccinated = value;
                  });
                },
                secondary: Icon(Icons.vaccines),
              ),
              SwitchListTile(
                title: Text('Castrado'),
                value: isNeutered,
                onChanged: (value) {
                  setState(() {
                    isNeutered = value;
                  });
                },
                secondary: Icon(Icons.health_and_safety),
              ),
              SizedBox(height: 20),
              TextButton.icon(
                icon: Icon(Icons.image),
                label: Text('Anexar Foto'),
                onPressed: _pickImage,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Image.file(
                    _image!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Cadastrar Animal',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
