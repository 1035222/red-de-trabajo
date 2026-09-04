import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/service.dart';
import '../repositories/mock_repositories.dart';
import '../widgets/service_card.dart';
import '../screens/service_detail_screen.dart';
import '../screens/edit_service_screen.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  final _serviceRepository = MockServiceRepository();
  List<Service> _myServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final services = await _serviceRepository.getAllServices();
    if (mounted) {
      setState(() {
        _myServices = services.where((s) => s.providerId == 'user_1').toList();
        _isLoading = false;
      });
    }
  }

  void _showServiceOptions(BuildContext context, Service service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility_outlined, color: AppColors.primary),
                title: const Text('Ver detalle'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditServiceScreen(service: service)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outlined, color: AppColors.error),
                title: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, service);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar servicio'),
          content: Text('¿Estás seguro de que deseas eliminar "${service.title}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: AppColors.error))),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      setState(() => _myServices.removeWhere((s) => s.id == service.id));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${service.title}" eliminado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Text('Mis servicios', style: AppTextStyles.titleLg),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myServices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withValues(alpha: 0.12), AppColors.primaryContainer.withValues(alpha: 0.06)]),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(Icons.work_outline_rounded, size: 48, color: AppColors.primary),
                      ),
                      const SizedBox(height: 24),
                      Text('No tienes servicios publicados', style: AppTextStyles.headlineMd.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Text('Publica tu primer servicio para comenzar', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _myServices.length,
                  itemBuilder: (context, index) {
                    final service = _myServices[index];
                    return RTServiceCard(
                      imageUrl: service.imageUrl,
                      serviceName: service.title,
                      providerName: service.providerName,
                      rating: service.rating,
                      price: service.price,
                      onTap: () {
                        _showServiceOptions(context, service);
                      },
                    );
                  },
                ),
    );
  }
}
