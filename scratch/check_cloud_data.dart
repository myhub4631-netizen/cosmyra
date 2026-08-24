import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final usersRes = await http.get(Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/users.json?t=${DateTime.now().millisecondsSinceEpoch}'));
  print('=== USERS.JSON ===');
  print(usersRes.body);

  final addrRes = await http.get(Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/addresses.json?t=${DateTime.now().millisecondsSinceEpoch}'));
  print('=== ADDRESSES.JSON ===');
  print(addrRes.body);
}
