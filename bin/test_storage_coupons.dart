import 'dart:convert';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  final testCoupons = [
    {
      'id': 'c-mega50',
      'code': 'MEGA50',
      'title': 'Rs 50 Discount',
      'discountType': 'percentage',
      'discountValue': 50.0,
      'minSpend': 150.0,
      'isVisibleAtCheckout': true,
      'isActive': true,
    },
    {
      'id': 'c-v20',
      'code': 'VAIDYAM20',
      'title': 'Get 20% OFF on all Ayurvedic Botanicals',
      'discountType': 'percentage',
      'discountValue': 20.0,
      'minSpend': 299.0,
      'isVisibleAtCheckout': false,
      'isActive': false,
    },
    {
      'id': 'c-org100',
      'code': 'ORGANIC100',
      'title': 'Flat ₹100 OFF on orders above ₹499',
      'discountType': 'fixed',
      'discountValue': 100.0,
      'minSpend': 499.0,
      'isVisibleAtCheckout': true,
      'isActive': true,
    },
    {
      'id': 'c-herb50',
      'code': 'HERBAL50',
      'title': 'Flat ₹50 OFF on first purchase',
      'discountType': 'fixed',
      'discountValue': 50.0,
      'minSpend': 199.0,
      'isVisibleAtCheckout': true,
      'isActive': true,
    },
    {
      'id': 'c-sec25',
      'code': 'SECRET25',
      'title': 'Exclusive 25% OFF VIP Coupon',
      'discountType': 'percentage',
      'discountValue': 25.0,
      'minSpend': 599.0,
      'isVisibleAtCheckout': true,
      'isActive': true,
    },
  ];

  print('1. Uploading coupons.json to Supabase Storage...');
  try {
    final bytes = utf8.encode(jsonEncode(testCoupons));
    await supabase.storage.from('product-images').uploadBinary(
          'settings/coupons.json',
          bytes,
          fileOptions: const FileOptions(contentType: 'application/json', upsert: true),
        );
    print('Uploaded coupons.json successfully!');

    final publicUrl = supabase.storage.from('product-images').getPublicUrl('settings/coupons.json');
    print('Public coupons JSON URL: $publicUrl');

    print('2. Downloading coupons.json back from Supabase Storage...');
    final downloadedBytes = await supabase.storage.from('product-images').download('settings/coupons.json');
    final downloadedStr = utf8.decode(downloadedBytes);
    print('Downloaded Content: $downloadedStr');
  } catch (e) {
    print('Error: $e');
  }
}
