import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('--- FETCHING REAL ORDERS FROM SUPABASE STORAGE ---');
  final ordersRes = await http.get(Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/orders.json?t=${DateTime.now().millisecondsSinceEpoch}'));
  print('Orders Status: ${ordersRes.statusCode}');
  if (ordersRes.statusCode == 200) {
    final List decoded = json.decode(ordersRes.body);
    print('Total orders count: ${decoded.length}');
    for (var o in decoded) {
      print('Order ${o['orderNumber'] ?? o['order_number']}: Name=${o['customerName'] ?? o['customer_name']} | Email=${o['customerEmail'] ?? o['customer_email']} | Phone=${o['customerPhone'] ?? o['customer_phone']} | Total=₹${o['totalAmount'] ?? o['total_amount']}');
    }
  }

  print('\n--- FETCHING REAL USERS FROM SUPABASE STORAGE ---');
  final usersRes = await http.get(Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/users.json?t=${DateTime.now().millisecondsSinceEpoch}'));
  print('Users Status: ${usersRes.statusCode}');
  if (usersRes.statusCode == 200) {
    final List decoded = json.decode(usersRes.body);
    print('Total users count: ${decoded.length}');
    for (var u in decoded) {
      print('User: Name=${u['name']} | Email=${u['email']} | Phone=${u['phone']} | Role=${u['role']}');
    }
  }
}
