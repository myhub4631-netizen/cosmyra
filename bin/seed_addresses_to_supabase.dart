import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('=== SEEDING ADDRESSES.JSON TO SUPABASE STORAGE ===');

  final String anonKey = 'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON';

  final Map<String, List<Map<String, dynamic>>> initialAddresses = {
    '1mdollar2027@gmail.com': [
      {
        'id': 'addr-1',
        'name': 'Mahboob Hasan',
        'phone': '+91 98765 43210',
        'street': 'Flat 402, Green Valley',
        'address': 'Flat 402, Green Valley',
        'city': 'Patna',
        'state': 'Bihar',
        'pincode': '800001',
        'type': 'HOME',
        'isDefault': 'true',
      }
    ],
  };

  final String jsonString = json.encode(initialAddresses);
  final Uri uploadUrl = Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/product-images/settings/addresses.json');

  final response = await http.post(
    uploadUrl,
    headers: {
      'Content-Type': 'application/json',
      'x-upsert': 'true',
      'apikey': anonKey,
      'Authorization': 'Bearer $anonKey',
    },
    body: jsonString,
  );

  print('Upload Status Code: ${response.statusCode}');
  print('Upload Response: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('SUCCESS! settings/addresses.json seeded to Supabase Storage.');
  } else {
    print('FAILED to upload settings/addresses.json');
  }
}
