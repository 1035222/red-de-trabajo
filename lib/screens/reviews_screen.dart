import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/review.dart';
import '../services/repository_provider.dart';
import '../services/session_service.dart';
import '../repositories/profile_repository.dart';
import '../widgets/avatar.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileRepository = RepositoryProvider.profileRepository;
    final sessionService = SessionService();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Text('Reseñas', style: AppTextStyles.titleLg),
      ),
      body: FutureBuilder<List<Review>>(
        future: _loadUserReviews(profileRepository, sessionService),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Error al cargar reseñas', style: AppTextStyles.bodyMd),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString().replaceFirst('Exception: ', ''), style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                ],
              ),
            );
          }
          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) {
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
                    child: Icon(Icons.rate_review_outlined, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Text('Aún no tienes reseñas', style: AppTextStyles.headlineMd.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Las reseñas de tus servicios aparecerán aquí', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RTAvatar(
                          imageUrl: review.userAvatar,
                          size: 44,
                          fallbackInitial: review.userName.isNotEmpty ? review.userName[0] : '?',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(review.userName, style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600)),
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    return Icon(
                                      index < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                                      size: 14,
                                      color: AppColors.secondary,
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  Text(_formatDate(review.date), style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(review.comment, style: AppTextStyles.bodyMd),
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

Future<List<Review>> _loadUserReviews(ProfileRepository profileRepository, SessionService sessionService) async {
  final session = await sessionService.getSession();
  final userId = session?.user?.id ?? 'user_1';
  return profileRepository.getUserReviews(userId);
}

String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }

