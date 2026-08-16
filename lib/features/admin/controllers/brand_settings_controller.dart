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

  const BrandSettings({
    this.headerLogoUrl = '',
    this.footerLogoUrl = '',
    this.faviconUrl = '',
    this.appIconUrl = '',
    this.brandName = 'Vaidyam Botanicals',
    this.brandTagline = 'Pure Ayurveda. Real Results.',
  });

  BrandSettings copyWith({
    String? headerLogoUrl,
    String? footerLogoUrl,
    String? faviconUrl,
    String? appIconUrl,
    String? brandName,
    String? brandTagline,
  }) {
    return BrandSettings(
      headerLogoUrl: headerLogoUrl ?? this.headerLogoUrl,
      footerLogoUrl: footerLogoUrl ?? this.footerLogoUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      appIconUrl: appIconUrl ?? this.appIconUrl,
      brandName: brandName ?? this.brandName,
      brandTagline: brandTagline ?? this.brandTagline,
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
  }) async {
    state = state.copyWith(
      headerLogoUrl: headerLogoUrl,
      footerLogoUrl: footerLogoUrl,
      faviconUrl: faviconUrl,
      appIconUrl: appIconUrl,
      brandName: brandName,
      brandTagline: brandTagline,
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
    if (!kIsWeb || url.isEmpty) return;
    try {
      final html.Element? existingLink = html.document.querySelector("link[rel*='icon']");
      if (existingLink != null) {
        existingLink.setAttribute('href', url);
      } else {
        final newLink = html.LinkElement()
          ..type = 'image/x-icon'
          ..rel = 'shortcut icon'
          ..href = url;
        html.document.getElementsByTagName('head').first.append(newLink);
      }
    } catch (_) {}
  }
}

final brandSettingsProvider = StateNotifierProvider<BrandSettingsNotifier, BrandSettings>((ref) {
  return BrandSettingsNotifier();
});
