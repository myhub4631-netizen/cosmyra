import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRrd3hrbW14d2VxcmZkdHRramZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxNzE3MTksImV4cCI6MjA1NTc0NzcxOX0.8N8b950nE328V1P8h1P3-6n-8P-6n-8P-6n-8P-6n-8';
  
  const String usersUrl = 'https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/users.json';
  const String addressesUrl = 'https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/addresses.json';

  try {
    final resp = await http.get(Uri.parse('$usersUrl?t=${DateTime.now().millisecondsSinceEpoch}'));
    if (resp.statusCode == 200) {
      final List decoded = json.decode(resp.body);
      final List<Map<String, dynamic>> users = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      for (var u in users) {
        if (u['email']?.toString().toLowerCase().trim() == 'myhub4637@gmail.com') {
          u['name'] = 'Mahboob 7';
          u['phone'] = '9977776600';
          u['street'] = 'Deepak Residency E 70';
          u['address'] = 'Deepak Residency E 70';
          u['city'] = 'Kota';
          u['state'] = 'Rajasthan';
          u['pincode'] = '324001';
          u['addresses'] = 1;
        }
      }

      await http.post(
        Uri.parse(usersUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-upsert': 'true',
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
        body: json.encode(users),
      );
      print('Successfully seeded users.json to Supabase Cloud Storage!');
    }

    final Map<String, dynamic> addressesMap = {
      'myhub4637@gmail.com': [
        {
          'id': 'addr-1787518218',
          'name': 'Mahboob 7',
          'phone': '9977776600',
          'street': 'Deepak Residency E 70',
          'address': 'Deepak Residency E 70',
          'city': 'Kota',
          'state': 'Rajasthan',
          'pincode': '324001',
          'type': 'HOME',
          'isDefault': 'true'
        }
      ]
    };

    await http.post(
      Uri.parse(addressesUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-upsert': 'true',
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
      },
      body: json.encode(addressesMap),
    );
    print('Successfully seeded addresses.json to Supabase Cloud Storage!');

  } catch (e) {
    print('Error seeding cloud storage: $e');
  }
}
