import 'package:cloud_firestore/cloud_firestore.dart';

class AdoptionRequest {
  final String adopterId;
  final String adopterName;
  final String adopterPhone;
  final String adopterEmail; // Adicionando o campo de email
  final String adopterContact; // Novo campo para o contato escolhido
  final String petId;
  final String petName;
  final String petOwnerId;
  final double compatibility;
  final Timestamp timestamp;

  AdoptionRequest({
    required this.adopterId,
    required this.adopterName,
    required this.adopterPhone,
    required this.adopterEmail, // Inicializando o campo de email
    required this.adopterContact, // Inicializando o campo de contato
    required this.petId,
    required this.petName,
    required this.petOwnerId,
    required this.compatibility,
    required this.timestamp,
  });

  factory AdoptionRequest.fromMap(Map<String, dynamic> map) {
    return AdoptionRequest(
      adopterId: map['adopterId'] ?? '',
      adopterName: map['adopterName'] ?? 'Usuário',
      adopterPhone: map['adopterPhone'] ?? 'Telefone desconhecido',
      adopterEmail: map['adopterEmail'] ??
          'Email desconhecido', // Inicializando com valor padrão
      adopterContact: map['adopterContact'] ??
          'Contato desconhecido', // Inicializando com valor padrão
      petId: map['petId'] ?? '',
      petName: map['petName'] ?? 'Pet Desconhecido',
      petOwnerId: map['petOwnerId'] ?? '',
      compatibility: map['compatibility']?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}
