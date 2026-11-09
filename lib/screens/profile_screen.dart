import '../l10n/app_localizations.dart';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/app_user.dart';
import '../models/review.dart';
import '../models/service.dart';
import '../services/repository_provider.dart';
import '../services/session_service.dart';
import '../repositories/profile_repository.dart';
import '../repositories/service_repository.dart';
import '../screens/my_services_screen.dart';
import '../screens/portfolio_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/notifications_screen.dart';
import '../widgets/avatar.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool isActive;

  const ProfileScreen({super.key, this.onBack, this.isActive = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _profileRepository =
      RepositoryProvider.profileRepository;
  final ServiceRepository _serviceRepository =
      RepositoryProvider.serviceRepository;
  final SessionService _sessionService = SessionService();
  late Future<_ProfileSummary?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileSummary();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _refreshProfile();
    }
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _profileFuture = _loadProfileSummary();
    });
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    if (mounted) await _refreshProfile();
  }

  Future<_ProfileSummary?> _loadProfileSummary() async {
    final session = await _sessionService.getSession();
    final userId = session?.user?.id;
    if (userId == null || userId.isEmpty) return null;

    final user = await _profileRepository.getUserProfile(userId);
    final activity = await Future.wait<Object>([
      _serviceRepository.getAllServices(),
      _profileRepository.getUserReviews(user.id),
    ]);
    final services = activity[0] as List<Service>;
    final reviews = activity[1] as List<Review>;
    final userServices = services.where(
      (service) => service.providerId == user.id,
    );
    final averageRating = reviews.isEmpty
        ? user.rating ?? 0
        : reviews.fold<double>(0, (total, review) => total + review.rating) /
              reviews.length;

    return _ProfileSummary(
      user: user,
      servicesCount: userServices.length,
      reviewsCount: reviews.length,
      rating: averageRating,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FutureBuilder<_ProfileSummary?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final summary = snapshot.data;
          if (snapshot.hasError && summary == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    LocalizedText(
                      'Error al cargar el perfil',
                      style: AppTextStyles.bodyMd,
                    ),
                    const SizedBox(height: 8),
                    LocalizedText(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          if (summary == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login_rounded,
                    size: 48,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  LocalizedText(
                    'No has iniciado sesión',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final user = summary.user;
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 180,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.primaryContainer],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 196, 24, 16),
                  child: Column(
                    children: [
                      RTAvatar(
                        imageUrl: user.avatarUrl,
                        size: 120,
                        fallbackInitial: user.name.isNotEmpty
                            ? user.name[0]
                            : 'U',
                      ),
                      const SizedBox(height: 16),
                      LocalizedText(
                        user.name,
                        style: AppTextStyles.headlineMd,
                        textAlign: TextAlign.center,
                      ),
                      if ((user.location ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: LocalizedText(
                                user.location ?? '',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatItem(
                                label: 'Servicios'.tr,
                                value: '${summary.servicesCount}',
                              ),
                            ),
                            _statDivider,
                            Expanded(
                              child: _StatItem(
                                label: 'Reseñas'.tr,
                                value: '${summary.reviewsCount}',
                              ),
                            ),
                            _statDivider,
                            Expanded(
                              child: _StatItem(
                                label: 'Calificación'.tr,
                                value: summary.rating.toStringAsFixed(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _openScreen(const MyServicesScreen()),
                          icon: const Icon(Icons.work_outline_rounded),
                          label: const LocalizedText('Mis servicios'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _openScreen(const PortfolioScreen()),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const LocalizedText('Portafolio'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _openScreen(const ReviewsScreen()),
                              icon: const Icon(Icons.rate_review_outlined),
                              label: const LocalizedText('Reseñas'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _openScreen(const NotificationsScreen()),
                          icon: const Icon(Icons.notifications_rounded),
                          label: const LocalizedText('Notificaciones'),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: SizedBox(
                    height: 64,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _HeaderButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () {
                              if (widget.onBack != null) {
                                widget.onBack!();
                              } else if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          const Spacer(),
                          LocalizedText(
                            'Perfil',
                            style: AppTextStyles.titleLg.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                          const Spacer(),
                          _HeaderButton(
                            icon: Icons.edit_rounded,
                            onTap: () =>
                                _openScreen(EditProfileScreen(user: user)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget get _statDivider => Container(
    width: 1,
    height: 40,
    color: AppColors.outlineVariant.withValues(alpha: 0.5),
  );
}

class _ProfileSummary {
  final AppUser user;
  final int servicesCount;
  final int reviewsCount;
  final double rating;

  const _ProfileSummary({
    required this.user,
    required this.servicesCount,
    required this.reviewsCount,
    required this.rating,
  });
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.onPrimary, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.onPrimary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocalizedText(
          value,
          style: AppTextStyles.headlineMd.copyWith(color: AppColors.primary),
        ),
        LocalizedText(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
