import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/animal.dart';

class EditAnimalScreen extends StatefulWidget {
  final Animal animal;

  EditAnimalScreen({required this.animal});

  @override
  _EditAnimalScreenState createState() => _EditAnimalScreenState();
}

class _EditAnimalScreenState extends State<EditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _cityController;
  late TextEditingController _neighborhoodController;

  bool _hasDisability = false;
  bool _isVaccinated = false;
  bool _isNeutered = false;
  String _gender = 'Macho';
  String _breed = 'Não tenho';

  // Lista de raças
  final List<String> _breedOptions = [
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
    'Manx'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.animal.name);
    _ageController = TextEditingController(text: widget.animal.age);
    _cityController = TextEditingController(text: widget.animal.city);
    _neighborhoodController =
        TextEditingController(text: widget.animal.neighborhood);

    _hasDisability = widget.animal.hasDisability;
    _isVaccinated = widget.animal.isVaccinated;
    _isNeutered = widget.animal.isNeutered;
    _gender = widget.animal.gender;
    _breed = widget.animal.breed;
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Atualizar o documento no Firestore
        await FirebaseFirestore.instance
            .collection('animals')
            .doc(widget.animal.id)
            .update({
          'name': _nameController.text,
          'breed': _breed,
          'age': _ageController.text,
          'city': _cityController.text,
          'neighborhood': _neighborhoodController.text,
          'hasDisability': _hasDisability,
          'isVaccinated': _isVaccinated,
          'isNeutered': _isNeutered,
          'gender': _gender,
        });

        // Cria uma instância atualizada do Animal
        Animal updatedAnimal = Animal(
          id: widget.animal.id,
          name: _nameController.text,
          breed: _breed,
          age: _ageController.text,
          hasDisability: _hasDisability,
          isVaccinated: _isVaccinated,
          isNeutered: _isNeutered,
          photoUrl: widget.animal.photoUrl,
          ownerId: widget.animal.ownerId,
          city: _cityController.text,
          neighborhood: _neighborhoodController.text,
          gender: _gender,
        );

        // Retorna o animal atualizado para a tela anterior
        Navigator.pop(context, updatedAnimal);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar as alterações'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Animal'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome do animal'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do animal';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _breed,
                decoration: InputDecoration(labelText: 'Raça'),
                items: _breedOptions.map((breed) {
                  return DropdownMenuItem(
                    value: breed,
                    child: Text(breed),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _breed = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione uma raça';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Idade'),
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(labelText: 'Gênero'),
                items: ['Macho', 'Fêmea']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _gender = value!;
                }),
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'Cidade'),
              ),
              TextFormField(
                controller: _neighborhoodController,
                decoration: InputDecoration(labelText: 'Bairro'),
              ),
              SwitchListTile(
                title: Text('Deficiência'),
                value: _hasDisability,
                onChanged: (value) => setState(() {
                  _hasDisability = value;
                }),
              ),
              SwitchListTile(
                title: Text('Vacinado'),
                value: _isVaccinated,
                onChanged: (value) => setState(() {
                  _isVaccinated = value;
                }),
              ),
              SwitchListTile(
                title: Text('Castrado'),
                value: _isNeutered,
                onChanged: (value) => setState(() {
                  _isNeutered = value;
                }),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
