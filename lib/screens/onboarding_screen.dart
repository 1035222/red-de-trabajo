import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../screens/login_screen.dart';

class OnboardingPageData {
  final Widget illustration;
  final String title;
  final String description;

  const OnboardingPageData({
    required this.illustration,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      illustration: _AnimatedIllustration(
        icon: Icons.search_rounded,
        color: AppColors.primary,
        secondaryColor: AppColors.primaryContainer,
      ),
      title: 'Encuentra el servicio que necesitas',
      description: 'Conecta con los mejores profesionales de tu zona de forma rápida y segura.',
    ),
    OnboardingPageData(
      illustration: _AnimatedIllustration(
        icon: Icons.person_add_rounded,
        color: AppColors.secondary,
        secondaryColor: AppColors.secondaryContainer,
      ),
      title: 'Haz visibles tus habilidades',
      description: 'Crea un perfil profesional, publica tus servicios y conecta con oportunidades reales.',
    ),
    OnboardingPageData(
      illustration: _AnimatedIllustration(
        icon: Icons.handshake_rounded,
        color: AppColors.primaryContainer,
        secondaryColor: AppColors.primaryFixedDim,
      ),
      title: 'Conecta y trabaja',
      description: 'Encuentra profesionales calificados o clientes ideales. Todo en un solo lugar.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700 || size.width < 360;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Saltar', style: GoogleFonts.inter(fontSize: isSmallScreen ? 13 : 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _OnboardingPage(data: _pages[index], isSmallScreen: isSmallScreen),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24, vertical: isSmallScreen ? 20 : 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: isActive ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 32),

                  Row(
                    children: [
                      SizedBox(
                        width: isSmallScreen ? 70 : 80,
                        child: _currentPage == 0
                            ? SizedBox(height: isSmallScreen ? 40 : 48)
                            : TextButton(
                                onPressed: _previousPage,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 10, vertical: isSmallScreen ? 10 : 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(color: AppColors.primaryFixedDim),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_back_rounded, size: isSmallScreen ? 16 : 18),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text('Anterior', style: GoogleFonts.inter(fontSize: isSmallScreen ? 11 : 12, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const Spacer(),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                            shadowColor: AppColors.primary.withValues(alpha: 0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(isLastPage ? 'Comenzar' : 'Continuar', style: GoogleFonts.inter(fontSize: isSmallScreen ? 12 : 13, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 4 : 6),
                              Icon(isLastPage ? Icons.arrow_forward_rounded : Icons.arrow_forward_rounded, size: isSmallScreen ? 16 : 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final bool isSmallScreen;

  const _OnboardingPage({required this.data, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxBox = constraints.maxHeight * 0.32;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: maxBox,
                constraints: BoxConstraints(maxWidth: 260, maxHeight: maxBox),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.primaryContainer.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(child: data.illustration),
              ),
              SizedBox(height: isSmallScreen ? 24 : 40),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: isSmallScreen ? 22 : 28, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: AppColors.onBackground, height: 1.2),
              ),
              SizedBox(height: isSmallScreen ? 8 : 16),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isSmallScreen ? 280 : 320),
                child: Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant, height: 1.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedIllustration extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color secondaryColor;

  const _AnimatedIllustration({
    required this.icon,
    required this.color,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight;
        final iconSize = size * 0.45;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.18),
                secondaryColor.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: color,
          ),
        );
      },
    );
  }
}
