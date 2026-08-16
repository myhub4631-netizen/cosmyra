import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    this.brandName = 'Vaidyam Botanicals',
    this.brandTagline = 'Pure Ayurveda. Real Results.',
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
      brandName: json['brandName']?.toString() ?? 'Vaidyam Botanicals',
      brandTagline: json['brandTagline']?.toString() ?? 'Pure Ayurveda. Real Results.',
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
    } catch (e) {
      // Use defaults if load fails
    }
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
    } catch (e) {
      // Handle save error
    }
  }

  void _updateDomFavicon(String url) {
    if (!kIsWeb) return;
    try {
      final String targetUrl = url.isNotEmpty ? url : 'favicon.png?v=${DateTime.now().millisecondsSinceEpoch}';
      final links = html.document.querySelectorAll("link[rel*='icon']");
      for (final link in links) {
        link.setAttribute('href', targetUrl);
      }
      final element = html.document.getElementById('app-favicon');
      if (element != null) {
        element.setAttribute('href', targetUrl);
      }
    } catch (_) {}
  }
}

final brandSettingsProvider = StateNotifierProvider<BrandSettingsNotifier, BrandSettings>((ref) {
  return BrandSettingsNotifier();
});
