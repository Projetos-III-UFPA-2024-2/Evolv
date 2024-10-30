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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _timeAvailableController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();

  String specificDogBreed = 'Não tenho';
  String specificCatBreed = 'Não tenho'; // Campo para raça de gato
  String petPreference = 'Cachorro';
  String _selectedContactMethod = 'Email';
  String genderPreference = 'Macho';
  bool _isSubmitting = false;

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

  bool isDogPreference() =>
      petPreference == 'Cachorro' || petPreference == 'Ambos';
  bool isCatPreference() => petPreference == 'Gato' || petPreference == 'Ambos';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _timeAvailableController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance
          .collection('form_responses')
          .doc(user!.uid)
          .set({
        'name': _nameController.text,
        'phone':
            _selectedContactMethod == 'Telefone' ? _phoneController.text : '',
        'email': _selectedContactMethod == 'Email' ? _emailController.text : '',
        'timeAvailable': _timeAvailableController.text,
        'specificDogBreed': specificDogBreed,
        'specificCatBreed': specificCatBreed,
        'city': _cityController.text,
        'neighborhood': _neighborhoodController.text,
        'petPreference': petPreference,
        'genderPreference': genderPreference,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informações salvas com sucesso!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdoptPetScreen(
            city: _cityController.text,
            neighborhood: _neighborhoodController.text,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar as informações.')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário de Pré-Adoção'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
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
              _buildTextField(_nameController, 'Nome', Icons.person,
                  'Por favor, insira seu nome'),
              SizedBox(height: 20),
              _buildDropdown(
                'Escolha o método de contato',
                _selectedContactMethod,
                ['Email', 'Telefone'],
                Icons.contact_mail,
                (value) {
                  setState(() {
                    _selectedContactMethod = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              if (_selectedContactMethod == 'Telefone')
                _buildTextField(
                  _phoneController,
                  'Telefone',
                  Icons.phone,
                  'Por favor, insira seu telefone',
                ),
              if (_selectedContactMethod == 'Email')
                _buildTextField(
                  _emailController,
                  'E-mail',
                  Icons.email,
                  'Por favor, insira seu e-mail',
                ),
              SizedBox(height: 20),
              _buildTextField(
                _timeAvailableController,
                'Disponibilidade semanal (Ex: 10 horas)',
                Icons.timer,
                'Por favor, insira o tempo disponível',
              ),
              SizedBox(height: 20),
              _buildRadioOptions(
                'Qual tipo de pet você prefere?',
                ['Cachorro', 'Gato', 'Ambos'],
                petPreference,
                (value) {
                  setState(() {
                    petPreference = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              _buildDropdown(
                'Prefere Macho, Fêmea ou Ambos?',
                genderPreference,
                ['Macho', 'Fêmea', 'Ambos'],
                Icons.pets,
                (newValue) {
                  setState(() {
                    genderPreference = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              if (isDogPreference())
                _buildDropdown(
                  'Raça de cachorro específica?',
                  specificDogBreed,
                  dogBreeds,
                  Icons.pets,
                  (value) {
                    setState(() {
                      specificDogBreed = value!;
                    });
                  },
                ),
              SizedBox(height: 20), // Adiciona espaçamento entre os campos
              if (isCatPreference())
                _buildDropdown(
                  'Raça de gato específica?',
                  specificCatBreed,
                  catBreeds,
                  Icons.pets,
                  (value) {
                    setState(() {
                      specificCatBreed = value!;
                    });
                  },
                ),
              SizedBox(height: 20),
              _buildTextField(
                _cityController,
                'Cidade',
                Icons.location_city,
                'Por favor, insira sua cidade',
              ),
              SizedBox(height: 20),
              _buildTextField(
                _neighborhoodController,
                'Bairro',
                Icons.location_on,
                'Por favor, insira seu bairro',
              ),
              SizedBox(height: 30),
              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        backgroundColor: Colors.deepPurple.shade700,
                        foregroundColor: Colors.white,
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

  // Método para construir campos de texto
  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, String validationMessage) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        prefixIcon: Icon(icon, color: Colors.deepPurple),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  // Método para construir Dropdowns
  Widget _buildDropdown(String label, String currentValue, List<String> items,
      IconData icon, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        prefixIcon: Icon(icon, color: Colors.deepPurple),
      ),
      value: currentValue,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Método para construir opções de rádio
  Widget _buildRadioOptions(String title, List<String> options,
      String groupValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16)),
        ...options.map((option) {
          return ListTile(
            title: Text(option),
            leading: Radio<String>(
              value: option,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Colors.deepPurple,
            ),
          );
        }).toList(),
      ],
    );
  }
}
