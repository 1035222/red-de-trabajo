import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RTPublishFab extends StatelessWidget {
  final VoidCallback onTap;

  const RTPublishFab({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      shape: const StadiumBorder(),
      elevation: 4,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}
