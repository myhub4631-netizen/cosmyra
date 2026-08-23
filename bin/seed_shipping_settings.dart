import 'dart:convert';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  final defaultSettings = {
    'standardShippingFee': 0.0, // 0 / Free
    'freeShippingThreshold': 399.0, // Free on orders >= ₹399
    'isSuperfastEnabled': true,
    'superfastDeliveryFee': 60.0, // Superfast charge: Rs 60
  };

  print('Uploading initial shipping_settings.json to Supabase Storage...');
  try {
    final bytes = utf8.encode(jsonEncode(defaultSettings));
    await supabase.storage.from('product-images').uploadBinary(
          'settings/shipping_settings.json',
          bytes,
          fileOptions: const FileOptions(contentType: 'application/json', upsert: true),
        );
    print('Uploaded initial shipping_settings.json successfully!');
  } catch (e) {
    print('Error seeding shipping settings: $e');
  }
}
