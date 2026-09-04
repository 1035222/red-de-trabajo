import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/portfolio_item.dart';
import '../repositories/mock_repositories.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileRepository = MockProfileRepository();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Text('Portafolio', style: AppTextStyles.titleLg),
      ),
      body: FutureBuilder<List<PortfolioItem>>(
        future: profileRepository.getUserPortfolio('user_1'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
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
                    child: Icon(Icons.photo_library_outlined, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Text('No tienes proyectos en tu portafolio', style: AppTextStyles.headlineMd.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Agrega tus trabajos más destacados', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          item.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surfaceContainerHighest,
                              child: Icon(Icons.image_not_supported_outlined, size: 32, color: AppColors.outline),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(item.title, style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
