import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final List<Map<String, dynamic>> allFetchedUsers = [];

  // 1. Fetch settings/users.json
  final Uri usersUri = Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/users.json?t=${DateTime.now().millisecondsSinceEpoch}');
  final response = await http.get(usersUri);
  if (response.statusCode == 200) {
    final List decoded = json.decode(response.body);
    for (var item in decoded) {
      allFetchedUsers.add(Map<String, dynamic>.from(item as Map));
    }
  }

  // 7. Read per-user saved addresses from Cloud Storage
  final Uri addrUri = Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/addresses.json?t=${DateTime.now().millisecondsSinceEpoch}');
  final addrResp = await http.get(addrUri);
  Map<String, List<Map<String, dynamic>>> cloudAddresses = {};
  if (addrResp.statusCode == 200 && addrResp.body.isNotEmpty) {
    final Map<String, dynamic> decoded = json.decode(addrResp.body);
    decoded.forEach((key, value) {
      if (value is List) {
        cloudAddresses[key.toLowerCase().trim()] = value.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    });
  }

  for (var u in allFetchedUsers) {
    final email = (u['email'] ?? '').toString().toLowerCase().trim();
    if (email.isNotEmpty) {
      if (cloudAddresses.containsKey(email) && cloudAddresses[email]!.isNotEmpty) {
        final firstAddr = cloudAddresses[email]!.first;
        final String aName = (firstAddr['name'] ?? '').toString();
        final String aPhone = (firstAddr['phone'] ?? '').toString();
        if (aName.isNotEmpty) u['name'] = aName;
        if (aPhone.isNotEmpty) u['phone'] = aPhone;
        u['street'] = firstAddr['street'] ?? firstAddr['address'] ?? '';
        u['address'] = firstAddr['street'] ?? firstAddr['address'] ?? '';
        u['city'] = firstAddr['city'] ?? '';
        u['state'] = firstAddr['state'] ?? '';
        u['pincode'] = firstAddr['pincode'] ?? '';
        u['addresses'] = cloudAddresses[email]!.length;
      }
    }
  }

  print('=== FETCHED USERS IN ADMIN DASHBOARD ===');
  for (var u in allFetchedUsers) {
    final String fullAddr = [u['street'], u['city'], u['state'], u['pincode']].where((s) => (s ?? '').toString().isNotEmpty).join(', ');
    print('User: ${u['name']} (${u['email']}) | Address: ${fullAddr.isNotEmpty ? fullAddr : '—'}');
  }
}
