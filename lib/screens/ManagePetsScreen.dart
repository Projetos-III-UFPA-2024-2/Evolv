import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/animal.dart';
import 'edit_pet_screen.dart';

class ManagePetsScreen extends StatefulWidget {
  final String ownerId; // O ID do usuário atual para filtrar os pets

  ManagePetsScreen({required this.ownerId});

  @override
  _ManagePetsScreenState createState() => _ManagePetsScreenState();
}

class _ManagePetsScreenState extends State<ManagePetsScreen> {
  List<Animal> animals = [];

  @override
  void initState() {
    super.initState();
    _loadUserAnimals(); // Carrega os animais do usuário ao inicializar
  }

  // Carregar os animais cadastrados pelo usuário atual
  Future<void> _loadUserAnimals() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('animals')
          .where('ownerId', isEqualTo: widget.ownerId) // Filtrar pelo dono
          .get();

      setState(() {
        animals = querySnapshot.docs.map((doc) {
          return Animal.fromMap(doc.data() as Map<String, dynamic>)
            ..id = doc.id; // Certifique-se de armazenar o ID do documento
        }).toList();
      });
    } catch (e) {
      print('Erro ao carregar os animais: $e');
    }
  }

  // Atualiza o animal localmente após edição
  void _updateAnimal(Animal updatedAnimal) {
    setState(() {
      // Atualiza o animal específico na lista
      int index = animals.indexWhere((a) => a.id == updatedAnimal.id);
      if (index != -1) {
        animals[index] = updatedAnimal;
      }
    });
  }

  Future<void> _deleteAnimal(BuildContext context, Animal animal) async {
    try {
      // Excluir pedidos de adoção associados ao animal
      final adoptionRequestsSnapshot = await FirebaseFirestore.instance
          .collection('adoption_requests')
          .where('petId', isEqualTo: animal.id)
          .get();

      for (var doc in adoptionRequestsSnapshot.docs) {
        await doc.reference.delete(); // Deleta cada pedido de adoção associado
      }

      // Excluir o animal em si
      await FirebaseFirestore.instance
          .collection('animals')
          .doc(animal.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Pet excluído com sucesso! seu pet foi removido da lista de adoção e escolher adotante, por favor faça login novamente para atualizar todos os campos'),
          backgroundColor: Colors.red,
        ),
      );

      // Remove o animal da lista localmente
      setState(() {
        animals.removeWhere((a) => a.id == animal.id);
      });
    } catch (e) {
      print('Erro ao excluir o animal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir o animal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Mostrar diálogo de confirmação de exclusão
  void _showDeleteConfirmation(BuildContext context, Animal animal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Animal'),
          content: Text(
              'Você tem certeza que deseja excluir o animal "${animal.name}"? Isso removerá o pet da lista de adoção.'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () async {
                await _deleteAnimal(context, animal);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Animais'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: animals.isEmpty
          ? Center(child: Text('Nenhum animal cadastrado.'))
          : ListView.builder(
              itemCount: animals.length,
              itemBuilder: (context, index) {
                final animal = animals[index];
                return ListTile(
                  leading: animal.photoUrl.isNotEmpty
                      ? Image.network(animal.photoUrl, width: 50, height: 50)
                      : Icon(Icons.pets),
                  title: Text(animal.name),
                  subtitle: Text('Raça: ${animal.breed}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          // Navegar para a tela de edição e esperar o resultado
                          Animal? updatedAnimal = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditAnimalScreen(animal: animal),
                            ),
                          );

                          // Se o animal foi atualizado, fazer o update local
                          if (updatedAnimal != null) {
                            _updateAnimal(updatedAnimal);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(context, animal);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
