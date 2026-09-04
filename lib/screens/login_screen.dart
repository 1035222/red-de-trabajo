import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../repositories/mock_repositories.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _authRepository = MockAuthRepository();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await _authRepository.login(_emailController.text.trim(), _passwordController.text);
      if (!mounted) return;
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credenciales inválidas')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: InputBorder.none,
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                              ),
                              validator: (value) => (value == null || !value.contains('@')) ? 'Ingresa un correo válido' : null,
                            ),
                          ),
                          Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                border: InputBorder.none,
                                labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                              ),
                              validator: (value) => (value == null || value.length < 6) ? 'Mínimo 6 caracteres' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    RTPrimaryButton(text: 'Iniciar sesión', onPressed: _handleLogin, isLoading: _isLoading),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('¿No tienes cuenta?', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: Text('Regístrate', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
