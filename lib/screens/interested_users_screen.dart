import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/adoption_request.dart';
import '../models/animal.dart';

class InterestedUsersScreen extends StatelessWidget {
  final Animal animal;

  InterestedUsersScreen({required this.animal});

  // Função para excluir uma solicitação de adoção
  void _deleteRequest(String requestId) {
    FirebaseFirestore.instance
        .collection('adoption_requests')
        .doc(requestId)
        .delete()
        .then((_) {
      print("Solicitação de adoção excluída com sucesso!");
    }).catchError((error) {
      print("Erro ao excluir solicitação de adoção: $error");
    });
  }

  // Função para escolher um adotante
  void _chooseAdopter(
      BuildContext context, AdoptionRequest request, String requestId) async {
    try {
      // Exibir o diálogo de sucesso com as informações do adotante escolhido
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Adoção Concluída'),
            content: Text(
              'Parabéns! Você escolheu ${request.adopterName} para adotar ${animal.name}. '
              'Entre em contato através do: ${request.adopterContact} '
              'para finalizar a adoção. Você pode tirar um print desta tela para facilitar e não esqueça de remover o seu pet da lista de adoção.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Erro ao concluir a adoção: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao concluir a adoção.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitações de Adoção'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('adoption_requests')
            .where('petId', isEqualTo: animal.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Nenhum interessado ainda.',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var requestDoc = snapshot.data!.docs[index];
              var request = AdoptionRequest.fromMap(
                  requestDoc.data() as Map<String, dynamic>);

              String contactInfo = request.adopterContact.isNotEmpty
                  ? request.adopterContact
                  : 'Contato desconhecido';

              String adopterDisplayName = request.adopterName != "Usuário" &&
                      request.adopterName.isNotEmpty
                  ? request.adopterName
                  : 'Nome não informado';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: Text(
                    '$adopterDisplayName quer adotar ${animal.name}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Compatibilidade: ${request.compatibility}%'),
                        SizedBox(height: 4),
                        Text(contactInfo),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _chooseAdopter(context, request, requestDoc.id);
                        },
                        icon: Icon(Icons.check),
                        label: Text('Escolher'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 8), // Espaçamento entre os botões
                      IconButton(
                        onPressed: () {
                          _deleteRequest(requestDoc.id);
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir solicitação',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
