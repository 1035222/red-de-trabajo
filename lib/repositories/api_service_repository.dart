import 'dart:convert';
import 'package:red_de_trabajo/services/api_service.dart';
import '../models/service.dart';
import 'service_repository.dart';

class ApiServiceRepository implements ServiceRepository {
  final ApiService _api;

  ApiServiceRepository(this._api);

  @override
  Future<List<Service>> getFeaturedServices() async {
    final response = await _api.get('/services');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Service.fromJson(json)).where((s) => s.featured).toList();
    }
    throw Exception('Error al obtener servicios destacados');
  }

  @override
  Future<List<Service>> getAllServices() async {
    final response = await _api.get('/services');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Service.fromJson(json)).toList();
    }
    throw Exception('Error al obtener servicios');
  }

  @override
  Future<List<Service>> searchServices(String query, String category) async {
    final params = <String, String>{};
    if (query.isNotEmpty) params['search'] = query;
    if (category.isNotEmpty && category != 'Todos') params['category'] = category;
    final response = await _api.get('/services', queryParams: params);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Service.fromJson(json)).toList();
    }
    throw Exception('Error al buscar servicios');
  }

  @override
  Future<Service?> getServiceById(String id) async {
    final response = await _api.get('/services/$id');
    if (response.statusCode == 200) {
      return Service.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 404) return null;
    throw Exception('Error al obtener servicio');
  }

  @override
  Future<Service> createService(Service service) async {
    final response = await _api.post('/services', {
      'title': service.title,
      'price': service.price,
      'description': service.description,
      'category': service.category,
      'imageUrl': service.imageUrl,
    });
    if (response.statusCode == 201) {
      return Service.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear servicio');
  }

  @override
  Future<Service> updateService(Service service) async {
    final response = await _api.put('/services/${service.id}', {
      'title': service.title,
      'price': service.price,
      'description': service.description,
      'category': service.category,
      'imageUrl': service.imageUrl,
      'featured': service.featured,
    });
    if (response.statusCode == 200) {
      return Service.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al actualizar servicio');
  }

  @override
  Future<void> deleteService(String id) async {
    final response = await _api.delete('/services/$id');
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar servicio');
    }
  }
}
