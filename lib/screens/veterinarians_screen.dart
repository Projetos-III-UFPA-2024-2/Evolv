import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projetoipet/models/veterinarian.dart';

class VeterinariansScreen extends StatefulWidget {
  @override
  _VeterinariansScreenState createState() => _VeterinariansScreenState();
}

class _VeterinariansScreenState extends State<VeterinariansScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _workingHoursController = TextEditingController();
  bool _homeService = false;

  String _contactMethod = 'Telefone'; // Define telefone como padrão

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Veterinário'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Nome', Icons.person),
              _buildDropdownField(),
              _buildTextField(_contactInfoController,
                  'Contato ($_contactMethod)', Icons.phone),
              _buildTextField(
                  _specializationController, 'Especialização', Icons.work),
              _buildTextField(
                  _experienceController, 'Experiência', Icons.timer),
              _buildTextField(_cityController, 'Cidade', Icons.location_city),
              _buildTextField(_neighborhoodController, 'Bairro', Icons.map),
              _buildTextField(_clinicAddressController, 'Endereço da Clínica',
                  Icons.home_work),
              _buildTextField(_workingHoursController, 'Horário de Trabalho',
                  Icons.schedule),
              SwitchListTile(
                title: Text('Atende a Domicílio'),
                activeColor: Colors.purple,
                value: _homeService,
                onChanged: (value) {
                  setState(() {
                    _homeService = value;
                  });
                },
              ),
              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.purple),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField(
        value: _contactMethod,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.contact_phone, color: Colors.purple),
          labelText: 'Método de Contato',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        items: ['Telefone', 'Email']
            .map((method) => DropdownMenuItem(
                  value: method,
                  child: Text(method),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _contactMethod = value!;
          });
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _saveVeterinarian,
      child: Text(
        'Cadastrar',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 8,
        backgroundColor: Colors.purple.shade700,
        shadowColor: Colors.purpleAccent,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _saveVeterinarian() async {
    if (_formKey.currentState!.validate()) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final veterinarian = Veterinarian(
          id: '', // Gerado pelo Firebase
          ownerId: user.uid,
          name: _nameController.text,
          contactMethod: _contactMethod,
          contactInfo: _contactInfoController.text,
          specialization: _specializationController.text,
          experience: _experienceController.text,
          city: _cityController.text,
          neighborhood: _neighborhoodController.text,
          homeService: _homeService,
          clinicAddress: _clinicAddressController.text,
          workingHours: _workingHoursController.text,
        );

        await FirebaseFirestore.instance
            .collection('veterinarians')
            .add(veterinarian.toMap());

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
        ));

        Navigator.pop(context);
      }
    }
  }
}
