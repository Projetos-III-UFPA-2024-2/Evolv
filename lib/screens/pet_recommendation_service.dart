import 'dart:convert';
import 'package:http/http.dart' as http;

class PetRecommendationService {
  // Substitua localhost por 10.0.2.2 no Android ou pelo IP correto do servidor
  final String _baseUrl =
      'http://ipet-env.eba-ummbhmx6.us-east-1.elasticbeanstalk.com/recommend';

  // Função para obter recomendações de pets com base nas preferências do usuário
  Future<List<dynamic>> getPetRecommendations(List<String> preferences) async {
    try {
      final url = Uri.parse(_baseUrl);

      // Fazendo a requisição HTTP POST
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'preferences': preferences}),
      );

      // Verificando se a resposta é válida
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Tratamento de erro mais detalhado
        print('Erro ao buscar recomendações: ${response.statusCode}');
        throw Exception(
            'Erro ao buscar recomendações, status: ${response.statusCode}');
      }
    } catch (e) {
      // Tratamento de exceções de rede
      print('Exceção ao fazer a requisição: $e');
      throw Exception('Erro de rede: $e');
    }
  }
}
