import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/app_user.dart';
import '../services/repository_provider.dart';
import '../services/session_service.dart';
import '../repositories/profile_repository.dart';
import '../screens/my_services_screen.dart';
import '../screens/portfolio_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/notifications_screen.dart';
import '../widgets/avatar.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const ProfileScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final profileRepository = RepositoryProvider.profileRepository;
    final sessionService = SessionService();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FutureBuilder<AppUser>(
        future: _loadUserProfile(profileRepository, sessionService),
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
                  Text('Error al cargar el perfil', style: AppTextStyles.bodyMd),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString().replaceFirst('Exception: ', ''), style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                ],
              ),
            );
          }
          final user = snapshot.data ?? AppUser(id: 'user_1', name: 'Usuario', email: '');

          return Column(
            children: [
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.primary, AppColors.primaryContainer]),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (onBack != null) {
                              onBack!();
                            } else if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.onPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.arrow_back_rounded, color: AppColors.onPrimary, size: 20),
                          ),
                        ),
                        const Spacer(),
                        Text('Perfil', style: AppTextStyles.titleLg.copyWith(color: AppColors.onPrimary)),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.onPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)));
                            },
                            icon: Icon(Icons.edit_rounded, color: AppColors.onPrimary, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -70),
                        child: Column(
                          children: [
                            RTAvatar(
                              imageUrl: user.avatarUrl,
                              size: 120,
                              fallbackInitial: user.name.isNotEmpty ? user.name[0] : 'U',
                            ),
                            const SizedBox(height: 16),
                            Text(user.name, style: AppTextStyles.headlineMd),
                            if ((user.location ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on_outlined, size: 16, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(user.location ?? '', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(label: 'Servicios', value: '${user.servicesCount ?? 0}'),
                            Container(width: 1, height: 40, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                            _StatItem(label: 'Reseñas', value: (user.rating ?? 0).toStringAsFixed(1)),
                            Container(width: 1, height: 40, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                            _StatItem(label: 'Calificación', value: (user.rating ?? 0).toStringAsFixed(1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyServicesScreen()));
                          },
                          icon: const Icon(Icons.work_outline_rounded),
                          label: const Text('Mis servicios'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioScreen()));
                              },
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Portafolio'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewsScreen()));
                              },
                              icon: const Icon(Icons.rate_review_outlined),
                              label: const Text('Reseñas'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                          },
                          icon: const Icon(Icons.notifications_rounded),
                          label: const Text('Notificaciones'),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<AppUser> _loadUserProfile(ProfileRepository profileRepository, SessionService sessionService) async {
  final session = await sessionService.getSession();
  final userId = session?.user?.id ?? 'user_1';
  return profileRepository.getUserProfile(userId);
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineMd.copyWith(color: AppColors.primary)),
        Text(label, style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
