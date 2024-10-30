import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetoipet/models/veterinarian.dart';

class VeterinariansSearchScreen extends StatefulWidget {
  @override
  _VeterinariansSearchScreenState createState() =>
      _VeterinariansSearchScreenState();
}

class _VeterinariansSearchScreenState extends State<VeterinariansSearchScreen> {
  final _cityController = TextEditingController();
  List<Veterinarian> _veterinarians = [];
  bool _noResults = false;

  Future<void> _searchVeterinarians() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('veterinarians')
        .where('city', isEqualTo: _cityController.text)
        .get();

    if (querySnapshot.docs.isEmpty) {
      setState(() {
        _noResults = true;
        _veterinarians = [];
      });
    } else {
      setState(() {
        _veterinarians = querySnapshot.docs
            .map((doc) => Veterinarian.fromMap(doc.data()))
            .toList();
        _noResults = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Procurar Veterinário'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(),
            SizedBox(height: 20),
            _buildSearchButton(),
            if (_noResults) _buildNoResultsMessage(),
            SizedBox(height: 10),
            _buildVeterinariansList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextFormField(
      controller: _cityController,
      decoration: InputDecoration(
        labelText: 'Cidade',
        prefixIcon: Icon(Icons.search, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton.icon(
      onPressed: _searchVeterinarians,
      icon: Icon(Icons.search, color: Colors.white),
      label: Text(
        'Buscar',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Botão mais arredondado
        ),
        elevation: 8, // Adiciona uma sombra ao botão
        backgroundColor: Colors.purple.shade700, // Tom mais vibrante de roxo
        shadowColor: Colors.purpleAccent, // Cor da sombra
      ),
    );
  }

  Widget _buildNoResultsMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(
        'Nenhum veterinário encontrado na cidade: ${_cityController.text}',
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }

  Widget _buildVeterinariansList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _veterinarians.length,
        itemBuilder: (context, index) {
          final vet = _veterinarians[index];
          return Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.purple, size: 24),
                      SizedBox(width: 10),
                      Text(
                        vet.name,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(Icons.location_city, 'Cidade: ${vet.city}'),
                  _buildInfoRow(Icons.near_me, 'Bairro: ${vet.neighborhood}'),
                  _buildInfoRow(Icons.phone, 'Contato: ${vet.contactInfo}'),
                  _buildInfoRow(Icons.credit_card, 'CRMV: ${vet.crmv}'),
                  _buildInfoRow(
                      Icons.work, 'Especialização: ${vet.specialization}'),
                  _buildInfoRow(
                      Icons.timer, 'Experiência: ${vet.experience} anos'),
                  _buildInfoRow(Icons.home_work,
                      'Endereço da Clínica: ${vet.clinicAddress}'),
                  _buildInfoRow(Icons.schedule,
                      'Horário de Trabalho: ${vet.workingHours}'),
                  _buildInfoRow(Icons.home,
                      'Atende a Domicílio: ${vet.homeService ? 'Sim' : 'Não'}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
