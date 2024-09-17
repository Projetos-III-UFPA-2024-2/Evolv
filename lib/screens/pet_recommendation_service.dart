import 'dart:convert';
import 'package:http/http.dart' as http;

class PetRecommendationService {
  Future<List<dynamic>> getPetRecommendations(List<String> preferences) async {
    final url = Uri.parse('http://localhost:5000/recommend');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'preferences': preferences}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar recomendações');
    }
  }
}
