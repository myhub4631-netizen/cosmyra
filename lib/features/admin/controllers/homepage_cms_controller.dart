import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomepageCmsState {
  final List<Map<String, dynamic>> sections;
  final String metaTitle;
  final String metaDescription;
  final String customCss;
  final String customJs;

  HomepageCmsState({
    required this.sections,
    this.metaTitle = 'Vaidyam Botanicals • Pure Herbal Skincare & Wellness',
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
  HomepageCmsNotifier() : super(HomepageCmsState(sections: _defaultSections));

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
        {'title': 'Monsoon Herbal Sale', 'sub': 'Flat 20% OFF', 'color': const Color(0xFFFEF3C7)},
        {'title': 'Pure Neem Facewash', 'sub': 'New Launch', 'color': const Color(0xFFD1FAE5)},
        {'title': 'Kumkumadi Tailam', 'sub': 'Best Seller', 'color': const Color(0xFFEEF2FF)},
        {'title': 'Ayurvedic Hair Care', 'sub': '100% Natural', 'color': const Color(0xFFE0E7FF)},
        {'title': 'Botanical Soaps Pack', 'sub': 'Organic', 'color': const Color(0xFFF3E8FF)},
      ],
      'addLabel': '+ Add Slide',
    },
    {
      'id': 'sec-2',
      'number': 2,
      'title': 'Shop by Categories',
      'isActive': true,
      'description': 'Category grid section with icons and category links.',
      'meta': '8 Categories • Columns: 8 • Style: Circle • Show Title: Yes',
      'type': 'categories',
      'items': [
        {'name': 'Haircare', 'title': 'Haircare & Oils', 'icon': Icons.spa, 'emoji': '💇', 'asset': 'assets/images/shampoo.jpg'},
        {'name': 'Skincare', 'title': 'Skincare & Serums', 'icon': Icons.face, 'emoji': '✨', 'asset': 'assets/images/facewash.jpg'},
        {'name': 'Soaps', 'title': 'Organic Soaps', 'icon': Icons.clean_hands, 'emoji': '🧴', 'asset': 'assets/images/soap.jpg'},
        {'name': 'Wellness Oils', 'title': 'Wellness Oils', 'icon': Icons.opacity, 'emoji': '🌿', 'asset': 'assets/images/soap.jpg'},
        {'name': 'Elixirs', 'title': 'Radiance Elixirs', 'icon': Icons.local_pharmacy, 'emoji': '🌸', 'asset': 'assets/images/shampoo.jpg'},
        {'name': 'Gift Combos', 'title': 'Gift Combos', 'icon': Icons.card_giftcard, 'emoji': '🎁', 'asset': 'assets/images/soap.jpg'},
        {'name': 'Aloe Vera', 'title': 'Aloe & Hydration', 'icon': Icons.eco, 'emoji': '💧', 'asset': 'assets/images/facewash.jpg'},
        {'name': 'Body Care', 'title': 'Body Thailams', 'icon': Icons.self_improvement, 'emoji': '🍃', 'asset': 'assets/images/soap.jpg'},
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
        {'title': 'Free Shipping', 'sub': 'On orders over ₹999', 'icon': Icons.local_shipping_outlined},
        {'title': 'Easy Returns', 'sub': 'Within 7 days', 'icon': Icons.replay_outlined},
        {'title': 'Best Quality', 'sub': '100% Original', 'icon': Icons.verified_outlined},
        {'title': 'Secure Payments', 'sub': 'Multiple options', 'icon': Icons.lock_outline},
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

  void updateSections(List<Map<String, dynamic>> updatedSections) {
    state = state.copyWith(sections: List.from(updatedSections));
  }

  void removeCategoryItem(int itemIndex) {
    final newSections = state.sections.map((sec) {
      if (sec['type'] == 'categories') {
        final newSec = Map<String, dynamic>.from(sec);
        final newItems = List<Map<String, dynamic>>.from(sec['items']);
        if (itemIndex >= 0 && itemIndex < newItems.length) {
          newItems.removeAt(itemIndex);
        }
        newSec['items'] = newItems;
        newSec['meta'] = '${newItems.length} Categories • Columns: ${newItems.length} • Style: Circle • Show Title: Yes';
        return newSec;
      }
      return sec;
    }).toList();

    state = state.copyWith(sections: newSections);
  }

  void updateSeo({required String title, required String description}) {
    state = state.copyWith(metaTitle: title, metaDescription: description);
  }

  void updateCustomCssJs({required String css, required String js}) {
    state = state.copyWith(customCss: css, customJs: js);
  }
}

final homepageCmsProvider = StateNotifierProvider<HomepageCmsNotifier, HomepageCmsState>((ref) {
  return HomepageCmsNotifier();
});
