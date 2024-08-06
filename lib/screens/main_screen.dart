import 'package:flutter/material.dart';
import 'pre_adoption_form_screen.dart';
import 'register_pet_screen.dart';
import 'adopt_pet_check_screen.dart'; // Importar a nova tela de verificação

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iPet'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdoptPetCheckScreen(), // Redirecionar para a nova tela de verificação
                  ),
                );
              },
              child: Text('Adote um pet'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPetScreen()),
                );
              },
              child: Text('Cadastrar animal'),
            ),
          ],
        ),
      ),
    );
  }
}
