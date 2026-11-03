import '../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/notification.dart';
import '../services/app_navigation.dart';
import '../services/repository_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationRepository = RepositoryProvider.notificationRepository;
  late Future<List<AppNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationRepository.getNotifications();
  }

  Future<void> _refresh() async {
    final request = _notificationRepository.getNotifications();
    setState(() => _notificationsFuture = request);
    await request;
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.read) return;
    try {
      await _notificationRepository.markAsRead(notification.id);
      await _refresh();
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
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
        title: LocalizedText('Notificaciones', style: AppTextStyles.titleLg),
        actions: [
          IconButton(
            tooltip: 'Actualizar'.tr,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: _notificationsFuture,
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
                  LocalizedText('Error al cargar notificaciones', style: AppTextStyles.bodyMd),
                  const SizedBox(height: 8),
                  LocalizedText(snapshot.error.toString().replaceFirst('Exception: ', ''), style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                ],
              ),
            );
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.outline),
                  const SizedBox(height: 16),
                  LocalizedText('No tienes notificaciones', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    await _markAsRead(notification);
                    final data = notification.data;
                    if (data != null) {
                      AppNavigation.handleNotification(data);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: notification.read ? AppColors.surfaceContainerLowest : AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: notification.read ? Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)) : Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.primaryContainer.withValues(alpha: 0.06)]),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.notifications_rounded, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LocalizedText(notification.title, style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600)),
                                  LocalizedText(_formatDate(notification.time), style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            if (!notification.read) Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LocalizedText(notification.body, style: AppTextStyles.bodyMd),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }
}
