import 'dart:convert';
import 'package:http/http.dart' as http;

class CatApiService {
  static const String _apiKey = 'live_JBT0Ah0Nt12iyl2IpjQVLDWjcLk0GQwf4zI9wBMfmfejKmcC31mOJp4yJz5TsOUP';
  static const String _baseUrl = 'https://api.thecatapi.com/v1';

  static final Map<String, String> _headers = {
    'x-api-key': _apiKey,
  };

  /// ✅ Obtener listado completo de razas
  static Future<List<Map<String, dynamic>>> getBreeds() async {
    try {
      final url = Uri.parse('$_baseUrl/breeds');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final breeds = data.map((item) {
          final map = item as Map<String, dynamic>;
          return {
            'id': map['id'] ?? '',
            'name': map['name'] ?? 'Sin nombre',
            'origin': map['origin'] ?? 'Desconocido',
            'life_span': map['life_span'] ?? '',
            'intelligence': map['intelligence']?.toString() ?? '',
            'description': map['description'] ?? '',
            'wikipedia_url': map['wikipedia_url'] ?? '',
            'image': map['image'] != null ? (map['image']['url'] ?? '') : '',
          };
        }).where((breed) => breed['image'] != '').toList();

        return breeds;
      } else {
        throw Exception('Error al cargar razas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }

  /// ✅ Obtener imágenes de una raza específica
  static Future<List> getImagesByBreed(String breedId) async {
    try {
      final url = Uri.parse('$_baseUrl/images/search?breed_ids=$breedId&limit=10');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final images = data.map((item) {
          final map = item as Map<String, dynamic>;
          return map['url'] ?? '';
        }).where((url) => url.isNotEmpty).toList();

        return images;
      } else {
        throw Exception('Error al cargar imágenes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }
}
