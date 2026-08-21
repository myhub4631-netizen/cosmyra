import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme/app_colors.dart';

/// Helper widget to render both asset, base64 data, and network product images cleanly
class ProductImageWidget extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  static final Map<String, Uint8List> _base64Cache = {};

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
    final String trimmedUrl = imageUrl.trim();

    if (trimmedUrl.isEmpty) {
      return Container(
        color: isDark ? AppColors.charcoalCard : AppColors.sageLight,
        child: Center(
          child: Image.asset('assets/images/cosmyra_logo.png', height: 24, fit: BoxFit.contain),
        ),
      );
    }

    if (trimmedUrl.startsWith('data:')) {
      try {
        final Uint8List bytes = _base64Cache.putIfAbsent(trimmedUrl, () {
          String cleanBase64 = trimmedUrl.split(',').last.replaceAll(RegExp(r'[\r\n\s]+'), '');
          try {
            return base64Decode(cleanBase64);
          } catch (_) {
            cleanBase64 = Uri.decodeComponent(cleanBase64).replaceAll(RegExp(r'[\r\n\s]+'), '');
            return base64Decode(cleanBase64);
          }
        });

        return Image.memory(
          bytes,
          key: ValueKey('base64_${trimmedUrl.hashCode}_${trimmedUrl.length}'),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Container(
            color: isDark ? AppColors.charcoalCard : AppColors.sageLight,
            child: Center(
              child: Image.asset('assets/images/cosmyra_logo.png', height: 24, fit: BoxFit.contain),
            ),
          ),
        );
      } catch (_) {
        return Container(
          color: isDark ? AppColors.charcoalCard : AppColors.sageLight,
          child: Center(
            child: Image.asset('assets/images/cosmyra_logo.png', height: 24, fit: BoxFit.contain),
          ),
        );
      }
    }

    if (trimmedUrl.startsWith('assets/')) {
      return Image.asset(
        trimmedUrl,
        key: ValueKey('asset_$trimmedUrl'),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: isDark ? AppColors.charcoalCard : AppColors.sageLight,
          child: Center(
            child: Image.asset('assets/images/cosmyra_logo.png', height: 24, fit: BoxFit.contain),
          ),
        ),
      );
    }

    if (kIsWeb) {
      return Image.network(
        trimmedUrl,
        key: ValueKey('web_net_$trimmedUrl'),
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: isDark ? AppColors.charcoalCard : AppColors.sageLight,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldAccent),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: isDark ? AppColors.charcoalCard : AppColors.sageLight,
          child: Center(
            child: Image.asset('assets/images/cosmyra_logo.png', height: 24, fit: BoxFit.contain),
          ),
        ),
      );
    }

    // Native Android / iOS Build: Fetch fresh live images from Supabase Storage
    final String liveNativeUrl = trimmedUrl.startsWith('http')
        ? (trimmedUrl.contains('?') ? '$trimmedUrl&t=${DateTime.now().millisecondsSinceEpoch ~/ 300000}' : '$trimmedUrl?t=${DateTime.now().millisecondsSinceEpoch ~/ 300000}')
        : trimmedUrl;

    return CachedNetworkImage(
      key: ValueKey('native_net_${liveNativeUrl.hashCode}'),
      imageUrl: liveNativeUrl,
      cacheKey: liveNativeUrl,
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
        child: Center(
          child: Image.asset('assets/images/cosmyra_logo.png', height: 24, fit: BoxFit.contain),
        ),
      ),
    );
  }

  static void clearAllCaches([String? specificUrl]) {
    _base64Cache.clear();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    if (specificUrl != null && specificUrl.isNotEmpty) {
      try {
        CachedNetworkImage.evictFromCache(specificUrl);
      } catch (_) {}
    }
  }
}
