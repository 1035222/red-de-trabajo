import 'dart:convert';
import 'package:red_de_trabajo/services/api_service.dart';
import '../services/session_service.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final ApiService _api;
  final SessionService _sessionService;

  ApiAuthRepository(this._api) : _sessionService = SessionService();

  @override
  Future<AppUser?> login(String email, String password) async {
    final response = await _api.post('/auth/login', {'email': email, 'password': password});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = AppUser.fromJson(data['user']);
      await _sessionService.saveSession(user: user, token: data['token']);
      return user;
    }
    return null;
  }

  @override
  Future<AppUser> register(String name, String email, String password) async {
    final response = await _api.post('/auth/register', {'name': name, 'email': email, 'password': password});
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final user = AppUser.fromJson(data['user']);
      await _sessionService.saveSession(user: user, token: data['token']);
      return user;
    }
    throw Exception('Error en registro');
  }

  @override
  Future<void> logout() async {
    await _sessionService.clearSession();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final response = await _api.get('/auth/profile');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AppUser.fromJson(data);
    }
    return null;
  }
}
