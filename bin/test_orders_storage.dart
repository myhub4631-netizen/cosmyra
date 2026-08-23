import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const url = 'https://tkwxkmmxweqrfdttkjfd.supabase.co';
  const anonKey = 'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON';

  print('Testing Supabase Storage for orders.json...');
  final getRes = await http.get(
    Uri.parse('$url/storage/v1/object/public/product-images/settings/orders.json?t=${DateTime.now().millisecondsSinceEpoch}'),
    headers: {
      'Cache-Control': 'no-cache',
    },
  );

  print('Get orders.json status code: ${getRes.statusCode}');
  print('Get orders.json body: ${getRes.body}');
}
