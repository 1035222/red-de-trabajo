import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class SessionService {
  static const String _userKey = 'app_user';
  static const String _authorizedKey = 'app_user_authorized';
  static const String _tokenKey = 'auth_token';

  Future<void> saveSession({required AppUser user, required String token, bool authorized = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_authorizedKey, authorized);
  }

  Future<({AppUser? user, String? token, bool authorized})?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(_userKey);
    final token = prefs.getString(_tokenKey);
    final authorized = prefs.getBool(_authorizedKey) ?? false;
    if (rawUser == null || token == null) return null;
    return (user: AppUser.fromJson(jsonDecode(rawUser)), token: token, authorized: authorized);
  }

  Future<void> setAuthorized(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authorizedKey, value);
  }

  Future<bool> isAuthorized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_authorizedKey) ?? false;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_authorizedKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
