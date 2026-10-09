import 'dart:convert';
import 'package:http/http.dart' as http;

class MovementStatusRepo {
  static Future<Map<String, dynamic>> active(String url, String userId) async {
    final response = await http
        .post(Uri.parse(url), body: {'user_id': userId})
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw Exception('Status gagal dimuat');
    final rows = jsonDecode(response.body)['data'] as List;
    return rows.isEmpty ? {} : Map<String, dynamic>.from(rows.first);
  }
}
