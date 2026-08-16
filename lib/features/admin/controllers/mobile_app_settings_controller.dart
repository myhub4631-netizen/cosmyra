import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileAppSettings {
  final String mobileLogoUrl;
  final String mobileAppName;
  final String announcementBarText;
  final bool showAnnouncementBar;
  final String searchPlaceholder;
  final String bannerTitle;
  final String bannerSubtitle;
  final String bannerDiscountTag;
  final String bannerImageUrl;
  final String supportPhone;
  final String whatsappNumber;
  final bool showHotSellingSection;
  final bool showCategoryGrid;
  final List<Map<String, String>> customBanners;

  const MobileAppSettings({
    this.mobileLogoUrl = '',
    this.mobileAppName = 'Vaidyam Botanicals',
    this.announcementBarText = '🌿 Special Offer: Free Shipping on all orders above ₹999!',
    this.showAnnouncementBar = true,
    this.searchPlaceholder = 'Search in Ayurveda, Haircare, Skincare...',
    this.bannerTitle = 'Great Deals on Ayurveda & Skincare',
    this.bannerSubtitle = '100% Pure Certified Organic Formulations',
    this.bannerDiscountTag = 'Up to 60% OFF • Shop Now',
    this.bannerImageUrl = '',
    this.supportPhone = '+91 94730 40903',
    this.whatsappNumber = '+91 94730 40903',
    this.showHotSellingSection = true,
    this.showCategoryGrid = true,
    this.customBanners = const [
      {
        'title': 'Ayurvedic Hair Vitality Oil',
        'subtitle': 'Promotes Hair Growth & Reduces Fall',
        'discount': '30% OFF',
        'image': '',
      },
      {
        'title': 'Kumkumadi Radiance Face Serum',
        'subtitle': 'Saffron & 26 Herbs Glow Elixir',
        'discount': '25% OFF',
        'image': '',
      },
    ],
  });

  MobileAppSettings copyWith({
    String? mobileLogoUrl,
    String? mobileAppName,
    String? announcementBarText,
    bool? showAnnouncementBar,
    String? searchPlaceholder,
    String? bannerTitle,
    String? bannerSubtitle,
    String? bannerDiscountTag,
    String? bannerImageUrl,
    String? supportPhone,
    String? whatsappNumber,
    bool? showHotSellingSection,
    bool? showCategoryGrid,
    List<Map<String, String>>? customBanners,
  }) {
    return MobileAppSettings(
      mobileLogoUrl: mobileLogoUrl ?? this.mobileLogoUrl,
      mobileAppName: mobileAppName ?? this.mobileAppName,
      announcementBarText: announcementBarText ?? this.announcementBarText,
      showAnnouncementBar: showAnnouncementBar ?? this.showAnnouncementBar,
      searchPlaceholder: searchPlaceholder ?? this.searchPlaceholder,
      bannerTitle: bannerTitle ?? this.bannerTitle,
      bannerSubtitle: bannerSubtitle ?? this.bannerSubtitle,
      bannerDiscountTag: bannerDiscountTag ?? this.bannerDiscountTag,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      supportPhone: supportPhone ?? this.supportPhone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      showHotSellingSection: showHotSellingSection ?? this.showHotSellingSection,
      showCategoryGrid: showCategoryGrid ?? this.showCategoryGrid,
      customBanners: customBanners ?? this.customBanners,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobileLogoUrl': mobileLogoUrl,
      'mobileAppName': mobileAppName,
      'announcementBarText': announcementBarText,
      'showAnnouncementBar': showAnnouncementBar,
      'searchPlaceholder': searchPlaceholder,
      'bannerTitle': bannerTitle,
      'bannerSubtitle': bannerSubtitle,
      'bannerDiscountTag': bannerDiscountTag,
      'bannerImageUrl': bannerImageUrl,
      'supportPhone': supportPhone,
      'whatsappNumber': whatsappNumber,
      'showHotSellingSection': showHotSellingSection,
      'showCategoryGrid': showCategoryGrid,
      'customBanners': customBanners,
    };
  }

  factory MobileAppSettings.fromJson(Map<String, dynamic> json) {
    return MobileAppSettings(
      mobileLogoUrl: json['mobileLogoUrl']?.toString() ?? '',
      mobileAppName: json['mobileAppName']?.toString() ?? 'Vaidyam Botanicals',
      announcementBarText: json['announcementBarText']?.toString() ?? '🌿 Special Offer: Free Shipping on all orders above ₹999!',
      showAnnouncementBar: json['showAnnouncementBar'] as bool? ?? true,
      searchPlaceholder: json['searchPlaceholder']?.toString() ?? 'Search in Ayurveda, Haircare, Skincare...',
      bannerTitle: json['bannerTitle']?.toString() ?? 'Great Deals on Ayurveda & Skincare',
      bannerSubtitle: json['bannerSubtitle']?.toString() ?? '100% Pure Certified Organic Formulations',
      bannerDiscountTag: json['bannerDiscountTag']?.toString() ?? 'Up to 60% OFF • Shop Now',
      bannerImageUrl: json['bannerImageUrl']?.toString() ?? '',
      supportPhone: json['supportPhone']?.toString() ?? '+91 94730 40903',
      whatsappNumber: json['whatsappNumber']?.toString() ?? '+91 94730 40903',
      showHotSellingSection: json['showHotSellingSection'] as bool? ?? true,
      showCategoryGrid: json['showCategoryGrid'] as bool? ?? true,
      customBanners: (json['customBanners'] as List?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          const [],
    );
  }
}

class MobileAppSettingsNotifier extends StateNotifier<MobileAppSettings> {
  static const _prefsKey = 'cosmyra_mobile_app_settings_v1';

  MobileAppSettingsNotifier() : super(const MobileAppSettings()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_prefsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = json.decode(jsonStr) as Map<String, dynamic>;
        state = MobileAppSettings.fromJson(map);
      }
    } catch (_) {}
  }

  Future<void> updateSettings(MobileAppSettings newSettings) async {
    state = newSettings;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = json.encode(newSettings.toJson());
      await prefs.setString(_prefsKey, jsonStr);
    } catch (_) {}
  }
}

final mobileAppSettingsProvider = StateNotifierProvider<MobileAppSettingsNotifier, MobileAppSettings>((ref) {
  return MobileAppSettingsNotifier();
});
