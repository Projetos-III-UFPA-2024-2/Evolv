import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/adoption_request.dart';
import '../models/animal.dart';

class InterestedUsersScreen extends StatelessWidget {
  final Animal animal;

  InterestedUsersScreen({required this.animal});

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

  void _chooseAdopter(
      BuildContext context, AdoptionRequest request, String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('animals')
          .doc(animal.id)
          .delete();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Adoção Concluída'),
            content: Text(
              'Parabéns! Você escolheu ${request.adopterName} para adotar ${animal.name}. '
              'Entre em contato através do contato: ${request.adopterContact} '
              'para finalizar a adoção. Você pode tirar um print desta tela.',
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

  void _removePet(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('animals')
          .doc(animal.id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Animal removido com sucesso!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Erro ao remover animal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover o animal.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitações de Adoção'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // Cor do AppBar roxa
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Remover Animal'),
                    content: Text(
                        'Você tem certeza que deseja remover ${animal.name}?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          _removePet(context);
                          Navigator.of(context).pop();
                        },
                        child: Text('Remover'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
                      color: Colors.deepPurple, // Título com cor roxa
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
                          backgroundColor:
                              Colors.green, // Cor verde para escolher
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _deleteRequest(requestDoc.id);
                        },
                        icon: Icon(Icons.delete),
                        label: Text('Excluir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red, // Cor vermelha para excluir
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
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
