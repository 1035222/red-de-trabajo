import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../services/firebase_auth_service.dart';
import '../services/session_service.dart';
import '../models/app_user.dart';
import '../screens/home_screen.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String email;
  final String name;

  const CreatePasswordScreen({super.key, required this.email, required this.name});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden')));
      return;
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final authService = FirebaseAuthService();
      await authService.linkEmailAndPassword(widget.email, _passwordController.text.trim());

      final user = FirebaseAuthService().currentUser;
      if (user != null) {
        try {
          await FirebaseAuthService().syncUserWithBackend(ApiConfig.baseUrl);
        } on Exception catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contraseña creada. Sync backend: ${e.toString().replaceFirst('Exception: ', '')}')));
          }
        }
      }

      if (!mounted) return;
      final sessionUser = FirebaseAuthService().currentUser;
      if (sessionUser != null) {
        final idToken = await sessionUser.getIdToken();
        Map<String, dynamic> backendData;
        try {
          backendData = await FirebaseAuthService().syncUserWithBackend(ApiConfig.baseUrl);
        } on Exception catch (e) {
          backendData = {
            'id': sessionUser.uid,
            'name': sessionUser.displayName ?? 'Usuario',
            'email': sessionUser.email ?? '',
            'avatarUrl': sessionUser.photoURL ?? '',
          };
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync backend: ${e.toString().replaceFirst('Exception: ', '')}')));
          }
        }
        final appUser = AppUser(
          id: backendData['id'] ?? sessionUser.uid,
          name: backendData['name'] ?? sessionUser.displayName ?? 'Usuario',
          email: backendData['email'] ?? sessionUser.email ?? '',
          avatarUrl: backendData['avatarUrl'] ?? sessionUser.photoURL ?? '',
        );
        await SessionService().saveSession(user: appUser, token: idToken ?? sessionUser.uid, authorized: true);
      }
      messenger.showSnackBar(const SnackBar(content: Text('Contraseña creada exitosamente')));
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } on Exception catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    Text('Crea tu contraseña', textAlign: TextAlign.center, style: AppTextStyles.headlineMd),
                    const SizedBox(height: 8),
                    Text(
                      'Para ${widget.email}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Asocia una contraseña a tu cuenta para iniciar sesión más rápido la próxima vez.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.length < 6) ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: Icon(Icons.lock_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 24),
                    RTPrimaryButton(text: 'Guardar contraseña', onPressed: _handleCreatePassword, isLoading: _isLoading),
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
