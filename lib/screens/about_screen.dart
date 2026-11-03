import '../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: LocalizedText('Acerca de', style: AppTextStyles.titleLg),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                       child: const Icon(Icons.handshake_rounded, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  LocalizedText('Red de Trabajo', style: AppTextStyles.headlineLg),
                  const SizedBox(height: 8),
                  LocalizedText('Versión 1.0.0', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  LocalizedText(
                    'Conectando personas que ofrecen servicios con quienes necesitan contratarlos. '
                    'Nuestra misión es facilitar el encuentro entre profesionales, trabajadores independientes '
                    'y usuarios que buscan servicios de calidad.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share_rounded),
                          label: const LocalizedText('Compartir'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
