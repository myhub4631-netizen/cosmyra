import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme/app_colors.dart';

/// Helper widget to render both asset, base64 data, and network product images cleanly
class ProductImageWidget extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl.startsWith('data:')) {
      try {
        final base64Str = imageUrl.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Container(
            color: isDark ? AppColors.charcoalCard : AppColors.sageLight,
            child: const Center(child: Icon(Icons.spa, color: AppColors.sageMuted)),
          ),
        );
      } catch (_) {
        return Container(
          color: isDark ? AppColors.charcoalCard : AppColors.sageLight,
          child: const Center(child: Icon(Icons.spa, color: AppColors.sageMuted)),
        );
      }
    }

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: isDark ? AppColors.charcoalCard : AppColors.sageLight,
          child: const Center(child: Icon(Icons.spa, color: AppColors.sageMuted)),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        color: isDark ? AppColors.charcoalCard : AppColors.sageLight,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldAccent),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: isDark ? AppColors.charcoalCard : AppColors.sageLight,
        child: const Center(child: Icon(Icons.spa, color: AppColors.sageMuted)),
      ),
    );
  }
}
