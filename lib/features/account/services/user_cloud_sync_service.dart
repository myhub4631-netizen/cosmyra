import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/supabase_config.dart';

class UserCloudSyncService {
  static const String _usersUrl =
      'https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/users.json';
  static const String _addressesUrl =
      'https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/addresses.json';

  static const String _uploadUsersUrl =
      'https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/product-images/settings/users.json';
  static const String _uploadAddressesUrl =
      'https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/product-images/settings/addresses.json';

  /// Fetches all users from Supabase Storage `settings/users.json`
  static Future<List<Map<String, dynamic>>> fetchUsersFromCloud() async {
    try {
      final uri = Uri.parse('$_usersUrl?t=${DateTime.now().millisecondsSinceEpoch}');
      final resp = await http.get(uri);
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final List decoded = json.decode(resp.body);
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Fetches all user addresses map from Supabase Storage `settings/addresses.json`
  static Future<Map<String, List<Map<String, dynamic>>>> fetchAllAddressesFromCloud() async {
    try {
      final uri = Uri.parse('$_addressesUrl?t=${DateTime.now().millisecondsSinceEpoch}');
      final resp = await http.get(uri);
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(resp.body);
        final Map<String, List<Map<String, dynamic>>> result = {};
        decoded.forEach((key, value) {
          if (value is List) {
            result[key.toLowerCase()] =
                value.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        });
        return result;
      }
    } catch (_) {}
    return {};
  }

  /// Fetches saved addresses for a specific user email from cloud
  static Future<List<Map<String, dynamic>>> fetchUserAddressesFromCloud(String email) async {
    if (email.trim().isEmpty) return [];
    final all = await fetchAllAddressesFromCloud();
    return all[email.toLowerCase().trim()] ?? [];
  }

  /// Syncs single user profile and addresses to Supabase cloud storage & local SharedPreferences
  static Future<void> syncUserProfileAndAddress({
    required String email,
    required String name,
    required String phone,
    String? street,
    String? city,
    String? state,
    String? pincode,
    List<Map<String, dynamic>>? addressList,
    String? role,
    String? status,
    String? password,
  }) async {
    if (email.trim().isEmpty) return;
    final String cleanEmail = email.toLowerCase().trim();

    // 1. Update SharedPreferences cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final sanitized = cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

      final profMap = {
        'name': name,
        'email': cleanEmail,
        'phone': phone,
        if (role != null) 'role': role,
      };
      await prefs.setString('cosmyra_${sanitized}_profile_v2', jsonEncode(profMap));
      await prefs.setString('cosmyra_user_profile_v2', jsonEncode(profMap));

      if (addressList != null && addressList.isNotEmpty) {
        await prefs.setString('cosmyra_${sanitized}_addresses_v3', jsonEncode(addressList));
      } else if (street != null && street.isNotEmpty) {
        final singleAddr = [
          {
            'id': 'addr-${DateTime.now().millisecondsSinceEpoch}',
            'name': name,
            'phone': phone,
            'street': street,
            'address': street,
            'city': city ?? '',
            'state': state ?? '',
            'pincode': pincode ?? '',
            'type': 'HOME',
            'isDefault': 'true',
          }
        ];
        await prefs.setString('cosmyra_${sanitized}_addresses_v3', jsonEncode(singleAddr));
      }
    } catch (_) {}

    // 2. Fetch current users.json & addresses.json from cloud with retries
    List<Map<String, dynamic>> cloudUsers = await fetchUsersFromCloud();
    Map<String, List<Map<String, dynamic>>> cloudAddresses = await fetchAllAddressesFromCloud();

    if (cloudUsers.isEmpty) {
      for (int retry = 0; retry < 3; retry++) {
        await Future.delayed(const Duration(milliseconds: 400));
        final retryUsers = await fetchUsersFromCloud();
        if (retryUsers.isNotEmpty) {
          cloudUsers = retryUsers;
          break;
        }
      }
    }

    if (cloudAddresses.isEmpty) {
      for (int retry = 0; retry < 3; retry++) {
        await Future.delayed(const Duration(milliseconds: 400));
        final retryAddresses = await fetchAllAddressesFromCloud();
        if (retryAddresses.isNotEmpty) {
          cloudAddresses = retryAddresses;
          break;
        }
      }
    }

    // Safety fallback: Ensure core system users are never dropped if fetch failed
    final List<Map<String, dynamic>> defaultSystemUsers = [
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
        'street': 'Flat 402, Green Valley',
        'address': 'Flat 402, Green Valley',
        'city': 'Patna',
        'state': 'Bihar',
        'pincode': '800001'
      },
      {
        'id': '#USR-0002',
        'name': 'Mahboob 2 Add',
        'email': 'myhub4632@gmail.com',
        'phone': '9988776602',
        'role': 'Customer',
        'status': 'Active',
        'isVip': false,
        'isYou': false,
        'orders': 0,
        'totalSpent': 0.0,
        'joinedOn': '24 Aug 2026 02:00 AM',
        'lastLogin': '24 Aug 2026',
        'emailVerified': true,
        'phoneVerified': true,
        'addresses': 1,
        'street': 'Deepak Residency E70',
        'address': 'Deepak Residency E70',
        'city': 'Kota',
        'state': 'Rajasthan',
        'pincode': '324002'
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
        'addresses': 1
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
        'addresses': 1
      },
      {
        'id': '#USR-0005',
        'name': 'Mmmmm',
        'email': 'myhub4633@gmail.com',
        'phone': '9999999999',
        'role': 'Customer',
        'status': 'Active',
        'isVip': false,
        'isYou': false,
        'orders': 0,
        'totalSpent': 0.0,
        'joinedOn': '24 Aug 2026',
        'lastLogin': '24 Aug 2026',
        'emailVerified': true,
        'phoneVerified': true,
        'addresses': 2,
        'street': 'E 12 Kabsb',
        'address': 'E 12 Kabsb',
        'city': 'ksbs',
        'state': 'bihar',
        'pincode': '324001'
      }
    ];

    for (var defUser in defaultSystemUsers) {
      if (!cloudUsers.any((u) => u['email']?.toString().toLowerCase().trim() == defUser['email'])) {
        cloudUsers.add(defUser);
      }
    }

    // 3. Update or Add user in cloudUsers
    final idx = cloudUsers.indexWhere((u) => u['email']?.toString().toLowerCase().trim() == cleanEmail);

    final Map<String, dynamic> userRecord = idx >= 0 ? Map<String, dynamic>.from(cloudUsers[idx]) : {
      'id': '#USR-000${cloudUsers.length + 1}',
      'email': cleanEmail,
      'joinedOn': '24 Aug 2026',
      'emailVerified': true,
      'phoneVerified': phone.trim().isNotEmpty,
      'orders': 0,
      'totalSpent': 0,
    };

    userRecord['name'] = name;
    userRecord['phone'] = phone;
    userRecord['phoneVerified'] = phone.trim().isNotEmpty;
    if (role != null) userRecord['role'] = role;
    if (status != null) userRecord['status'] = status;
    if (password != null && password.isNotEmpty) userRecord['password'] = password;
    userRecord['lastLogin'] = '24 Aug 2026';

    if (street != null && street.isNotEmpty) {
      userRecord['street'] = street;
      userRecord['address'] = street;
      userRecord['city'] = city ?? '';
      userRecord['state'] = state ?? '';
      userRecord['pincode'] = pincode ?? '';
    } else if (addressList != null && addressList.isNotEmpty) {
      final first = addressList.first;
      userRecord['street'] = first['street'] ?? first['address'] ?? '';
      userRecord['address'] = first['street'] ?? first['address'] ?? '';
      userRecord['city'] = first['city'] ?? '';
      userRecord['state'] = first['state'] ?? '';
      userRecord['pincode'] = first['pincode'] ?? '';
    }

    if (addressList != null) {
      userRecord['addresses'] = addressList.length;
    } else if (street != null && street.isNotEmpty) {
      userRecord['addresses'] = 1;
    } else {
      userRecord['addresses'] = idx >= 0 ? (cloudUsers[idx]['addresses'] ?? 0) : 0;
    }

    if (idx >= 0) {
      cloudUsers[idx] = userRecord;
    } else {
      cloudUsers.add(userRecord);
    }

    // 4. Update cloudAddresses for cleanEmail
    if (addressList != null && addressList.isNotEmpty) {
      cloudAddresses[cleanEmail] = addressList;
    } else if (street != null && street.isNotEmpty) {
      cloudAddresses[cleanEmail] = [
        {
          'id': 'addr-${DateTime.now().millisecondsSinceEpoch}',
          'name': name,
          'phone': phone,
          'street': street,
          'address': street,
          'city': city ?? '',
          'state': state ?? '',
          'pincode': pincode ?? '',
          'type': 'HOME',
          'isDefault': 'true',
        }
      ];
    }

    // 5. Upload updated users.json & addresses.json to Supabase Storage
    try {
      final String anonKey = SupabaseConfig.anonKey;
      final Uri usersPostUrl = Uri.parse(_uploadUsersUrl);
      await http.post(
        usersPostUrl,
        headers: {
          'Content-Type': 'application/json',
          'x-upsert': 'true',
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
        body: json.encode(cloudUsers),
      );

      final Uri addrPostUrl = Uri.parse(_uploadAddressesUrl);
      await http.post(
        addrPostUrl,
        headers: {
          'Content-Type': 'application/json',
          'x-upsert': 'true',
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
        body: json.encode(cloudAddresses),
      );
    } catch (_) {}
  }
}
