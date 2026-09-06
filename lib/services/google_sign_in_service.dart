import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:red_de_trabajo/services/api_service.dart';
import '../services/session_service.dart';
import '../models/app_user.dart';

class GoogleSignInService {
  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[GoogleSignIn] $message');
    }
  }

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    clientId: kIsWeb
        ? '867847161323-kif144ccp2r4jl5c7ie7k9kms9rnn8ta.apps.googleusercontent.com'
        : null,
  );

  static Future<Map<String, dynamic>?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        _log('account == null => user canceled');
        return null;
      }

      final googleAuth = await account.authentication;
      _log('authentication idToken=${googleAuth.idToken != null ? "present" : "null"}, accessToken=${googleAuth.accessToken != null ? "present" : "null"}');
      if (googleAuth.idToken == null && !kIsWeb) {
        _log('idToken is null after authentication');
        return null;
      }

      final api = ApiService();
      final response = await api.post('/auth/google', {
        'email': account.email,
        'name': account.displayName ?? 'Usuario',
        'photoUrl': account.photoUrl,
        'googleId': account.id,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _log('API response body=$data');
        final userJson = data['user'] as Map<String, dynamic>?;
        final token = data['token'] as String?;
        if (userJson == null || token == null) {
          _log('missing user/token in response');
          return null;
        }
        final user = AppUser.fromJson(userJson);
        final sessionService = SessionService();
        await sessionService.saveSession(user: user, token: token);
        return data;
      }
      _log('API error status=${response.statusCode} body=${response.body}');
      return null;
    } catch (e, stack) {
      _log('error type=${e.runtimeType} message=$e');
      _log('stack=$stack');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}
