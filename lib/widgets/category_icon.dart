import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class RTCategoryIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? label;

  const RTCategoryIcon({
    super.key,
    required this.icon,
    required this.color,
    this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.06)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          if (label != null) ...[
            const SizedBox(height: 10),
            Text(label!, style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}
