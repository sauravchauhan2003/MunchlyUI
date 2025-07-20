import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class AuthenticationService {
  final String _baseUrl = Constants.baseUrl;

  Future<String?> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      url,
      headers: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final token = response.body;
      await _saveToken(token);
      return token;
    } else {
      return null;
    }
  }

  Future<String?> register(
    String email,
    String username,
    String password,
  ) async {
    final url = Uri.parse('$_baseUrl/register');

    final response = await http.post(
      url,
      headers: {'email': email, 'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final token = response.body;
      await _saveToken(token);
      return token;
    } else {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
