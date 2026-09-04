import '../models/service.dart';
import '../models/category.dart';

abstract class ServiceRepository {
  Future<List<Service>> getFeaturedServices();
  Future<List<Service>> getAllServices();
  Future<List<Service>> searchServices(String query, String category);
  Future<Service?> getServiceById(String id);
  Future<Service> createService(Service service);
  Future<List<Category>> getCategories();
}
