import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/service.dart';
import '../repositories/mock_repositories.dart';
import '../widgets/service_card.dart';
import '../screens/service_detail_screen.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceRepository = MockServiceRepository();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Text('Solicitudes', style: AppTextStyles.titleLg),
      ),
      body: FutureBuilder<List<Service>>(
        future: serviceRepository.getAllServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final services = snapshot.data ?? [];
          final requests = services.where((s) => s.id == '1' || s.id == '2').toList();

          if (requests.isEmpty) {
            return Center(
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
                    child: Icon(Icons.inbox_outlined, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Text('No tienes solicitudes pendientes', style: AppTextStyles.headlineMd.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Las solicitudes de servicio aparecerán aquí', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final service = requests[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RTServiceCard(
                  imageUrl: service.imageUrl,
                  serviceName: service.title,
                  providerName: service.providerName,
                  rating: service.rating,
                  price: service.price,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
