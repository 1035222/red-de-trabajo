import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../repositories/mock_repositories.dart';
import '../screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = MockAuthRepository();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Text('Configuración', style: AppTextStyles.titleLg),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(title: 'General', children: [
            _SettingsTile(icon: Icons.notifications_outlined, title: 'Notificaciones', trailing: Switch(value: true, onChanged: (value) {}, activeThumbColor: AppColors.primary)),
            _SettingsTile(icon: Icons.language_outlined, title: 'Idioma', trailing: const Text('Español', style: TextStyle(color: AppColors.onSurfaceVariant))),
            _SettingsTile(icon: Icons.dark_mode_outlined, title: 'Modo oscuro', trailing: Switch(value: false, onChanged: (value) {}, activeThumbColor: AppColors.primary)),
          ]),
          const SizedBox(height: 24),
          _SettingsSection(title: 'Cuenta', children: [
            _SettingsTile(icon: Icons.lock_outline_rounded, title: 'Cambiar contraseña', onTap: () {}),
            _SettingsTile(icon: Icons.privacy_tip_outlined, title: 'Privacidad', onTap: () {}),
            _SettingsTile(icon: Icons.help_outline_rounded, title: 'Ayuda y soporte', onTap: () {}),
          ]),
          const SizedBox(height: 24),
          _SettingsSection(title: 'Sesión', children: [
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Cerrar sesión',
              titleColor: AppColors.error,
              onTap: () async {
                await authRepository.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                }
              },
            ),
          ]),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({required this.icon, required this.title, this.trailing, this.onTap, this.titleColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (titleColor ?? AppColors.primary).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: titleColor ?? AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.labelMd.copyWith(color: titleColor ?? AppColors.onSurface)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
