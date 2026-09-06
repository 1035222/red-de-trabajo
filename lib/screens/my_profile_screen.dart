import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/app_user.dart';
import '../services/repository_provider.dart';
import '../services/session_service.dart';
import '../repositories/profile_repository.dart';
import 'edit_profile_screen.dart';
import 'portfolio_screen.dart';
import 'reviews_screen.dart';
import 'settings_screen.dart';
import 'my_services_screen.dart';
import 'notifications_screen.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileRepository = RepositoryProvider.profileRepository;
    final sessionService = SessionService();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Mi perfil', style: AppTextStyles.titleLg),
      ),
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfileTile(
                icon: Icons.person_outline_rounded,
                title: 'Información personal',
                subtitle: user.name,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)));
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.work_outline_rounded,
                title: 'Mis servicios',
                subtitle: '${user.servicesCount ?? 0} servicios publicados',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyServicesScreen()));
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.photo_library_outlined,
                title: 'Portafolio',
                subtitle: '${user.servicesCount ?? 0} proyectos',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioScreen()));
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.rate_review_outlined,
                title: 'Reseñas',
                subtitle: 'Calificación ${(user.rating ?? 0).toStringAsFixed(1)}',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewsScreen()));
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.notifications_rounded,
                title: 'Notificaciones',
                subtitle: 'Actividad reciente',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.settings_outlined,
                title: 'Configuración',
                subtitle: 'Notificaciones, privacidad, tema',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
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

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.labelMd),
      subtitle: Text(subtitle, style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
      onTap: onTap,
    );
  }
}
