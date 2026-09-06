import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';

class EmailAuthScreen extends StatefulWidget {
  final String email;
  final String name;
  final VoidCallback onAuthorized;

  const EmailAuthScreen({super.key, required this.email, required this.name, required this.onAuthorized});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> with TickerProviderStateMixin {
  bool _isSending = false;
  bool _isVerified = false;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sendAuthorizationEmail();
  }

  Future<void> _sendAuthorizationEmail() async {
    setState(() => _isSending = true);
    try {
      final response = await ApiService().post('/auth/send-authorization-email', {'email': widget.email});
      if (!mounted) return;
      setState(() => _isSending = false);
      if (response.statusCode == 200) {
        HapticFeedback.lightImpact();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo enviar el correo de autorización')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión al enviar autorización')));
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresá el código de autorización')));
      return;
    }
    try {
      final response = await ApiService().post('/auth/verify-authorization', {'code': code});
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() => _isVerified = true);
        widget.onAuthorized();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código inválido')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión')));
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.primaryContainer.withValues(alpha: 0.05)]),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(Icons.mark_email_read_rounded, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Text('Verifica tu acceso', textAlign: TextAlign.center, style: AppTextStyles.headlineMd),
                  const SizedBox(height: 8),
                  Text(
                    'Enviamos un correo a ${widget.email}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingresá el código de autorización que recibiste para continuar.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  if (_isSending)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: [
                        TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Código de autorización',
                            hintText: 'Ej: 123456',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isVerified ? null : _verifyCode,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
                          child: Text(_isVerified ? 'Verificado' : 'Verificar código', style: AppTextStyles.labelLg),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () async {
                            await _sendAuthorizationEmail();
                          },
                    child: Text('Reenviar correo', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
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
