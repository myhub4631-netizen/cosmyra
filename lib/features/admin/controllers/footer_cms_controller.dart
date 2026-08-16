import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FooterCmsState {
  final List<Map<String, dynamic>> sections;
  final String brandName;
  final String brandDescription;
  final String newsletterTitle;
  final String newsletterSubtitle;
  final String copyrightText;
  final String metaTitle;
  final String schemaOrg;
  final String customCss;
  final String customJs;

  FooterCmsState({
    required this.sections,
    this.brandName = 'Cosmyra',
    this.brandDescription = 'Your premier destination for certified organic Ayurveda formulation. Pure wellness delivered to your doorstep.',
    this.newsletterTitle = 'Subscribe to our newsletter',
    this.newsletterSubtitle = 'Get updates on offers, new formulations and botanical rituals.',
    this.copyrightText = '© 2026 Cosmyra. All Rights Reserved.',
    this.metaTitle = 'Cosmyra • Authentic Herbal & Ayurvedic Formulations',
    this.schemaOrg = '{\n  "@context": "https://schema.org",\n  "@type": "Organization",\n  "name": "Cosmyra",\n  "url": "https://cosmyra.cloud"\n}',
    this.customCss = '/* Footer Specific Styles */\n.footer-bg { background-color: #0B132B; }\n.footer-link:hover { color: #818CF8; }',
    this.customJs = '// Footer Scripts & Tracking\nconsole.log("Cosmyra Footer Initialized");',
  });

  FooterCmsState copyWith({
    List<Map<String, dynamic>>? sections,
    String? brandName,
    String? brandDescription,
    String? newsletterTitle,
    String? newsletterSubtitle,
    String? copyrightText,
    String? metaTitle,
    String? schemaOrg,
    String? customCss,
    String? customJs,
  }) {
    return FooterCmsState(
      sections: sections ?? this.sections,
      brandName: brandName ?? this.brandName,
      brandDescription: brandDescription ?? this.brandDescription,
      newsletterTitle: newsletterTitle ?? this.newsletterTitle,
      newsletterSubtitle: newsletterSubtitle ?? this.newsletterSubtitle,
      copyrightText: copyrightText ?? this.copyrightText,
      metaTitle: metaTitle ?? this.metaTitle,
      schemaOrg: schemaOrg ?? this.schemaOrg,
      customCss: customCss ?? this.customCss,
      customJs: customJs ?? this.customJs,
    );
  }
}

class FooterCmsNotifier extends StateNotifier<FooterCmsState> {
  static const _prefsKey = 'cosmyra_footer_cms_sections_v2';
  static const _metaPrefsKey = 'cosmyra_footer_brand_meta_v2';

  FooterCmsNotifier() : super(FooterCmsState(sections: _defaultSections)) {
    _loadFromPrefs();
  }

