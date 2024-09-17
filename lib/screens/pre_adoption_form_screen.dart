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

  // Controladores para os campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _timeAvailableController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();

  String specificBreed = 'Não tenho';
  String petPreference = 'Cachorro';
  String _selectedContactMethod = 'Email'; // Contato por padrão será email
  String genderPreference = 'Macho'; // Novo campo para preferir macho ou fêmea

  bool isDogPreference() =>
      petPreference == 'Cachorro' || petPreference == 'Ambos';
  bool isCatPreference() => petPreference == 'Gato' || petPreference == 'Ambos';

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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('form_responses')
          .doc(user!.uid)
          .set({
        'name': _nameController.text,
        'phone':
            _selectedContactMethod == 'Telefone' ? _phoneController.text : '',
        'email': _selectedContactMethod == 'Email' ? _emailController.text : '',
        'timeAvailable': _timeAvailableController.text,
        'specificBreed': specificBreed,
        'city': _cityController.text,
        'neighborhood': _neighborhoodController.text,
        'petPreference': petPreference,
        'genderPreference': genderPreference, // Incluindo preferência de gênero
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
            city: _cityController.text,
            neighborhood: _neighborhoodController.text,
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
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // Cor do AppBar roxa
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Por favor, preencha o formulário abaixo para encontrar seu pet ideal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedContactMethod,
                items: ['Email', 'Telefone'].map((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedContactMethod = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Escolha o método de contato',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  prefixIcon:
                      Icon(Icons.contact_mail, color: Colors.deepPurple),
                ),
              ),
              SizedBox(height: 20),
              if (_selectedContactMethod == 'Telefone')
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    prefixIcon: Icon(Icons.phone, color: Colors.deepPurple),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira seu telefone';
                    }
                    return null;
                  },
                ),
              if (_selectedContactMethod == 'Email')
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira seu e-mail';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 20),
              Text(
                'Quanto tempo você tem disponível para dedicar ao pet? (Semanal)',
                style: TextStyle(fontSize: 16),
              ),
              TextFormField(
                controller: _timeAvailableController,
                decoration: InputDecoration(
                  hintText: 'Ex: 10 horas',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  prefixIcon: Icon(Icons.timer, color: Colors.deepPurple),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira o tempo disponível';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Qual tipo de pet você prefere?',
                style: TextStyle(fontSize: 16),
              ),
              ListTile(
                title: const Text('Cachorro'),
                leading: Radio<String>(
                  value: 'Cachorro',
                  groupValue: petPreference,
                  onChanged: (value) {
                    setState(() {
                      petPreference = value!;
                    });
                  },
                  activeColor: Colors.deepPurple,
                ),
              ),
              ListTile(
                title: const Text('Gato'),
                leading: Radio<String>(
                  value: 'Gato',
                  groupValue: petPreference,
                  onChanged: (value) {
                    setState(() {
                      petPreference = value!;
                    });
                  },
                  activeColor: Colors.deepPurple,
                ),
              ),
              ListTile(
                title: const Text('Ambos'),
                leading: Radio<String>(
                  value: 'Ambos',
                  groupValue: petPreference,
                  onChanged: (value) {
                    setState(() {
                      petPreference = value!;
                    });
                  },
                  activeColor: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Prefere Macho, Fêmea ou Ambos?',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  prefixIcon: Icon(Icons.pets, color: Colors.deepPurple),
                ),
                value: genderPreference,
                items: ['Macho', 'Fêmea', 'Ambos'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    genderPreference = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              if (isDogPreference())
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Procura alguma raça de cachorro específica?',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  value: specificBreed,
                  items: dogBreeds.map((breed) {
                    return DropdownMenuItem<String>(
                      value: breed,
                      child: Text(breed),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      specificBreed = value!;
                    });
                  },
                ),
              if (specificBreed == 'Outro' && isDogPreference())
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Digite a raça do cachorro',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  onSaved: (value) {
                    specificBreed = value!;
                  },
                ),
              if (isCatPreference())
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Procura alguma raça de gato específica?',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  value: specificBreed,
                  items: catBreeds.map((breed) {
                    return DropdownMenuItem<String>(
                      value: breed,
                      child: Text(breed),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      specificBreed = value!;
                    });
                  },
                ),
              if (specificBreed == 'Outro' && isCatPreference())
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Digite a raça do gato',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  onSaved: (value) {
                    specificBreed = value!;
                  },
                ),
              SizedBox(height: 20),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  prefixIcon:
                      Icon(Icons.location_city, color: Colors.deepPurple),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira sua cidade';
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
                  prefixIcon: Icon(Icons.location_on, color: Colors.deepPurple),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira seu bairro';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Colors.deepPurple.shade700,
                  foregroundColor: Colors.white, // Botão roxo
                ),
                child: Text(
                  'Concluir formulário',
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
