import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const url = 'https://tkwxkmmxweqrfdttkjfd.supabase.co';
  const anonKey = 'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON';

  print('Fetching orders from Supabase REST API...');
  final response = await http.get(
    Uri.parse('$url/rest/v1/orders?select=*,order_items(*)'),
    headers: {
      'apikey': anonKey,
      'Authorization': 'Bearer $anonKey',
    },
  );

  print('Status code: ${response.statusCode}');
  print('Response body: ${response.body}');
}