  static final List<Map<String, dynamic>> _defaultSections = [
    {
      'id': 'fsec-1',
      'number': 1,
      'title': 'Store Info & Newsletter',
      'isActive': true,
      'description': 'Store logo, description, newsletter subscription & social links.',
      'meta': '1 Content Block • 5 Social Links',
      'type': 'newsletter_info',
      'items': [
        {'text': 'Facebook', 'url': 'https://facebook.com'},
        {'text': 'Instagram', 'url': 'https://instagram.com'},
        {'text': 'Twitter/X', 'url': 'https://x.com'},
        {'text': 'YouTube', 'url': 'https://youtube.com'},
        {'text': 'Pinterest', 'url': 'https://pinterest.com'},
      ],
    },
    {
      'id': 'fsec-2',
      'number': 2,
      'title': 'Shop Links',
      'isActive': true,
      'description': 'Important shop pages and collections.',
      'meta': '8 Links',
      'type': 'links',
      'items': [
        {'text': 'All Categories', 'url': '/category/all'},
        {'text': "Today's Deals", 'url': '/deals'},
        {'text': 'New Arrivals', 'url': '/new-arrivals'},
        {'text': 'Best Sellers', 'url': '/best-sellers'},
        {'text': 'Featured Formulations', 'url': '/featured'},
        {'text': 'Clearance Sale', 'url': '/clearance'},
      ],
    },
    {
      'id': 'fsec-3',
      'number': 3,
      'title': 'Customer Service',
      'isActive': true,
      'description': 'Help center, policies and support links.',
      'meta': '6 Links',
      'type': 'links',
      'items': [
        {'text': 'Track Your Order', 'url': '/track-order'},
        {'text': 'Returns & Refunds', 'url': '/returns'},
        {'text': 'Shipping Information', 'url': '/shipping'},
        {'text': 'Payment Methods', 'url': '/payment-methods'},
        {'text': 'FAQ', 'url': '/faq'},
        {'text': 'Contact Us', 'url': '/contact'},
      ],
    },
    {
      'id': 'fsec-4',
      'number': 4,
      'title': 'My Account',
      'isActive': true,
      'description': 'User account related pages.',
      'meta': '5 Links',
      'type': 'links',
      'items': [
        {'text': 'My Orders', 'url': '/orders'},
        {'text': 'Wishlist', 'url': '/wishlist'},
        {'text': 'Addresses', 'url': '/addresses'},
        {'text': 'Account Settings', 'url': '/settings'},
        {'text': 'Notifications', 'url': '/notifications'},
        {'text': 'Logout', 'url': '/logout'},
      ],
    },
    {
      'id': 'fsec-5',
      'number': 5,
      'title': 'About Us',
      'isActive': true,
      'description': 'Company information and useful links.',
      'meta': '6 Links • 1 Content Block',
      'type': 'links',
      'items': [
        {'text': 'About Vaidyam', 'url': '/about'},
        {'text': 'Our Story', 'url': '/our-story'},
        {'text': 'Careers', 'url': '/careers'},
        {'text': 'Botanical Blog', 'url': '/blog'},
        {'text': 'Privacy Policy', 'url': '/privacy'},
        {'text': 'Terms & Conditions', 'url': '/terms'},
      ],
    },
    {
      'id': 'fsec-6',
      'number': 6,
      'title': 'Popular Categories',
      'isActive': true,
      'description': 'Top product categories with icons.',
      'meta': '6 Categories',
      'type': 'categories',
      'items': [
        {'text': 'Haircare & Oils', 'url': '/category/haircare'},
        {'text': 'Skincare & Serums', 'url': '/category/skincare'},
        {'text': 'Organic Soaps', 'url': '/category/soaps'},
        {'text': 'Wellness Oils', 'url': '/category/wellness'},
        {'text': 'Body Thailams', 'url': '/category/body-care'},
      ],
    },
    {
      'id': 'fsec-7',
      'number': 7,
      'title': 'Bottom Bar',
      'isActive': true,
      'description': 'Bottom bar with extra info and payment methods.',
      'meta': '2 Content Blocks • 6 Payment Methods',
      'type': 'bottom_bar',
      'items': [
        {'text': 'VISA', 'url': ''},
        {'text': 'Mastercard', 'url': ''},
        {'text': 'UPI', 'url': ''},
        {'text': 'Paytm', 'url': ''},
        {'text': 'PhonePe', 'url': ''},
      ],
    },
  ];

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_prefsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = json.decode(jsonStr);
        final List<Map<String, dynamic>> loadedSections = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        state = state.copyWith(sections: loadedSections);
      }

      final String? metaJsonStr = prefs.getString(_metaPrefsKey);
      if (metaJsonStr != null && metaJsonStr.isNotEmpty) {
        final Map<String, dynamic> meta = json.decode(metaJsonStr);
        state = state.copyWith(
          brandName: meta['brandName']?.toString() ?? state.brandName,
          brandDescription: meta['brandDescription']?.toString() ?? state.brandDescription,
          newsletterTitle: meta['newsletterTitle']?.toString() ?? state.newsletterTitle,
          newsletterSubtitle: meta['newsletterSubtitle']?.toString() ?? state.newsletterSubtitle,
          copyrightText: meta['copyrightText']?.toString() ?? state.copyrightText,
        );
      }
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = json.encode(state.sections);
      await prefs.setString(_prefsKey, jsonStr);

      final String metaJsonStr = json.encode({
        'brandName': state.brandName,
        'brandDescription': state.brandDescription,
        'newsletterTitle': state.newsletterTitle,
        'newsletterSubtitle': state.newsletterSubtitle,
        'copyrightText': state.copyrightText,
      });
      await prefs.setString(_metaPrefsKey, metaJsonStr);
    } catch (_) {}
  }

  void updateBrandInfo({
    String? brandName,
    String? brandDescription,
    String? newsletterTitle,
    String? newsletterSubtitle,
    String? copyrightText,
  }) {
    state = state.copyWith(
      brandName: brandName ?? state.brandName,
      brandDescription: brandDescription ?? state.brandDescription,
      newsletterTitle: newsletterTitle ?? state.newsletterTitle,
      newsletterSubtitle: newsletterSubtitle ?? state.newsletterSubtitle,
      copyrightText: copyrightText ?? state.copyrightText,
    );
    _saveToPrefs();
  }

  void updateSections(List<Map<String, dynamic>> newSections) {
    _reindex(newSections);
    state = state.copyWith(sections: List.from(newSections));
    _saveToPrefs();
  }

  void toggleSection(int sectionIndex, bool isActive) {
    final updated = List<Map<String, dynamic>>.from(state.sections.map((s) => Map<String, dynamic>.from(s)));
    if (sectionIndex >= 0 && sectionIndex < updated.length) {
      updated[sectionIndex]['isActive'] = isActive;
      state = state.copyWith(sections: updated);
      _saveToPrefs();
    }
  }

  void addLinkToSection(int sectionIndex, String text, String url) {
    final updated = List<Map<String, dynamic>>.from(state.sections.map((s) => Map<String, dynamic>.from(s)));
    if (sectionIndex >= 0 && sectionIndex < updated.length) {
      final items = List<Map<String, dynamic>>.from((updated[sectionIndex]['items'] as List? ?? []).map((e) {
        if (e is Map) return Map<String, dynamic>.from(e);
        return {'text': e.toString(), 'url': ''};
      }));
      items.add({'text': text, 'url': url});
      updated[sectionIndex]['items'] = items;
      updated[sectionIndex]['meta'] = '${items.length} Links';
      state = state.copyWith(sections: updated);
      _saveToPrefs();
    }
  }

  void editLinkInSection(int sectionIndex, int linkIndex, String text, String url) {
    final updated = List<Map<String, dynamic>>.from(state.sections.map((s) => Map<String, dynamic>.from(s)));
    if (sectionIndex >= 0 && sectionIndex < updated.length) {
      final items = List<Map<String, dynamic>>.from((updated[sectionIndex]['items'] as List? ?? []).map((e) {
        if (e is Map) return Map<String, dynamic>.from(e);
        return {'text': e.toString(), 'url': ''};
      }));
      if (linkIndex >= 0 && linkIndex < items.length) {
        items[linkIndex] = {'text': text, 'url': url};
        updated[sectionIndex]['items'] = items;
        state = state.copyWith(sections: updated);
        _saveToPrefs();
      }
    }
  }

  void deleteLinkFromSection(int sectionIndex, int linkIndex) {
    final updated = List<Map<String, dynamic>>.from(state.sections.map((s) => Map<String, dynamic>.from(s)));
    if (sectionIndex >= 0 && sectionIndex < updated.length) {
      final items = List<Map<String, dynamic>>.from((updated[sectionIndex]['items'] as List? ?? []).map((e) {
        if (e is Map) return Map<String, dynamic>.from(e);
        return {'text': e.toString(), 'url': ''};
      }));
      if (linkIndex >= 0 && linkIndex < items.length) {
        items.removeAt(linkIndex);
        updated[sectionIndex]['items'] = items;
        updated[sectionIndex]['meta'] = '${items.length} Links';
        state = state.copyWith(sections: updated);
        _saveToPrefs();
      }
    }
  }

  void moveLinkInSection(int sectionIndex, int linkIndex, int direction) {
    final updated = List<Map<String, dynamic>>.from(state.sections.map((s) => Map<String, dynamic>.from(s)));
    if (sectionIndex >= 0 && sectionIndex < updated.length) {
      final items = List<Map<String, dynamic>>.from((updated[sectionIndex]['items'] as List? ?? []).map((e) {
        if (e is Map) return Map<String, dynamic>.from(e);
        return {'text': e.toString(), 'url': ''};
      }));
      final newIndex = linkIndex + direction;
      if (newIndex >= 0 && newIndex < items.length) {
        final item = items.removeAt(linkIndex);
        items.insert(newIndex, item);
        updated[sectionIndex]['items'] = items;
        state = state.copyWith(sections: updated);
        _saveToPrefs();
      }
    }
  }

  void moveSection(int currentIndex, int direction) {
    final updated = List<Map<String, dynamic>>.from(state.sections.map((s) => Map<String, dynamic>.from(s)));
    final newIndex = currentIndex + direction;
    if (newIndex >= 0 && newIndex < updated.length) {
      final item = updated.removeAt(currentIndex);
      updated.insert(newIndex, item);
      _reindex(updated);
      state = state.copyWith(sections: updated);
      _saveToPrefs();
    }
  }

  void addSection(Map<String, dynamic> sectionData) {
    final updated = List<Map<String, dynamic>>.from(state.sections.map((s) => Map<String, dynamic>.from(s)));
    updated.add(sectionData);
    _reindex(updated);
    state = state.copyWith(sections: updated);
    _saveToPrefs();
  }

  void deleteSection(int sectionIndex) {
    final updated = List<Map<String, dynamic>>.from(state.sections.map((s) => Map<String, dynamic>.from(s)));
    if (sectionIndex >= 0 && sectionIndex < updated.length) {
      updated.removeAt(sectionIndex);
      _reindex(updated);
      state = state.copyWith(sections: updated);
      _saveToPrefs();
    }
  }

  void resetToDefault() {
    state = FooterCmsState(sections: _defaultSections);
    _saveToPrefs();
  }

  void _reindex(List<Map<String, dynamic>> list) {
    for (int i = 0; i < list.length; i++) {
      list[i]['number'] = i + 1;
    }
  }
}

final footerCmsProvider = StateNotifierProvider<FooterCmsNotifier, FooterCmsState>((ref) {
  return FooterCmsNotifier();
});
