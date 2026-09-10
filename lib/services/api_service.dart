import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'session_service.dart';

class ApiService {
  static final String baseUrl = '${ApiConfig.baseUrl}/api';
  final SessionService _sessionService = SessionService();

  Future<http.Response> get(String path, {Map<String, String>? queryParams}) async {
    final token = await _sessionService.getToken();
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    return _request(() => http.get(uri, headers: _headers(token)));
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final token = await _sessionService.getToken();
    final uri = Uri.parse('$baseUrl$path');
    return _request(() => http.post(uri, headers: _headers(token), body: jsonEncode(body)));
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final token = await _sessionService.getToken();
    final uri = Uri.parse('$baseUrl$path');
    return _request(() => http.put(uri, headers: _headers(token), body: jsonEncode(body)));
  }

  Future<http.Response> delete(String path) async {
    final token = await _sessionService.getToken();
    final uri = Uri.parse('$baseUrl$path');
    return _request(() => http.delete(uri, headers: _headers(token)));
  }

  /// Envía la petición y devuelve la respuesta sin lanzar excepción para
  /// errores HTTP (statusCode >= 400). Esto permite a los repositorios
  /// inspeccionar el código de estado y el cuerpo del error con detalle.
  /// Solo lanza excepción para errores de red/conexión real (SocketException,
  /// TimeoutException, etc.).
  Future<http.Response> _request(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: 15));
      return response;
    } on SocketException {
      throw Exception('Error de conexión: No se pudo conectar al servidor. Verifica que el backend esté corriendo y la URL sea correcta.');
    } on TimeoutException {
      throw Exception('Error de conexión: La solicitud excedió el tiempo de espera (15s).');
    } on Exception catch (e) {
      // Otro error de red no clasificado
      throw Exception('Error de conexión: $e');
    }
  }

  Map<String, String> _headers(String? token) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
