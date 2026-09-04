import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RTPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const RTPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.primary),
        foregroundColor: WidgetStateProperty.all(AppColors.onPrimary),
        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 48)),
        shape: WidgetStateProperty.all(const StadiumBorder()),
        overlayColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(text, style: AppTextStyles.labelLg),
              ],
            ),
    );
  }
}
