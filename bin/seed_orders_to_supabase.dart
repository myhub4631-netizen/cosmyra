import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Seeding orders to Supabase Storage settings/orders.json...');

  final initialOrders = [
    {
      'id': 'ord-2026-954130',
      'order_number': 'CSM-2026-954130',
      'user_id': null,
      'is_guest': true,
      'customer_name': 'Mahboob Hasan',
      'customer_email': '1mdollar2027@gmail.com',
      'customer_phone': '9999999999',
      'shipping_address': {
        'address': 'Flat 402, Green Valley',
        'city': 'Patna',
        'state': 'Bihar',
        'pincode': '800001',
      },
      'subtotal_inr': 459.0,
      'discount_inr': 0.0,
      'shipping_fee_inr': 0.0,
      'total_amount_inr': 459.0,
      'payment_method': 'UPI',
      'payment_status': 'captured',
      'fulfillment_status': 'placed',
      'created_at': DateTime(2026, 5, 24, 14, 30).toIso8601String(),
      'order_items': [
        {
          'id': 'itm-954130-1',
          'order_id': 'ord-2026-954130',
          'product_variant_id': 'var-vaidyam-shampoo-250ml',
          'product_name': 'Vaidyam Organic Herbal Shampoo 250ml',
          'variant_name': '250ml Bottle',
          'unit_price_inr': 459.0,
          'quantity': 1,
          'total_price_inr': 459.0,
        }
      ]
    },
    {
      'id': 'ord-2026-595292',
      'order_number': 'CSM-2026-595292',
      'user_id': null,
      'is_guest': true,
      'customer_name': 'Mahboob Hasan',
      'customer_email': '1mdollar2027@gmail.com',
      'customer_phone': '9999999999',
      'shipping_address': {
        'address': 'Flat 402, Green Valley',
        'city': 'Patna',
        'state': 'Bihar',
        'pincode': '800001',
      },
      'subtotal_inr': 198.0,
      'discount_inr': 0.0,
      'shipping_fee_inr': 0.0,
      'total_amount_inr': 198.0,
      'payment_method': 'UPI',
      'payment_status': 'captured',
      'fulfillment_status': 'placed',
      'created_at': DateTime(2026, 5, 23, 11, 15).toIso8601String(),
      'order_items': [
        {
          'id': 'itm-595292-1',
          'order_id': 'ord-2026-595292',
          'product_variant_id': 'var-vaidyam-oil-100ml',
          'product_name': 'Vaidyam Ayurvedic Hair Oil 100ml',
          'variant_name': '100ml Bottle',
          'unit_price_inr': 198.0,
          'quantity': 1,
          'total_price_inr': 198.0,
        }
      ]
    },
    {
      'id': 'ord-2026-613045',
      'order_number': 'CSM-2026-613045',
      'user_id': null,
      'is_guest': true,
      'customer_name': 'Mahboob Hasan',
      'customer_email': '1mdollar2027@gmail.com',
      'customer_phone': '9999999999',
      'shipping_address': {
        'address': 'Flat 402, Green Valley',
        'city': 'Patna',
        'state': 'Bihar',
        'pincode': '800001',
      },
      'subtotal_inr': 148.0,
      'discount_inr': 0.0,
      'shipping_fee_inr': 0.0,
      'total_amount_inr': 148.0,
      'payment_method': 'Cash on Delivery',
      'payment_status': 'pending',
      'fulfillment_status': 'placed',
      'created_at': DateTime(2026, 8, 16, 14, 33).toIso8601String(),
      'order_items': [
        {
          'id': 'itm-613045-1',
          'order_id': 'ord-2026-613045',
          'product_variant_id': 'var-vaidyam-facewash-100ml',
          'product_name': 'Vaidyam Neem Face Wash 100ml',
          'variant_name': '100ml Tube',
          'unit_price_inr': 148.0,
          'quantity': 1,
          'total_price_inr': 148.0,
        }
      ]
    },
    {
      'id': 'ord-2026-412243',
      'order_number': 'CSM-2026-412243',
      'user_id': null,
      'is_guest': true,
      'customer_name': 'Mahboob Hasan',
      'customer_email': '1mdollar2027@gmail.com',
      'customer_phone': '9999999999',
      'shipping_address': {
        'address': 'Flat 402, Green Valley',
        'city': 'Patna',
        'state': 'Bihar',
        'pincode': '800001',
      },
      'subtotal_inr': 198.0,
      'discount_inr': 0.0,
      'shipping_fee_inr': 0.0,
      'total_amount_inr': 198.0,
      'payment_method': 'Cash on Delivery',
      'payment_status': 'pending',
      'fulfillment_status': 'placed',
      'created_at': DateTime(2026, 8, 16, 14, 27).toIso8601String(),
      'order_items': [
        {
          'id': 'itm-412243-1',
          'order_id': 'ord-2026-412243',
          'product_variant_id': 'var-vaidyam-oil-100ml',
          'product_name': 'Vaidyam Ayurvedic Hair Oil 100ml',
          'variant_name': '100ml Bottle',
          'unit_price_inr': 198.0,
          'quantity': 1,
          'total_price_inr': 198.0,
        }
      ]
    },
  ];

  final String jsonStr = jsonEncode(initialOrders);
  final bytes = utf8.encode(jsonStr);

  const url = 'https://tkwxkmmxweqrfdttkjfd.supabase.co';
  const anonKey = 'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON';

  final res = await http.post(
    Uri.parse('$url/storage/v1/object/product-images/settings/orders.json'),
    headers: {
      'apikey': anonKey,
      'Authorization': 'Bearer $anonKey',
      'Content-Type': 'application/json',
      'x-upsert': 'true',
    },
    body: bytes,
  );

  print('Upload orders.json status code: ${res.statusCode}');
  print('Upload response: ${res.body}');
}
