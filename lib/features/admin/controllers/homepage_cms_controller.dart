import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomepageCmsState {
  final List<Map<String, dynamic>> sections;
  final String metaTitle;
  final String metaDescription;
  final String customCss;
  final String customJs;

  HomepageCmsState({
    required this.sections,
    this.metaTitle = 'Cosmyra • Pure Herbal Skincare & Wellness',
    this.metaDescription = 'Discover 100% authentic Ayurvedic formulations, herbal hair oils, serums, and natural soaps.',
    this.customCss = '',
    this.customJs = '',
  });

  HomepageCmsState copyWith({
    List<Map<String, dynamic>>? sections,
    String? metaTitle,
    String? metaDescription,
    String? customCss,
    String? customJs,
  }) {
    return HomepageCmsState(
      sections: sections ?? this.sections,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      customCss: customCss ?? this.customCss,
      customJs: customJs ?? this.customJs,
    );
  }
}

class HomepageCmsNotifier extends StateNotifier<HomepageCmsState> {
  static const _prefsKey = 'cosmyra_homepage_cms_sections_v2';

  HomepageCmsNotifier() : super(HomepageCmsState(sections: _defaultSections)) {
    _loadFromPrefs();
  }

  static final List<Map<String, dynamic>> _defaultSections = [
    {
      'id': 'sec-1',
      'number': 1,
      'title': 'Hero Banner / Slider',
      'isActive': true,
      'description': 'Main banner slider that appears at the top of the homepage.',
      'meta': '5 Slides • Auto Play: 5s • Show Arrows: Yes • Show Dots: Yes',
      'type': 'slider',
      'items': [
        {'title': 'Monsoon Herbal Sale', 'sub': 'Flat 20% OFF', 'colorValue': 0xFFFEF3C7},
        {'title': 'Pure Neem Facewash', 'sub': 'New Launch', 'colorValue': 0xFFD1FAE5},
        {'title': 'Kumkumadi Tailam', 'sub': 'Best Seller', 'colorValue': 0xFFEEF2FF},
        {'title': 'Ayurvedic Hair Care', 'sub': '100% Natural', 'colorValue': 0xFFE0E7FF},
        {'title': 'Botanical Soaps Pack', 'sub': 'Organic', 'colorValue': 0xFFF3E8FF},
      ],
      'addLabel': '+ Add Slide',
    },
    {
      'id': 'sec-2',
      'number': 2,
      'title': 'Shop by Categories',
      'isActive': true,
      'description': 'Category grid section with icons and category links.',
      'meta': '9 Categories • Columns: 9 • Style: Circle • Show Title: Yes',
      'type': 'categories',
      'items': [
        {'name': 'Haircare', 'title': 'Haircare & Oils', 'emoji': '💇', 'asset': 'assets/images/shampoo.jpg'},
        {'name': 'Face Serum', 'title': 'Face Serum', 'emoji': '🧪', 'asset': 'assets/images/facewash.jpg'},
        {'name': 'Skincare', 'title': 'Skincare & Serums', 'emoji': '✨', 'asset': 'assets/images/facewash.jpg'},
        {'name': 'Soaps', 'title': 'Organic Soaps', 'emoji': '🧴', 'asset': 'assets/images/soap.jpg'},
        {'name': 'Wellness Oils', 'title': 'Wellness Oils', 'emoji': '🌿', 'asset': 'assets/images/soap.jpg'},
        {'name': 'Elixirs', 'title': 'Radiance Elixirs', 'emoji': '🌸', 'asset': 'assets/images/shampoo.jpg'},
        {'name': 'Gift Combos', 'title': 'Gift Combos', 'emoji': '🎁', 'asset': 'assets/images/soap.jpg'},
        {'name': 'Aloe Vera', 'title': 'Aloe & Hydration', 'emoji': '💧', 'asset': 'assets/images/facewash.jpg'},
        {'name': 'Body Care', 'title': 'Body Thailams', 'emoji': '🍃', 'asset': 'assets/images/soap.jpg'},
      ],
      'addLabel': '+ Add Category',
    },
    {
      'id': 'sec-3',
      'number': 3,
      'title': "Today's Best Deals",
      'isActive': true,
      'description': 'Showcase best selling products with offers.',
      'meta': '6 Products • Show Discount: Yes • Show Rating: Yes',
      'type': 'deals',
      'items': [
        {'name': 'Anti-Dandruff Shampoo', 'tag': '29% OFF', 'price': '₹399'},
        {'name': 'De-Tan Botanical Soap', 'tag': '23% OFF', 'price': '₹199'},
        {'name': 'Deep Clean Face Wash', 'tag': '28% OFF', 'price': '₹299'},
        {'name': 'Herbal Hair Oil', 'tag': '25% OFF', 'price': '₹349'},
        {'name': 'Vitamin C Serum', 'tag': '20% OFF', 'price': '₹599'},
        {'name': 'Kumkumadi Night Cream', 'tag': '25% OFF', 'price': '₹699'},
      ],
      'addLabel': '+ Add Product',
    },
    {
      'id': 'sec-4',
      'number': 4,
      'title': 'Trending & Popular Formulations',
      'isActive': true,
      'description': 'Highlight trending and popular formulations.',
      'meta': '4 Products • Layout: Horizontal • Show Filter: Yes',
      'type': 'trending',
      'items': [
        {'name': 'Bhringraj Elixir', 'tag': 'Trending'},
        {'name': 'Nalpamaradi Oil', 'tag': 'Popular'},
        {'name': 'Ubtan Scrub', 'tag': 'New'},
        {'name': 'Rose Water Toner', 'tag': 'Hot'},
      ],
      'addLabel': '+ Add Item',
    },
    {
      'id': 'sec-5',
      'number': 5,
      'title': 'Benefits / Trust Badges',
      'isActive': true,
      'description': 'Key features and trust indicators.',
      'meta': '4 Items • Style: Icon + Text • Background: Light',
      'type': 'benefits',
      'items': [
        {'title': 'Free Shipping', 'sub': 'On orders over ₹999'},
        {'title': 'Easy Returns', 'sub': 'Within 7 days'},
        {'title': 'Best Quality', 'sub': '100% Original'},
        {'title': 'Secure Payments', 'sub': 'Multiple options'},
      ],
      'addLabel': '+ Add Item',
    },
    {
      'id': 'sec-6',
      'number': 6,
      'title': 'Top Brands',
      'isActive': true,
      'description': 'Display top brands customers love.',
      'meta': '6 Brands • Style: Logo Grid • Show Title: Yes',
      'type': 'brands',
      'items': [
        {'name': 'VAIDYAM', 'tag': 'Organic Botanicals'},
        {'name': 'KOTTAKKAL', 'tag': 'Traditional Ayurveda'},
        {'name': 'FOREST ESSENTIALS', 'tag': 'Luxurious Beauty'},
        {'name': 'KAMA AYURVEDA', 'tag': 'Pure Formulations'},
        {'name': 'BIOTIQUE', 'tag': 'Botanical Skincare'},
        {'name': 'COSMYRA', 'tag': 'Ayurvedic Formulations'},
      ],
      'addLabel': '+ Add Brand',
    },
    {
      'id': 'sec-7',
      'number': 7,
      'title': 'Newsletter Section',
      'isActive': true,
      'description': 'Newsletter subscription section.',
      'meta': 'Style: Center • Background: Dark',
      'type': 'newsletter',
      'items': [],
      'addLabel': '',
    },
  ];

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = jsonDecode(jsonStr);
        final List<Map<String, dynamic>> loadedSections = List<Map<String, dynamic>>.from(
          decoded.map((x) => Map<String, dynamic>.from(x as Map)),
        );
        state = state.copyWith(sections: loadedSections);
      }
    } catch (_) {}
  }

  Future<void> _saveToPrefs(List<Map<String, dynamic>> updatedSections) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cleanSections = updatedSections.map((sec) {
        final cleanSec = Map<String, dynamic>.from(sec);
        if (sec['items'] is List) {
          cleanSec['items'] = (sec['items'] as List).map((item) {
            if (item is Map) {
              final cleanItem = Map<String, dynamic>.from(item);
              cleanItem.removeWhere((key, value) => value is IconData || value is Color);
              return cleanItem;
            }
            return item;
          }).toList();
        }
        return cleanSec;
      }).toList();

      final jsonStr = jsonEncode(cleanSections);
      await prefs.setString(_prefsKey, jsonStr);
    } catch (_) {}
  }

  void updateSections(List<Map<String, dynamic>> updatedSections) {
    state = state.copyWith(sections: List.from(updatedSections.map((s) => Map<String, dynamic>.from(s))));
    _saveToPrefs(updatedSections);
  }
}

final homepageCmsProvider = StateNotifierProvider<HomepageCmsNotifier, HomepageCmsState>((ref) {
  return HomepageCmsNotifier();
});
