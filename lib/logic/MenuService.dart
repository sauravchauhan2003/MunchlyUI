import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:munchly/logic/MenuItem.dart';

class MenuService {
  static Future<List<MenuItem>> fetchMenu(String time, String type) async {
    final response = await http.get(
      Uri.parse('https://munchlybackend.onrender.com/$time/$type'),
    ); // Replace with actual URL

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => MenuItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load menu');
    }
  }
}
