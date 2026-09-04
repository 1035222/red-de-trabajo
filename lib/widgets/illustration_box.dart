import 'package:flutter/material.dart';

class RTIllustrationBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color secondaryColor;

  const RTIllustrationBox({
    super.key,
    required this.icon,
    required this.color,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
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
            color: color.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 96,
        color: color,
      ),
    );
  }
}
