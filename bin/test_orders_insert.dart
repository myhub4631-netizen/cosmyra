import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const url = 'https://tkwxkmmxweqrfdttkjfd.supabase.co';
  const anonKey = 'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON';

  print('Testing insert into Supabase orders table...');
  final response = await http.post(
    Uri.parse('$url/rest/v1/orders'),
    headers: {
      'apikey': anonKey,
      'Authorization': 'Bearer $anonKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    },
    body: jsonEncode({
      'order_number': 'CSM-2026-TEST1',
      'customer_name': 'Test User',
      'customer_email': 'test@example.com',
      'customer_phone': '9999999999',
      'shipping_address': {'address': 'Test St'},
      'subtotal_inr': 100.0,
      'discount_inr': 0.0,
      'shipping_fee_inr': 0.0,
      'total_amount_inr': 100.0,
      'payment_method': 'UPI',
      'payment_status': 'captured',
      'fulfillment_status': 'placed',
    }),
  );

  print('Insert status code: ${response.statusCode}');
  print('Insert response body: ${response.body}');
}
