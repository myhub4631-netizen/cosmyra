import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/web_helper.dart';

class BrandSettings {
  final String headerLogoUrl;
  final String footerLogoUrl;
  final String faviconUrl;
  final String appIconUrl;
  final String brandName;
  final String brandTagline;
  final bool hideBrandTextWithLogo;

  const BrandSettings({
    this.headerLogoUrl = '',
    this.footerLogoUrl = '',
    this.faviconUrl = '',
    this.appIconUrl = '',
    this.brandName = 'Cosmyra',
    this.brandTagline = 'Pure Ayurveda & Botanical Wellness',
    this.hideBrandTextWithLogo = false,
  });

  BrandSettings copyWith({
    String? headerLogoUrl,
    String? footerLogoUrl,
    String? faviconUrl,
    String? appIconUrl,
    String? brandName,
    String? brandTagline,
    bool? hideBrandTextWithLogo,
  }) {
    return BrandSettings(
      headerLogoUrl: headerLogoUrl ?? this.headerLogoUrl,
      footerLogoUrl: footerLogoUrl ?? this.footerLogoUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      appIconUrl: appIconUrl ?? this.appIconUrl,
      brandName: brandName ?? this.brandName,
      brandTagline: brandTagline ?? this.brandTagline,
      hideBrandTextWithLogo: hideBrandTextWithLogo ?? this.hideBrandTextWithLogo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headerLogoUrl': headerLogoUrl,
      'footerLogoUrl': footerLogoUrl,
      'faviconUrl': faviconUrl,
      'appIconUrl': appIconUrl,
      'brandName': brandName,
      'brandTagline': brandTagline,
      'hideBrandTextWithLogo': hideBrandTextWithLogo,
    };
  }

  factory BrandSettings.fromJson(Map<String, dynamic> json) {
    return BrandSettings(
      headerLogoUrl: json['headerLogoUrl']?.toString() ?? '',
      footerLogoUrl: json['footerLogoUrl']?.toString() ?? '',
      faviconUrl: json['faviconUrl']?.toString() ?? '',
      appIconUrl: json['appIconUrl']?.toString() ?? '',
      brandName: json['brandName']?.toString() ?? 'Cosmyra',
      brandTagline: json['brandTagline']?.toString() ?? 'Pure Ayurveda & Botanical Wellness',
      hideBrandTextWithLogo: json['hideBrandTextWithLogo'] == true,
    );
  }
}

class BrandSettingsNotifier extends StateNotifier<BrandSettings> {
  static const String _key = 'cosmyra_brand_settings';

  BrandSettingsNotifier() : super(const BrandSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        state = BrandSettings.fromJson(map);
        _updateDomFavicon(state.faviconUrl);
      }
    } catch (_) {}

    try {
      if (SupabaseConfig.isConfigured) {
        final response = await supabase
            .from('brands')
            .select('logo_url')
            .eq('id', '6242b75a-f2b3-4895-8927-95ce0e24fa3c')
            .maybeSingle();

        if (response != null && response['logo_url'] != null) {
          final String remoteLogo = response['logo_url'].toString();
          if (remoteLogo.isNotEmpty) {
            state = state.copyWith(
              headerLogoUrl: state.headerLogoUrl.isEmpty ? remoteLogo : state.headerLogoUrl,
              footerLogoUrl: state.footerLogoUrl.isEmpty ? remoteLogo : state.footerLogoUrl,
              appIconUrl: state.appIconUrl.isEmpty ? remoteLogo : state.appIconUrl,
            );
          }
        }
      }
    } catch (_) {}
  }

  Future<void> updateSettings({
    String? headerLogoUrl,
    String? footerLogoUrl,
    String? faviconUrl,
    String? appIconUrl,
    String? brandName,
    String? brandTagline,
    bool? hideBrandTextWithLogo,
  }) async {
    state = state.copyWith(
      headerLogoUrl: headerLogoUrl,
      footerLogoUrl: footerLogoUrl,
      faviconUrl: faviconUrl,
      appIconUrl: appIconUrl,
      brandName: brandName,
      brandTagline: brandTagline,
      hideBrandTextWithLogo: hideBrandTextWithLogo,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(state.toJson()));
      if (faviconUrl != null) {
        _updateDomFavicon(faviconUrl);
      }

      final activeLogo = appIconUrl ?? headerLogoUrl ?? footerLogoUrl;
      if (activeLogo != null && activeLogo.isNotEmpty && SupabaseConfig.isConfigured) {
        await supabase
            .from('brands')
            .update({'logo_url': activeLogo})
            .eq('id', '6242b75a-f2b3-4895-8927-95ce0e24fa3c');
      }
    } catch (_) {}
  }

  void _updateDomFavicon(String url) {
    if (!kIsWeb) return;
    updateDomFavicon(url);
  }
}

final brandSettingsProvider = StateNotifierProvider<BrandSettingsNotifier, BrandSettings>((ref) {
  return BrandSettingsNotifier();
});
