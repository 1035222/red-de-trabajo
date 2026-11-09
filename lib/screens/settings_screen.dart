import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/session_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/app_preferences.dart';
import '../services/push_notification_service.dart';
import '../services/google_sign_in_service.dart';
import '../screens/create_password_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _loadingNotifications = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
    _darkModeEnabled = AppPreferences.instance.darkModeEnabled;
  }

  Future<void> _toggleDarkMode(bool enabled) async {
    await AppPreferences.instance.setDarkMode(enabled);
    if (!mounted) return;
    setState(() => _darkModeEnabled = enabled);
  }

  Future<void> _chooseLanguage() async {
    final locale = await showDialog<Locale>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const LocalizedText('Idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in [
              (locale: const Locale('es'), label: 'Español'.tr),
              (locale: const Locale('en'), label: 'English'.tr),
            ])
              ListTile(
                title: LocalizedText(option.label),
                trailing:
                    AppPreferences.instance.locale.languageCode ==
                        option.locale.languageCode
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(dialogContext, option.locale),
              ),
          ],
        ),
      ),
    );
    if (locale == null) return;
    try {
      await AppPreferences.instance.setLocale(locale);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _showUnavailablePrivacy() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const LocalizedText('Privacidad'),
        content: const LocalizedText(
          'La política de privacidad oficial todavía no está disponible. Se publicará aquí cuando haya sido aprobada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const LocalizedText('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showSupportInformation() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const LocalizedText('Ayuda y soporte'),
        content: const LocalizedText(
          'Todavía no hay un canal oficial de soporte configurado. Para problemas de acceso, verifica tu conexión y que el correo esté habilitado en Firebase. Si no llegan notificaciones, permite los avisos en el navegador o dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const LocalizedText('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadNotificationPreference() async {
    final enabled = await PushNotificationService.isEnabled();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _loadingNotifications = false;
    });
  }

  Future<void> _toggleNotifications(bool enabled) async {
    setState(() => _loadingNotifications = true);
    try {
      if (enabled) {
        await PushNotificationService.enable();
      } else {
        await PushNotificationService.disable();
      }
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = enabled;
        _loadingNotifications = false;
      });
    } on Exception catch (error) {
      final currentPreference = await PushNotificationService.isEnabled();
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = currentPreference;
        _loadingNotifications = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LocalizedText(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _managePassword() async {
    final user = FirebaseAuthService().currentUser;
    if (user == null || user.email == null) {
      _showMessage('No se encontró el correo de la cuenta actual');
      return;
    }

    if (!FirebaseAuthService().hasEmailPasswordLinked(user)) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePasswordScreen(
            email: user.email!,
            name: user.displayName ?? 'Usuario',
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      _showMessage('Te enviamos un enlace para cambiar la contraseña');
    } on FirebaseAuthException catch (error) {
      _showMessage(
        error.code == 'user-not-found'
            ? 'No existe una cuenta con ese correo'
            : 'No se pudo enviar el enlace de recuperación',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: LocalizedText(message)));
  }

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: LocalizedText('Configuración', style: AppTextStyles.titleLg),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'General'.tr,
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones'.tr,
                trailing: _loadingNotifications
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        activeThumbColor: AppColors.primary,
                      ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.language_outlined,
                title: 'Idioma'.tr,
                trailing: LocalizedText(
                  AppPreferences.instance.locale.languageCode == 'en'
                      ? 'English'
                      : 'Español',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
                onTap: _chooseLanguage,
              ),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Modo oscuro'.tr,
                trailing: Switch(
                  value: _darkModeEnabled,
                  onChanged: _toggleDarkMode,
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Cuenta'.tr,
            children: [
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: 'Cambiar contraseña'.tr,
                onTap: _managePassword,
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacidad'.tr,
                onTap: _showUnavailablePrivacy,
              ),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Ayuda y soporte'.tr,
                onTap: _showSupportInformation,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Sesión'.tr,
            children: [
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Cerrar sesión'.tr,
                titleColor: AppColors.error,
                onTap: () async {
                  try {
                    await FirebaseAuthService().signOut();
                    await sessionService.clearSession();
                    await GoogleSignInService.signOut();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: LocalizedText('Error al cerrar sesión: $e'),
                        ),
                      );
                    }
                  }
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
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
          child: LocalizedText(
            title,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
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

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
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
        title: LocalizedText(
          title,
          style: AppTextStyles.labelMd.copyWith(
            color: titleColor ?? AppColors.onSurface,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
