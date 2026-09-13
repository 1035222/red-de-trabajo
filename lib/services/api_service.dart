import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/session_service.dart';

class ApiService {
  final SessionService _sessionService = SessionService();
  static const String _apiPath = '/api';

  String get baseUrl => ApiConfig.baseUrl;

  Future<String?> _getToken({bool forceRefresh = false}) async {
    final session = await _sessionService.getSession();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return firebaseUser.getIdToken(forceRefresh);
    }
    return session?.token;
  }

  Future<Map<String, String>> _authHeaders({bool forceRefresh = false}) async {
    final token = await _getToken(forceRefresh: forceRefresh);
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> _sendWithAuth(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    var response = await request(await _authHeaders());
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (response.statusCode == 401 && firebaseUser != null) {
      response = await request(await _authHeaders(forceRefresh: true));
    }
    return response;
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('$baseUrl$_apiPath$path')
        .replace(queryParameters: queryParams);
    return _sendWithAuth((headers) => http.get(uri, headers: headers));
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$_apiPath$path');
    return _sendWithAuth(
      (headers) => http.post(uri, headers: headers, body: jsonEncode(body)),
    );
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$_apiPath$path');
    return _sendWithAuth(
      (headers) => http.put(uri, headers: headers, body: jsonEncode(body)),
    );
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$_apiPath$path');
    return _sendWithAuth((headers) => http.delete(uri, headers: headers));
  }

  Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$_apiPath$path');
    return _sendWithAuth(
      (headers) => http.patch(uri, headers: headers, body: jsonEncode(body)),
    );
  }

  Future<String> uploadImage({required List<int> bytes, required String filename}) async {
    Future<http.Response> send(String? token) async {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$_apiPath/uploads'));
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
      return http.Response.fromStream(await request.send());
    }

    var response = await send(await _getToken());
    if (response.statusCode == 401 && FirebaseAuth.instance.currentUser != null) {
      response = await send(await _getToken(forceRefresh: true));
    }
    if (response.statusCode != 201) {
      throw Exception('Error al subir imagen (${response.statusCode}): ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['url'] as String;
  }
}
