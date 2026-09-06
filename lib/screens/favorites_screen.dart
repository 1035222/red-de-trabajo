import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/service.dart';
import '../services/repository_provider.dart';
import '../widgets/service_card.dart';
import '../screens/service_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceRepository = RepositoryProvider.serviceRepository;
    final favoriteIds = <String>{'1', '2', '5'};

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Text('Favoritos', style: AppTextStyles.titleLg),
      ),
      body: FutureBuilder<List<Service>>(
        future: serviceRepository.getAllServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final services = snapshot.data ?? [];
          final favorites = services.where((s) => favoriteIds.contains(s.id)).toList();

          if (favorites.isEmpty) {
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
                    child: Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Text('No tienes favoritos guardados', style: AppTextStyles.headlineMd.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Explora servicios y guarda tus favoritos', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final service = favorites[index];
              return RTServiceCard(
                imageUrl: service.imageUrl,
                serviceName: service.title,
                providerName: service.providerName,
                rating: service.rating,
                price: service.price,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
