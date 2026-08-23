import 'dart:convert';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  final syncedCoupons = [
    {
      'id': 'c-mega50',
      'code': 'MEGA50',
      'title': 'Rs 66 Discount',
      'discountType': 'fixed',
      'discountValue': 66.0,
      'minSpend': 160.0,
      'isVisibleAtCheckout': true,
      'isActive': true,
    },
    {
      'id': 'c-v20',
      'code': 'VAIDYAM20',
      'title': 'Get 15% OFF on all Ayurvedic Botanicals',
      'discountType': 'percentage',
      'discountValue': 15.0,
      'minSpend': 180.0,
      'isVisibleAtCheckout': true,
      'isActive': true,
    },
    {
      'id': 'c-org100',
      'code': 'ORGANIC100',
      'title': 'Flat 10% OFF on orders above ₹169',
      'discountType': 'percentage',
      'discountValue': 10.0,
      'minSpend': 169.0,
      'isVisibleAtCheckout': true,
      'isActive': true,
    },
    {
      'id': 'c-herb50',
      'code': 'HERBAL50',
      'title': 'Flat ₹59 OFF on first purchase',
      'discountType': 'fixed',
      'discountValue': 59.0,
      'minSpend': 299.0,
      'isVisibleAtCheckout': true,
      'isActive': true,
    },
    {
      'id': 'c-sec25',
      'code': 'SECRET25',
      'title': 'Exclusive 22% OFF VIP Coupon',
      'discountType': 'percentage',
      'discountValue': 22.0,
      'minSpend': 199.0,
      'isVisibleAtCheckout': true,
      'isActive': true,
    },
  ];

  print('1. Uploading fully synced coupons JSON to Supabase Storage...');
  try {
    final bytes = utf8.encode(jsonEncode(syncedCoupons));
    await supabase.storage.from('product-images').uploadBinary(
          'settings/coupons.json',
          bytes,
          fileOptions: const FileOptions(contentType: 'application/json', upsert: true),
        );
    print('Uploaded synced coupons.json successfully!');
  } catch (e) {
    print('Error uploading coupons: $e');
  }
}
