import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  final baseUrl = supabase.storage.from('product-images').getPublicUrl('settings/coupons.json');
  final freshUrl = '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';

  print('Fetching from fresh URL: $freshUrl');
  try {
    final response = await http.get(
      Uri.parse(freshUrl),
      headers: {'Cache-Control': 'no-cache, no-store, must-revalidate'},
    );
    print('Status code: ${response.statusCode}');
    print('Content: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
