import '../l10n/app_localizations.dart';
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
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: hasImage
            ? Image.network(
              imageUrl!,
                loadingBuilder: (context, child, progress) => progress == null ? child : Container(
                  color: AppColors.surfaceContainerLowest,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorBuilder: (context, error, stackTrace) => _buildFallback(),
                fit: BoxFit.cover,
                width: size,
                height: size,
              )
            : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: LocalizedText(
        fallbackInitial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
