import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final String anonKey = 'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON';
  final Uri url = Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/rest/v1/profiles?select=*');

  final response = await http.get(
    url,
    headers: {
      'apikey': anonKey,
      'Authorization': 'Bearer $anonKey',
    },
  );

  print('=== PROFILES TABLE IN SUPABASE DB ===');
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
