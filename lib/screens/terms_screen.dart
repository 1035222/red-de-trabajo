import '../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: LocalizedText('Términos y condiciones', style: AppTextStyles.titleLg),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedText('Términos y condiciones', style: AppTextStyles.headlineMd),
                const SizedBox(height: 16),
                LocalizedText(
                  'Al utilizar Red de Trabajo, aceptas cumplir con estos términos y condiciones. '
                  'La plataforma conecta a personas que ofrecen servicios con usuarios que necesitan contratarlos, '
                  'pero no se hace responsable de las transacciones o acuerdos entre usuarios.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: 24),
                LocalizedText('1. Uso de la plataforma', style: AppTextStyles.labelMd),
                const SizedBox(height: 8),
                LocalizedText(
                  'Los usuarios deben proporcionar información veraz y actualizada. '
                  'Está prohibido el uso de la plataforma para actividades ilegales o fraudulentas.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: 24),
                LocalizedText('2. Responsabilidades', style: AppTextStyles.labelMd),
                const SizedBox(height: 8),
                LocalizedText(
                  'Red de Trabajo actúa como intermediario y no garantiza la calidad de los servicios. '
                  'Los usuarios son responsables de sus propios actos y acuerdos.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: 24),
                LocalizedText('3. Privacidad', style: AppTextStyles.labelMd),
                const SizedBox(height: 8),
                LocalizedText(
                  'La política de privacidad oficial todavía no está disponible. '
                  'Se publicará aquí cuando haya sido aprobada.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: 24),
                LocalizedText('4. Modificaciones', style: AppTextStyles.labelMd),
                const SizedBox(height: 8),
                LocalizedText(
                  'Nos reservamos el derecho de modificar estos términos en cualquier momento. '
                  'Te notificaremos sobre cambios importantes mediante la aplicación.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
