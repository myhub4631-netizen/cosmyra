import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/supabase_config.dart';

class ShippingSettings {
  final double standardShippingFee;
  final double freeShippingThreshold;
  final bool isSuperfastEnabled;
  final double superfastDeliveryFee;

  const ShippingSettings({
    this.standardShippingFee = 0.0, // Default 0 (Free)
    this.freeShippingThreshold = 399.0, // Free shipping on orders >= ₹399
    this.isSuperfastEnabled = true,
    this.superfastDeliveryFee = 60.0, // Superfast delivery charge: Rs 60
  });

  Map<String, dynamic> toJson() => {
        'standardShippingFee': standardShippingFee,
        'freeShippingThreshold': freeShippingThreshold,
        'isSuperfastEnabled': isSuperfastEnabled,
        'superfastDeliveryFee': superfastDeliveryFee,
      };

  factory ShippingSettings.fromJson(Map<String, dynamic> json) => ShippingSettings(
        standardShippingFee: (json['standardShippingFee'] as num?)?.toDouble() ?? 0.0,
        freeShippingThreshold: (json['freeShippingThreshold'] as num?)?.toDouble() ?? 399.0,
        isSuperfastEnabled: json['isSuperfastEnabled'] as bool? ?? true,
        superfastDeliveryFee: (json['superfastDeliveryFee'] as num?)?.toDouble() ?? 60.0,
      );

  ShippingSettings copyWith({
    double? standardShippingFee,
    double? freeShippingThreshold,
    bool? isSuperfastEnabled,
    double? superfastDeliveryFee,
  }) {
    return ShippingSettings(
      standardShippingFee: standardShippingFee ?? this.standardShippingFee,
      freeShippingThreshold: freeShippingThreshold ?? this.freeShippingThreshold,
      isSuperfastEnabled: isSuperfastEnabled ?? this.isSuperfastEnabled,
      superfastDeliveryFee: superfastDeliveryFee ?? this.superfastDeliveryFee,
    );
  }
}

class ShippingSettingsNotifier extends StateNotifier<ShippingSettings> {
  static const _prefsKey = 'cosmyra_shipping_settings_v1';
  static const _storagePath = 'settings/shipping_settings.json';

  ShippingSettingsNotifier() : super(const ShippingSettings()) {
    _loadFromPrefsAndRemote();
  }

  Future<void> _loadFromPrefsAndRemote() async {
    // 1. Fast local cache load
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        state = ShippingSettings.fromJson(map);
      }
    } catch (_) {}

    // 2. Live remote Supabase Storage sync with cache-busting
    try {
      if (SupabaseConfig.isConfigured) {
        final rawUrl = supabase.storage.from('product-images').getPublicUrl(_storagePath);
        final freshUrl = '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}';

        final response = await http.get(
          Uri.parse(freshUrl),
          headers: {'Cache-Control': 'no-cache, no-store, must-revalidate', 'Pragma': 'no-cache'},
        );

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          final Map<String, dynamic> map = jsonDecode(response.body);
          final loaded = ShippingSettings.fromJson(map);
          state = loaded;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefsKey, response.body);
        }
      }
    } catch (_) {}
  }

  Future<void> updateSettings(ShippingSettings newSettings) async {
    state = newSettings;
    final jsonStr = jsonEncode(newSettings.toJson());

    // 1. Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonStr);
    } catch (_) {}

    // 2. Push to Supabase Storage remotely
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
}

final shippingSettingsProvider = StateNotifierProvider<ShippingSettingsNotifier, ShippingSettings>((ref) {
  return ShippingSettingsNotifier();
});
