import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  final testCoupons = [
    {
      'code': 'MEGA50',
      'discount_type': 'percentage',
      'discount_value': 50.0,
      'min_order_value_inr': 150.0,
      'is_active': true,
    },
    {
      'code': 'VAIDYAM20',
      'discount_type': 'percentage',
      'discount_value': 20.0,
      'min_order_value_inr': 299.0,
      'is_active': false,
    },
    {
      'code': 'ORGANIC100',
      'discount_type': 'fixed',
      'discount_value': 100.0,
      'min_order_value_inr': 499.0,
      'is_active': true,
    },
    {
      'code': 'HERBAL50',
      'discount_type': 'fixed',
      'discount_value': 50.0,
      'min_order_value_inr': 199.0,
      'is_active': true,
    },
    {
      'code': 'SECRET25',
      'discount_type': 'percentage',
      'discount_value': 25.0,
      'min_order_value_inr': 599.0,
      'is_active': true,
    },
  ];

  print('2. Upserting standard columns into Supabase coupons table...');
  try {
    for (var coupon in testCoupons) {
      final res = await supabase.from('coupons').upsert(coupon, onConflict: 'code').select();
      print('Upserted ${coupon['code']}: $res');
    }
    print('SUCCESSFULLY seeded coupons to Supabase!');
  } catch (e) {
    print('Upsert failed: $e');
  }
}
