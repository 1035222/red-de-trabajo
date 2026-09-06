import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RTServiceCard extends StatelessWidget {
  final String imageUrl;
  final String serviceName;
  final String providerName;
  final double rating;
  final String price;
  final VoidCallback? onTap;

  const RTServiceCard({
    super.key,
    required this.imageUrl,
    required this.serviceName,
    required this.providerName,
    required this.rating,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported_outlined, size: 32, color: AppColors.outline),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    providerName,
                    style: AppTextStyles.labelSm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 12, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(rating.toString(), style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondary, fontSize: 11)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(price, style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
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
