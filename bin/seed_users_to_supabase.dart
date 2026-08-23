import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('=== RE-SEEDING CLEAN REAL USERS TO SUPABASE STORAGE (settings/users.json) ===');

  final String anonKey = 'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON';

  final List<Map<String, dynamic>> initialRealUsers = [
    {
      'id': '#USR-0001',
      'name': 'Mahboob Hasan',
      'email': '1mdollar2027@gmail.com',
      'phone': '+91 98765 43210',
      'role': 'Master Admin',
      'status': 'Active',
      'isVip': true,
      'isYou': true,
      'orders': 4,
      'totalSpent': 1455.0,
      'joinedOn': '15 Aug 2026 10:30 AM',
      'lastLogin': '24 Aug 2026 01:45 AM',
      'emailVerified': true,
      'phoneVerified': true,
      'addresses': 2,
    },
    {
      'id': '#USR-0002',
      'name': 'MyHub User',
      'email': 'myhub4632@gmail.com',
      'phone': '+91 94730 40903',
      'role': 'Customer',
      'status': 'Active',
      'isVip': false,
      'isYou': false,
      'orders': 0,
      'totalSpent': 0.0,
      'joinedOn': '24 Aug 2026 02:00 AM',
      'lastLogin': '24 Aug 2026 02:00 AM',
      'emailVerified': true,
      'phoneVerified': true,
      'addresses': 1,
    },
    {
      'id': '#USR-0003',
      'name': 'Cosmyra Admin',
      'email': 'admin@cosmyra.cloud',
      'phone': '+91 94730 40903',
      'role': 'Master Admin',
      'status': 'Active',
      'isVip': true,
      'isYou': false,
      'orders': 0,
      'totalSpent': 0.0,
      'joinedOn': '01 Aug 2026 08:00 AM',
      'lastLogin': '24 Aug 2026 01:00 AM',
      'emailVerified': true,
      'phoneVerified': true,
      'addresses': 1,
    },
    {
      'id': '#USR-0004',
      'name': 'Netizen Admin',
      'email': 'myhub4631@gmail.com',
      'phone': '+91 98765 43210',
      'role': 'Admin',
      'status': 'Active',
      'isVip': false,
      'isYou': false,
      'orders': 0,
      'totalSpent': 0.0,
      'joinedOn': '10 Aug 2026 09:00 AM',
      'lastLogin': '23 Aug 2026 11:30 PM',
      'emailVerified': true,
      'phoneVerified': true,
      'addresses': 1,
    },
  ];

  final String jsonString = json.encode(initialRealUsers);
  final Uri uploadUrl = Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/product-images/settings/users.json');

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
    print('SUCCESS! Real users file settings/users.json re-seeded to Supabase Storage with ZERO demo orders.');
  } else {
    print('FAILED to upload settings/users.json');
  }
}
