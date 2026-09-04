import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.onPrimary.withValues(alpha: 0.2), AppColors.onPrimary.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: AppColors.onPrimary.withValues(alpha: 0.15), blurRadius: 32, offset: const Offset(0, 16))],
              ),
              child: Icon(Icons.handshake_rounded, size: 56, color: AppColors.onPrimary),
            ),
            const SizedBox(height: 32),
            Text('Red de Trabajo', style: AppTextStyles.headlineLg.copyWith(color: AppColors.onPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 12),
            Text(
              'Conecta con profesionales',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onPrimary.withValues(alpha: 0.85), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
