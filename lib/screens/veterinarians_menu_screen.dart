import 'package:flutter/material.dart';
import 'veterinarians_screen.dart'; // Tela de cadastro de veterinário
import 'veterinarians_search_screen.dart'; // Tela de busca de veterinário
import 'veterinarian_profile_screen.dart'; // Tela de perfil do veterinário

class VeterinariansMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Veterinários'),
        backgroundColor: Colors.purple, // Aplicando cor roxa no AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton(
              context,
              icon: Icons.add,
              label: 'Cadastro de Veterinário',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VeterinariansScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            _buildMenuButton(
              context,
              icon: Icons.search,
              label: 'Procurar Veterinário',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VeterinariansSearchScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            _buildMenuButton(
              context,
              icon: Icons.person,
              label: 'Perfil do Veterinário',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VeterinarianProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        minimumSize: Size(double.infinity, 50), // Botão em largura total
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Botões arredondados
        ),
        elevation: 8, // Sombra para dar profundidade
        backgroundColor: Colors.purple.shade700, // Cor roxa mais intensa
        shadowColor: Colors.purpleAccent, // Cor da sombra
      ),
    );
  }
}
