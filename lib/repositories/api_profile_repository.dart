import 'dart:convert';
import 'package:red_de_trabajo/services/api_service.dart';
import '../models/app_user.dart';
import '../models/review.dart';
import '../models/portfolio_item.dart';
import 'profile_repository.dart';

class ApiProfileRepository implements ProfileRepository {
  final ApiService _api;

  ApiProfileRepository(this._api);

  @override
  Future<AppUser> getUserProfile(String userId) async {
    final response = await _api.get('/users/$userId');
    if (response.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al obtener perfil');
  }

  @override
  Future<AppUser> updateUserProfile(AppUser user) async {
    final response = await _api.put('/users/me', {
      'name': user.name,
      'bio': user.bio,
      'location': user.location,
    });
    if (response.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al actualizar perfil');
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async {
    final response = await _api.get('/reviews/$userId');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    }
    throw Exception('Error al obtener reseñas');
  }

  @override
  Future<List<PortfolioItem>> getUserPortfolio(String userId) async {
    final response = await _api.get('/portfolio/$userId');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => PortfolioItem.fromJson(json)).toList();
    }
    throw Exception('Error al obtener portafolio');
  }
}
