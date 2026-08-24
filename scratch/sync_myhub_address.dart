import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final String anonKey = 'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON';
  final String addressesUrl = 'https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/product-images/settings/addresses.json';

  final postAddrRes = await http.post(
    Uri.parse(addressesUrl),
    headers: {
      'Content-Type': 'application/json',
      'x-upsert': 'true',
      'apikey': anonKey,
      'Authorization': 'Bearer $anonKey',
    },
    body: json.encode({
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
      'myhub4632@gmail.com': [
        {
          'id': 'addr-2',
          'name': 'Mahboob 2 Add',
          'phone': '9988776602',
          'street': 'Deepak Residency E70',
          'address': 'Deepak Residency E70',
          'city': 'Kota',
          'state': 'Rajasthan',
          'pincode': '324002',
          'type': 'HOME',
          'isDefault': 'true',
        }
      ]
    }),
  );

  print('Addresses POST status: ${postAddrRes.statusCode}');
  print('Addresses POST body: ${postAddrRes.body}');
}
