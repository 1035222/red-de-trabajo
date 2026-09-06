import '../models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> login(String email, String password);
  Future<AppUser> register(String name, String email, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}
