import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../screens/home_screen.dart';
import '../screens/create_password_screen.dart';
import '../services/firebase_auth_service.dart';
import '../services/session_service.dart';
import '../models/app_user.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _sessionService = SessionService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingSession() async {
    final session = await _sessionService.getSession();
    if (!mounted) return;
    if (session != null && session.authorized) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await FirebaseAuthService().signInWithGoogle();
      if (!mounted) return;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicio cancelado')));
        return;
      }

      await _syncAndSaveSession(user);

      if (!mounted) return;
      final hasPassword = FirebaseAuthService().hasEmailPasswordLinked(user);
      if (!mounted) return;
      if (hasPassword) {
        await _sessionService.setAuthorized(true);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePasswordScreen(email: user.email ?? '', name: user.displayName ?? 'Usuario')));
      }
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = await FirebaseAuthService().signInWithEmailAndPassword(_emailController.text.trim(), _passwordController.text);
      if (!mounted) return;
      if (user != null) {
        await _syncAndSaveSession(user);
        if (!mounted) return;
        await _sessionService.setAuthorized(true);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _syncAndSaveSession(User user) async {
    try {
      final backendData = await FirebaseAuthService().syncUserWithBackend(ApiConfig.baseUrl);
      final appUser = AppUser(
        id: backendData['id'] ?? user.uid,
        name: backendData['name'] ?? user.displayName ?? 'Usuario',
        email: backendData['email'] ?? user.email ?? '',
        avatarUrl: backendData['avatarUrl'] ?? user.photoURL ?? '',
      );
      final idToken = await user.getIdToken();
      await _sessionService.saveSession(user: appUser, token: idToken ?? user.uid, authorized: true);
    } on Exception catch (e) {
      final appUser = AppUser(
        id: user.uid,
        name: user.displayName ?? 'Usuario',
        email: user.email ?? '',
        avatarUrl: user.photoURL ?? '',
      );
      final idToken = await user.getIdToken();
      await _sessionService.saveSession(user: appUser, token: idToken ?? user.uid, authorized: true);
      throw Exception('Sesión iniciada localmente. ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.primaryContainer.withValues(alpha: 0.08)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 12))],
                      ),
                      child: Icon(Icons.handshake_rounded, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 32),
                    Text('Bienvenido', textAlign: TextAlign.center, style: AppTextStyles.headlineLg),
                    const SizedBox(height: 8),
                    Text('Inicia sesión para continuar', textAlign: TextAlign.center, style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || !value.contains('@')) ? 'Ingresa un correo válido' : null,
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 24),
                    RTPrimaryButton(text: 'Iniciar sesión', onPressed: _isLoading ? null : _handleEmailLogin, isLoading: _isLoading),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: Icon(Icons.login_rounded, color: AppColors.primary),
                      label: Text('Continuar con Google', style: AppTextStyles.labelMd),
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
