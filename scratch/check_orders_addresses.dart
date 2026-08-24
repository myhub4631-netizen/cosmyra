import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final ordersRes = await http.get(Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/orders.json?t=${DateTime.now().millisecondsSinceEpoch}'));
  print('=== ORDERS.JSON ===');
  if (ordersRes.statusCode == 200) {
    final List decoded = json.decode(ordersRes.body);
    for (var ord in decoded) {
      print('Order ${ord['id']} | Customer: ${ord['customerEmail'] ?? ord['customer_email']} | ShippingAddress: ${ord['shippingAddress'] ?? ord['shipping_address'] ?? ord['address']}');
    }
  } else {
    print('Orders error: ${ordersRes.statusCode}');
  }
}
