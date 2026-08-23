import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/supabase_config.dart';

class CouponModel {
  final String id;
  final String code;
  final String title;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double minSpend;
  final bool isVisibleAtCheckout; // Admin toggle: show on checkout page or not
  final bool isActive;

  const CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    this.minSpend = 0.0,
    this.isVisibleAtCheckout = true,
    this.isActive = true,
  });

  double calculateDiscount(double subtotal) {
    if (!isActive || subtotal < minSpend) return 0.0;
    if (discountType == 'percentage') {
      return (subtotal * (discountValue / 100.0)).roundToDouble();
    }
    return discountValue > subtotal ? subtotal : discountValue;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'discountType': discountType,
        'discountValue': discountValue,
        'minSpend': minSpend,
        'isVisibleAtCheckout': isVisibleAtCheckout,
        'isActive': isActive,
      };

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
        id: json['id']?.toString() ?? 'c-${DateTime.now().millisecondsSinceEpoch}',
        code: json['code']?.toString().toUpperCase() ?? 'OFFER',
        title: json['title']?.toString() ?? 'Discount Offer',
        discountType: json['discountType']?.toString() ?? 'percentage',
        discountValue: (json['discountValue'] as num?)?.toDouble() ?? 10.0,
        minSpend: (json['minSpend'] as num?)?.toDouble() ?? 0.0,
        isVisibleAtCheckout: json['isVisibleAtCheckout'] as bool? ?? true,
        isActive: json['isActive'] as bool? ?? true,
      );

  CouponModel copyWith({
    String? id,
    String? code,
    String? title,
    String? discountType,
    double? discountValue,
    double? minSpend,
    bool? isVisibleAtCheckout,
    bool? isActive,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minSpend: minSpend ?? this.minSpend,
      isVisibleAtCheckout: isVisibleAtCheckout ?? this.isVisibleAtCheckout,
      isActive: isActive ?? this.isActive,
    );
  }
}

class CouponNotifier extends StateNotifier<List<CouponModel>> {
  static const _prefsKey = 'cosmyra_admin_coupons_v2';
  static const _storagePath = 'settings/coupons.json';

  static final List<CouponModel> _defaultCoupons = [
    const CouponModel(
      id: 'c-mega50',
      code: 'MEGA50',
      title: 'Rs 50 Discount',
      discountType: 'percentage',
      discountValue: 50.0,
      minSpend: 150.0,
      isVisibleAtCheckout: true,
      isActive: true,
    ),
    const CouponModel(
      id: 'c-v20',
      code: 'VAIDYAM20',
      title: 'Get 20% OFF on all Ayurvedic Botanicals',
      discountType: 'percentage',
      discountValue: 20.0,
      minSpend: 299.0,
      isVisibleAtCheckout: false,
      isActive: false, // Disabled by Admin
    ),
    const CouponModel(
      id: 'c-org100',
      code: 'ORGANIC100',
      title: 'Flat ₹100 OFF on orders above ₹499',
      discountType: 'fixed',
      discountValue: 100.0,
      minSpend: 499.0,
      isVisibleAtCheckout: true,
      isActive: true,
    ),
    const CouponModel(
      id: 'c-herb50',
      code: 'HERBAL50',
      title: 'Flat ₹50 OFF on first purchase',
      discountType: 'fixed',
      discountValue: 50.0,
      minSpend: 199.0,
      isVisibleAtCheckout: true,
      isActive: true,
    ),
    const CouponModel(
      id: 'c-sec25',
      code: 'SECRET25',
      title: 'Exclusive 25% OFF VIP Coupon',
      discountType: 'percentage',
      discountValue: 25.0,
      minSpend: 599.0,
      isVisibleAtCheckout: true,
      isActive: true,
    ),
  ];

  CouponNotifier() : super(_defaultCoupons) {
    _loadFromPrefsAndRemote();
  }

  Future<void> _loadFromPrefsAndRemote() async {
    // 1. Fast local cache load
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = jsonDecode(jsonStr);
        final loaded = decoded.map((x) => CouponModel.fromJson(Map<String, dynamic>.from(x))).toList();
        state = loaded;
      }
    } catch (_) {}

    // 2. Live Remote Supabase Storage sync with Cache-Busting (prevents browser/CDN cache from returning stale JSON on page refresh)
    try {
      if (SupabaseConfig.isConfigured) {
        final rawUrl = supabase.storage.from('product-images').getPublicUrl(_storagePath);
        final freshUrl = '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}';

        final response = await http.get(
          Uri.parse(freshUrl),
          headers: {'Cache-Control': 'no-cache, no-store, must-revalidate', 'Pragma': 'no-cache'},
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final List decoded = jsonDecode(response.body);
          final loaded = decoded.map((x) => CouponModel.fromJson(Map<String, dynamic>.from(x))).toList();
          if (loaded.isNotEmpty) {
            state = loaded;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_prefsKey, response.body);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _saveToPrefsAndRemote(List<CouponModel> coupons) async {
    final jsonStr = jsonEncode(coupons.map((c) => c.toJson()).toList());

    // 1. Save to local browser cache immediately
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonStr);
    } catch (_) {}

    // 2. Remote push to Supabase Storage so ALL mobile & desktop devices get the update live!
    try {
      if (SupabaseConfig.isConfigured) {
        final bytes = utf8.encode(jsonStr);
        await supabase.storage.from('product-images').uploadBinary(
              _storagePath,
              bytes,
              fileOptions: const FileOptions(contentType: 'application/json', upsert: true),
            );
      }
    } catch (_) {}
  }

  void addCoupon(CouponModel coupon) {
    final filtered = state.where((c) => c.code.trim().toUpperCase() != coupon.code.trim().toUpperCase() && c.id != coupon.id).toList();
    final updated = [coupon, ...filtered];
    state = updated;
    _saveToPrefsAndRemote(updated);
  }

  void updateCoupon(CouponModel updatedCoupon) {
    final updated = state.map((c) {
      if (c.id == updatedCoupon.id || c.code.trim().toUpperCase() == updatedCoupon.code.trim().toUpperCase()) {
        return updatedCoupon;
      }
      return c;
    }).toList();
    state = updated;
    _saveToPrefsAndRemote(updated);
  }

  void toggleVisibilityAtCheckout(String couponId, bool isVisible) {
    final updated = state.map((c) {
      if (c.id == couponId) {
        return c.copyWith(isVisibleAtCheckout: isVisible);
      }
      return c;
    }).toList();
    state = updated;
    _saveToPrefsAndRemote(updated);
  }

  void toggleActive(String couponId, bool isActive) {
    final updated = state.map((c) {
      if (c.id == couponId) {
        return c.copyWith(isActive: isActive);
      }
      return c;
    }).toList();
    state = updated;
    _saveToPrefsAndRemote(updated);
  }

  void deleteCoupon(String couponId) {
    final updated = state.where((c) => c.id != couponId).toList();
    state = updated;
    _saveToPrefsAndRemote(updated);
  }

  CouponModel? findByCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    for (final c in state) {
      if (c.isActive && c.code.toUpperCase() == cleanCode) {
        return c;
      }
    }
    return null;
  }
}

final couponProvider = StateNotifierProvider<CouponNotifier, List<CouponModel>>((ref) {
  return CouponNotifier();
});
