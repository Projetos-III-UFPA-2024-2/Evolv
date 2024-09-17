import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DonationScreen extends StatelessWidget {
  final String pixKey = 'adocaoipet@gmail.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajude o iPet'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ajude o iPet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 25),
            Text(
              'Sua contribuição é essencial para continuar ajudando animais a encontrar um lar amoroso. '
              'Qualquer valor será muito bem-vindo e ajudará a manter nosso trabalho.',
              style:
                  TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800]),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 30),
            Divider(thickness: 1, color: Colors.deepPurple.shade700),
            SizedBox(height: 20),
            Text(
              'Chave PIX para doações:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade700),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      pixKey,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.deepPurple.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.deepPurple.shade700),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: pixKey));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Chave PIX copiada!'),
                          backgroundColor: Colors.purple,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                'Muito obrigado por apoiar o iPet!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: Colors.deepPurple.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
