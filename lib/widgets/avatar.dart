import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RTAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String fallbackInitial;

  const RTAvatar({
    super.key,
    this.imageUrl,
    this.size = 56,
    this.fallbackInitial = 'U',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.primaryContainer.withValues(alpha: 0.08)],
        ),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? CircleAvatar(
              radius: size / 2,
              backgroundImage: NetworkImage(imageUrl!),
              onBackgroundImageError: (exception, stackTrace) {},
              child: Container(
                color: AppColors.surfaceContainerHighest,
                child: Icon(Icons.person_rounded, size: size * 0.5, color: AppColors.onSurfaceVariant),
              ),
            )
          : CircleAvatar(
              radius: size / 2,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                fallbackInitial,
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
    );
  }
}
