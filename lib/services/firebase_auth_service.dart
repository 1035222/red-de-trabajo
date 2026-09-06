import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '867847161323-kif144ccp2r4jl5c7ie7k9kms9rnn8ta.apps.googleusercontent.com'
        : null,
  );

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final UserCredential userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
        return userCredential.user;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('ERROR GOOGLE SIGN-IN: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      throw _mapFirebaseError(e);
    } catch (e, stackTrace) {
      debugPrint('ERROR GOOGLE SIGN-IN: $e');
      debugPrint('STACK TRACE: $stackTrace');
      throw Exception('Error en autenticación con Google');
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      debugPrint('EMAIL SIGN-IN attempt for: $email');
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      debugPrint('EMAIL SIGN-IN success uid=${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('ERROR EMAIL SIGN-IN: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      throw _mapFirebaseError(e);
    } catch (e, stackTrace) {
      debugPrint('ERROR EMAIL SIGN-IN: $e');
      debugPrint('STACK TRACE: $stackTrace');
      throw Exception('Error en autenticación con correo');
    }
  }

  Future<void> linkEmailAndPassword(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final credential = EmailAuthProvider.credential(email: email, password: password);
      await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('ERROR LINK CREDENTIAL: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      throw _mapFirebaseError(e);
    } catch (e, stackTrace) {
      debugPrint('ERROR LINK CREDENTIAL: $e');
      debugPrint('STACK TRACE: $stackTrace');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  User? get currentUser => _auth.currentUser;

  bool hasEmailPasswordLinked(User user) {
    return user.providerData.any((info) => info.providerId == 'password');
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Map<String, dynamic>> syncUserWithBackend(String backendUrl) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    final idToken = await user.getIdToken();
    final tokenForLog = (idToken == null) ? 'null' : '${idToken.substring(0, 12)}...';
    debugPrint('SYNC BACKEND uid=${user.uid} email=${user.email} token_present=${idToken != null} token_prefix=$tokenForLog');

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/api/users/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': user.uid,
          'email': user.email ?? '',
          'name': user.displayName ?? '',
          'avatarUrl': user.photoURL ?? '',
        }),
      ).timeout(const Duration(seconds: 10));

      debugPrint('SYNC BACKEND status=${response.statusCode} body=${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      if (response.statusCode == 401) {
        debugPrint('SYNC BACKEND: token inválido o expirado, usando datos locales');
        return _localUserData(user);
      }

      throw Exception('No se pudo sincronizar el usuario con el backend (status ${response.statusCode})');
    } on Exception catch (e) {
      debugPrint('SYNC BACKEND error: $e');
      return _localUserData(user);
    }
  }

  Map<String, dynamic> _localUserData(User user) {
    return {
      'id': user.uid,
      'name': user.displayName ?? 'Usuario',
      'email': user.email ?? '',
      'avatarUrl': user.photoURL ?? '',
    };
  }

  Exception _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Usuario no encontrado');
      case 'wrong-password':
        return Exception('Contraseña incorrecta');
      case 'email-already-in-use':
        return Exception('El correo ya está registrado');
      case 'weak-password':
        return Exception('La contraseña es muy débil');
      case 'invalid-email':
        return Exception('Correo electrónico inválido');
      case 'user-disabled':
        return Exception('Cuenta deshabilitada');
      case 'too-many-requests':
        return Exception('Demasiados intentos, intenta más tarde');
      case 'operation-not-allowed':
        return Exception('Operación no permitida');
      case 'invalid-credential':
        return Exception('Credenciales inválidas');
      case 'account-exists-with-different-credential':
        return Exception('Esta cuenta existe con otro método de acceso');
      case 'requires-recent-login':
        return Exception('Requiere login reciente');
      default:
        return Exception(e.message ?? 'Error de autenticación');
    }
  }
}
