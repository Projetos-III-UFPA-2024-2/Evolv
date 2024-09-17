import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projetoipet/models/veterinarian.dart';

class VeterinarianProfileScreen extends StatefulWidget {
  @override
  _VeterinarianProfileScreenState createState() =>
      _VeterinarianProfileScreenState();
}

class _VeterinarianProfileScreenState extends State<VeterinarianProfileScreen> {
  Veterinarian? _veterinarian;
  String? _docId;
  bool _isEditing = false;

  // Controladores para os campos de texto
  final _nameController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _workingHoursController = TextEditingController();
  bool _homeService = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('veterinarians')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          _veterinarian = Veterinarian.fromMap(doc.data());
          _docId = doc.id;
          _nameController.text = _veterinarian!.name;
          _contactInfoController.text = _veterinarian!.contactInfo;
          _specializationController.text = _veterinarian!.specialization;
          _experienceController.text = _veterinarian!.experience;
          _cityController.text = _veterinarian!.city;
          _neighborhoodController.text = _veterinarian!.neighborhood;
          _clinicAddressController.text = _veterinarian!.clinicAddress;
          _workingHoursController.text = _veterinarian!.workingHours;
          _homeService = _veterinarian!.homeService;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_docId != null) {
      final updatedVeterinarian = _veterinarian!.copyWith(
        name: _nameController.text,
        contactInfo: _contactInfoController.text,
        specialization: _specializationController.text,
        experience: _experienceController.text,
        city: _cityController.text,
        neighborhood: _neighborhoodController.text,
        clinicAddress: _clinicAddressController.text,
        workingHours: _workingHoursController.text,
        homeService: _homeService,
      );

      await FirebaseFirestore.instance
          .collection('veterinarians')
          .doc(_docId!)
          .update(updatedVeterinarian.toMap());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Perfil atualizado com sucesso!'),
      ));

      setState(() {
        _isEditing = false;
        _loadProfile();
      });
    }
  }

  Future<void> _deleteProfile() async {
    if (_docId != null) {
      await FirebaseFirestore.instance
          .collection('veterinarians')
          .doc(_docId!)
          .delete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_veterinarian == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Perfil do Veterinário'),
          backgroundColor: Colors.purple,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil do Veterinário'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isEditing ? _buildEditForm() : _buildProfileView(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: _isEditing
            ? _updateProfile
            : () {
                setState(() {
                  _isEditing = true;
                });
              },
        child: Icon(_isEditing ? Icons.save : Icons.edit),
      ),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard(Icons.person, 'Nome', _veterinarian!.name),
          _buildProfileCard(Icons.phone, 'Contato', _veterinarian!.contactInfo),
          _buildProfileCard(
              Icons.work, 'Especialização', _veterinarian!.specialization),
          _buildProfileCard(
              Icons.timer, 'Experiência', _veterinarian!.experience),
          _buildProfileCard(Icons.location_city, 'Localização',
              '${_veterinarian!.city}, ${_veterinarian!.neighborhood}'),
          _buildProfileCard(Icons.home_work, 'Endereço da Clínica',
              _veterinarian!.clinicAddress),
          _buildProfileCard(Icons.schedule, 'Horário de Trabalho',
              _veterinarian!.workingHours),
          _buildProfileCard(Icons.home, 'Atende a Domicílio',
              _veterinarian!.homeService ? 'Sim' : 'Não'),
        ],
      ),
    );
  }

  Widget _buildProfileCard(IconData icon, String label, String value) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.purple),
        title: Text(value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(label),
      ),
    );
  }

  Widget _buildEditForm() {
    return ListView(
      children: [
        _buildTextField(_nameController, 'Nome', Icons.person),
        _buildTextField(_contactInfoController, 'Contato', Icons.phone),
        _buildTextField(
            _specializationController, 'Especialização', Icons.work),
        _buildTextField(_experienceController, 'Experiência', Icons.timer),
        _buildTextField(_cityController, 'Cidade', Icons.location_city),
        _buildTextField(_neighborhoodController, 'Bairro', Icons.map),
        _buildTextField(
            _clinicAddressController, 'Endereço da Clínica', Icons.home_work),
        _buildTextField(
            _workingHoursController, 'Horário de Trabalho', Icons.schedule),
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
      ],
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
      ),
    );
  }
}
