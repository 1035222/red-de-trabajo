import '../l10n/app_localizations.dart';

import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/app_user.dart';
import '../screens/home_screen.dart';
import '../services/firebase_auth_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    var firebaseAccountCreated = false;

    try {
      final authService = FirebaseAuthService();
      final user = await authService.registerWithEmailAndPassword(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
      firebaseAccountCreated = true;

      final backendData = await authService.syncUserWithBackend(
        ApiConfig.baseUrl,
      );

      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Firebase no pudo generar el token de acceso');
      }
      final appUser = AppUser(
        id: backendData['id'] ?? user.uid,
        name:
            backendData['name'] ??
            user.displayName ??
            _nameController.text.trim(),
        email:
            backendData['email'] ?? user.email ?? _emailController.text.trim(),
        avatarUrl: backendData['avatarUrl'] ?? user.photoURL ?? '',
      );
      await SessionService().saveSession(
        user: appUser,
        token: idToken,
        authorized: true,
      );

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: LocalizedText('Cuenta creada. ¡Bienvenido!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: LocalizedText(
            '${firebaseAccountCreated ? 'La cuenta se creó en Firebase, pero no se pudo sincronizar con la aplicación. ' : ''}${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Ingresa un correo válido'.tr;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LocalizedText(
                      'Crea tu cuenta',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMd,
                    ),
                    const SizedBox(height: 8),
                    LocalizedText(
                      'Regístrate con cualquier correo electrónico',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Nombre'.tr,
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().length < 2)
                          ? 'Ingresa tu nombre'.tr.tr
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico'.tr,
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: 'Contraseña'.tr,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Mostrar contraseña'.tr
                              : 'Ocultar contraseña'.tr,
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.length < 6)
                          ? 'La contraseña debe tener al menos 6 caracteres'.tr
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmation,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña'.tr,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          tooltip: _obscureConfirmation
                              ? 'Mostrar contraseña'.tr
                              : 'Ocultar contraseña'.tr,
                          icon: Icon(
                            _obscureConfirmation
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmation = !_obscureConfirmation,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value != _passwordController.text
                          ? 'Las contraseñas no coinciden'.tr
                          : null,
                    ),
                    const SizedBox(height: 24),
                    RTPrimaryButton(
                      text: 'Crear cuenta'.tr,
                      onPressed: _isLoading ? null : _handleRegister,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: LocalizedText(
                        '¿Ya tienes cuenta? Inicia sesión',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
