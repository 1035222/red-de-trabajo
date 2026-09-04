import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/service.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Service service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: AppColors.surface,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Añadido a favoritos')));
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compartiendo servicio...')));
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                service.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported_outlined, size: 64, color: AppColors.outline),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(service.title, style: AppTextStyles.headlineLg)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(service.rating.toString(), style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(service.providerName, style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('Ciudad de México', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(service.price, style: AppTextStyles.headlineMd.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 24),
                  Text('Descripción', style: AppTextStyles.headlineMd),
                  const SizedBox(height: 8),
                  Text(service.description, style: AppTextStyles.bodyMd),
                  const SizedBox(height: 24),
                  Text('Categoría', style: AppTextStyles.headlineMd),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: Text(service.category, style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                  ),
                  const SizedBox(height: 24),
                  Text('Reseñas', style: AppTextStyles.headlineMd),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < service.rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 20,
                          color: AppColors.secondary,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text('${service.rating} (${service.reviewsCount} reseñas)', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Llamando a ${service.providerName}')));
                          },
                          icon: const Icon(Icons.phone_rounded),
                          label: const Text('Llamar'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.onSecondary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitud enviada a ${service.providerName}')));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
                          child: const Text('Solicitar servicio'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
