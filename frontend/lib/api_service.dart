import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  ApiService({this.baseUrl = 'http://localhost:5000'});

  Future<List<dynamic>> search(String q) async {
    final res = await http.post(Uri.parse('$baseUrl/api/search'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode({'q': q}));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Search failed');
  }

  Future<List<dynamic>> files() async {
    final res = await http.get(Uri.parse('$baseUrl/api/files'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Files failed');
  }

  Future<int> reindex() async {
    final res = await http.post(Uri.parse('$baseUrl/api/reindex'));
    if (res.statusCode == 200) return jsonDecode(res.body)['indexed'] as int;
    throw Exception('Reindex failed');
  }
}
