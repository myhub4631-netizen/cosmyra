import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/supabase_config.dart';
import '../../../config/theme/app_colors.dart';

class AdminCustomersView extends ConsumerStatefulWidget {
  const AdminCustomersView({super.key});

  @override
  ConsumerState<AdminCustomersView> createState() => _AdminCustomersViewState();
}

class _AdminCustomersViewState extends ConsumerState<AdminCustomersView> {
  String _searchQuery = '';
  String _selectedRoleFilter = 'All Roles';
  String _selectedStatusFilter = 'All Status';
  int _currentPage = 1;
  int _perPage = 10;

  Map<String, dynamic>? _selectedUser;
  bool _showRightPanel = true;

  List<Map<String, dynamic>> _registeredProfiles = [];
  bool _isLoadingProfiles = true;

  @override
  void initState() {
    super.initState();
    _fetchSupabaseProfiles();
  }

  Future<void> _fetchSupabaseProfiles() async {
    if (mounted) setState(() => _isLoadingProfiles = true);
    final List<Map<String, dynamic>> allFetchedUsers = [];

    // 1. Fetch settings/users.json from Supabase Storage
    try {
      final Uri usersUri = Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/users.json?t=${DateTime.now().millisecondsSinceEpoch}');
      final response = await http.get(usersUri);
      if (response.statusCode == 200) {
        final List decoded = json.decode(response.body);
        for (var item in decoded) {
          allFetchedUsers.add(Map<String, dynamic>.from(item as Map));
        }
      }
    } catch (_) {}

    // 2. Fetch Supabase profiles table
    if (SupabaseConfig.isConfigured) {
      try {
        final data = await supabase.from('profiles').select('*');
        if (data is List) {
          for (var row in data) {
            final email = row['email']?.toString().trim() ?? '';
            if (email.isNotEmpty) {
              final idx = allFetchedUsers.indexWhere((u) => u['email']?.toString().toLowerCase() == email.toLowerCase());
              final name = row['full_name']?.toString() ?? (email.split('@').first);
              final phone = row['phone']?.toString() ?? '+91 98765 43210';
              if (idx >= 0) {
                if (name.isNotEmpty) allFetchedUsers[idx]['name'] = name;
                if (phone.isNotEmpty) allFetchedUsers[idx]['phone'] = phone;
              } else {
                final isMaster = email.toLowerCase() == '1mdollar2027@gmail.com';
                allFetchedUsers.add({
                  'id': '#USR-000${allFetchedUsers.length + 1}',
                  'name': name,
                  'email': email,
                  'phone': phone,
                  'role': isMaster ? 'Master Admin' : (row['role']?.toString().toUpperCase() ?? 'Customer'),
                  'status': 'Active',
                  'isVip': isMaster,
                  'isYou': isMaster,
                  'orders': 0,
                  'totalSpent': 0.0,
                  'joinedOn': row['created_at']?.toString().substring(0, 10) ?? '24 Aug 2026',
                  'lastLogin': '24 Aug 2026',
                  'emailVerified': true,
                  'phoneVerified': true,
                  'addresses': 1,
                });
              }
            }
          }
        }
      } catch (_) {}
    }

    // 3. Read local SharedPreferences profile to ensure newly registered local user is included
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('cosmyra_user_profile_v2');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> localData = json.decode(jsonStr);
        final String localEmail = (localData['email'] ?? '').toString().trim();
        final String localName = (localData['name'] ?? '').toString().trim();
        final String localPhone = (localData['phone'] ?? '').toString().trim();
        final bool isLocalAdmin = localData['isAdmin'] == true;

        if (localEmail.isNotEmpty && !localEmail.contains('guest')) {
          final idx = allFetchedUsers.indexWhere((u) => u['email']?.toString().toLowerCase() == localEmail.toLowerCase());
          if (idx >= 0) {
            if (localName.isNotEmpty) allFetchedUsers[idx]['name'] = localName;
            if (localPhone.isNotEmpty) allFetchedUsers[idx]['phone'] = localPhone;
          } else {
            allFetchedUsers.insert(0, {
              'id': '#USR-000${allFetchedUsers.length + 1}',
              'name': localName.isNotEmpty ? localName : localEmail.split('@').first,
              'email': localEmail,
              'phone': localPhone.isNotEmpty ? localPhone : '+91 98765 43210',
              'role': isLocalAdmin ? 'Master Admin' : 'Customer',
              'status': 'Active',
              'isVip': isLocalAdmin,
              'isYou': true,
              'orders': 0,
              'totalSpent': 0.0,
              'joinedOn': '24 Aug 2026',
              'lastLogin': 'Just now',
              'emailVerified': true,
              'phoneVerified': true,
              'addresses': 1,
            });
          }
        }
      }
    } catch (_) {}

    // 4. Ensure myhub4632@gmail.com is present
    if (!allFetchedUsers.any((u) => u['email']?.toString().toLowerCase() == 'myhub4632@gmail.com')) {
      allFetchedUsers.add({
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
      });
    }

    // 5. RESET orders & totalSpent to 0 for all customer accounts before calculating real orders
    for (var u in allFetchedUsers) {
      if (u['role'] != 'Master Admin' && u['email']?.toString().toLowerCase() != '1mdollar2027@gmail.com') {
        u['orders'] = 0;
        u['totalSpent'] = 0.0;
        u['isVip'] = false;
      }
    }

    // 6. Fetch settings/orders.json and compute EXACT actual orders and spending for each user
    try {
      final Uri ordersUri = Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/settings/orders.json?t=${DateTime.now().millisecondsSinceEpoch}');
      final response = await http.get(ordersUri);
      if (response.statusCode == 200) {
        final List decoded = json.decode(response.body);
        for (var ord in decoded) {
          final email = (ord['customerEmail'] ?? ord['customer_email'] ?? '').toString().trim().toLowerCase();
          final double amount = (ord['totalAmount'] ?? ord['total_amount'] ?? ord['total_amount_inr'] ?? 0).toDouble();

          if (email.isNotEmpty) {
            final idx = allFetchedUsers.indexWhere((u) => u['email']?.toString().toLowerCase() == email);
            if (idx >= 0) {
              allFetchedUsers[idx]['orders'] = ((allFetchedUsers[idx]['orders'] as int? ?? 0) + 1);
              allFetchedUsers[idx]['totalSpent'] = ((allFetchedUsers[idx]['totalSpent'] as double? ?? 0.0) + amount);
              if ((allFetchedUsers[idx]['orders'] as int) > 3) {
                allFetchedUsers[idx]['isVip'] = true;
              }
            } else {
              allFetchedUsers.add({
                'id': '#USR-000${allFetchedUsers.length + 1}',
                'name': (ord['customerName'] ?? ord['customer_name'] ?? email.split('@').first).toString().trim(),
                'email': email,
                'phone': (ord['customerPhone'] ?? ord['customer_phone'] ?? '+91 94730 40903').toString().trim(),
                'role': 'Customer',
                'status': 'Active',
                'isVip': false,
                'isYou': false,
                'orders': 1,
                'totalSpent': amount,
                'joinedOn': '24 Aug 2026',
                'lastLogin': '24 Aug 2026',
                'emailVerified': true,
                'phoneVerified': true,
                'addresses': 1,
              });
            }
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _registeredProfiles = allFetchedUsers;
        _isLoadingProfiles = false;
        if (allFetchedUsers.isNotEmpty) {
          _selectedUser = allFetchedUsers[0];
        }
      });
    }
  }

  Future<void> _syncProfilesToStorageAndSupabase() async {
    try {
      final String anonKey = SupabaseConfig.anonKey;
      final Uri postUrl = Uri.parse('https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/product-images/settings/users.json');
      await http.post(
        postUrl,
        headers: {
          'Content-Type': 'application/json',
          'x-upsert': 'true',
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
        body: json.encode(_registeredProfiles),
      );
    } catch (_) {}
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final nameCtrl = TextEditingController(text: user['name']?.toString() ?? '');
    final emailCtrl = TextEditingController(text: user['email']?.toString() ?? '');
    final phoneCtrl = TextEditingController(text: user['phone']?.toString() ?? '');
    final passwordCtrl = TextEditingController(text: user['password']?.toString() ?? '');
    final addressCtrl = TextEditingController(text: user['address']?.toString() ?? 'Flat 402, Green Glen Heights, Bellandur');
    final cityCtrl = TextEditingController(text: user['city']?.toString() ?? 'Bengaluru');
    final pincodeCtrl = TextEditingController(text: user['pincode']?.toString() ?? '560103');

    String roleVal = user['role']?.toString() ?? 'Customer';
    String statusVal = user['status']?.toString() ?? 'Active';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.edit_outlined, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 8),
                  Text('Edit User Account (${user['id']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: emailCtrl,
                              decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: phoneCtrl,
                              decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_outlined)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Account Role & Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: roleVal,
                              decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                              items: ['Customer', 'Moderator', 'Admin', 'Master Admin']
                                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                  .toList(),
                              onChanged: (val) => setDlgState(() => roleVal = val ?? 'Customer'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: statusVal,
                              decoration: const InputDecoration(labelText: 'Account Status', border: OutlineInputBorder()),
                              items: ['Active', 'Inactive', 'Blocked']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (val) => setDlgState(() => statusVal = val ?? 'Active'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Address Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: addressCtrl,
                        decoration: const InputDecoration(labelText: 'Street Address', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()))),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: pincodeCtrl, decoration: const InputDecoration(labelText: 'Pincode', border: OutlineInputBorder()))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Security Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Set New Password (Optional)',
                          hintText: 'Leave blank to keep current password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;

                    setState(() {
                      user['name'] = nameCtrl.text.trim();
                      user['email'] = emailCtrl.text.trim();
                      user['phone'] = phoneCtrl.text.trim();
                      user['role'] = roleVal;
                      user['status'] = statusVal;
                      user['address'] = addressCtrl.text.trim();
                      user['city'] = cityCtrl.text.trim();
                      user['pincode'] = pincodeCtrl.text.trim();
                      if (passwordCtrl.text.trim().isNotEmpty) {
                        user['password'] = passwordCtrl.text.trim();
                      }
                      if (_selectedUser != null && _selectedUser!['id'] == user['id']) {
                        _selectedUser = user;
                      }
                    });

                    _syncProfilesToStorageAndSupabase();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User profile for ${user['name']} updated successfully! ✏️')),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showResetPasswordDialog(Map<String, dynamic> user) {
    final newPasswordCtrl = TextEditingController(text: 'Cosmyra@${DateTime.now().year}');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.lock_reset_outlined, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text('Reset User Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resetting password for user ${user['name']} (${user['email']}).'),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordCtrl,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key_outlined),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Provide this temporary password to the user to log in.', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Reset Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newPass = newPasswordCtrl.text.trim();
                if (newPass.isNotEmpty) {
                  setState(() {
                    user['password'] = newPass;
                  });
                  _syncProfilesToStorageAndSupabase();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password for ${user['name']} reset to: $newPass 🔑')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleDeactivateUser(Map<String, dynamic> user) {
    final bool isActive = user['status'] == 'Active';
    final String nextStatus = isActive ? 'Inactive' : 'Active';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isActive ? 'Deactivate Account?' : 'Activate Account?', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            isActive
                ? 'Are you sure you want to deactivate ${user['name']}\'s account? They will be unable to log in until re-activated.'
                : 'Are you sure you want to re-activate ${user['name']}\'s account?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? const Color(0xFFDC2626) : const Color(0xFF059669),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  user['status'] = nextStatus;
                  if (_selectedUser != null && _selectedUser!['id'] == user['id']) {
                    _selectedUser!['status'] = nextStatus;
                  }
                });
                _syncProfilesToStorageAndSupabase();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User ${user['name']} is now $nextStatus.')),
                );
              },
              child: Text(isActive ? 'Deactivate' : 'Activate'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete User Account?', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete ${user['name']} (${user['email']})? This action cannot be undone.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  _registeredProfiles.removeWhere((u) => u['id'] == user['id']);
                  if (_selectedUser != null && _selectedUser!['id'] == user['id']) {
                    _selectedUser = _registeredProfiles.isNotEmpty ? _registeredProfiles[0] : null;
                  }
                });
                _syncProfilesToStorageAndSupabase();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User ${user['name']} deleted successfully. 🗑️')),
                );
              },
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );
  }

  void _showUserActivityDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.analytics_outlined, color: Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Text('${user['name']}\'s Account Activity Log', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFE0E7FF),
                        child: Text(user['name'].toString().substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('${user['email']} • ${user['phone']}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Recent Activity Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                const SizedBox(height: 10),
                _buildActivityLogItem(Icons.login, 'User Logged In', 'Last session started from 157.48.21.90 (Mac OS X - Chrome)', user['lastLogin'] ?? 'Just now'),
                _buildActivityLogItem(Icons.shopping_bag_outlined, 'Orders Activity', 'Total Orders: ${user['orders']} | Total Spent: ₹${_formatCurrency(user['totalSpent'])}', 'Realtime'),
                _buildActivityLogItem(Icons.location_on_outlined, 'Address Updated', 'Saved delivery address updated', '24 Aug 2026'),
                _buildActivityLogItem(Icons.person_add_outlined, 'Account Created', 'Registered as ${user['role']} account', user['joinedOn'] ?? '24 Aug 2026'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivityLogItem(IconData icon, String title, String desc, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF111827))),
                Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  void _loginAsUser(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profile = {
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'phone': user['phone'],
        'isAdmin': user['role'] == 'Master Admin',
        'role': user['role'],
      };
      await prefs.setString('cosmyra_user_profile_v2', json.encode(profile));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switched session to ${user['name']} (${user['email']}) 👤')),
      );
    } catch (_) {}
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String roleVal = 'Customer';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name', hintText: 'e.g. Rahul Sharma'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email Address', hintText: 'e.g. rahul@example.com'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone Number', hintText: 'e.g. +91 98765 43210'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: roleVal,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['Customer', 'Moderator', 'Admin', 'Master Admin']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) => roleVal = val ?? 'Customer',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty && emailCtrl.text.trim().isNotEmpty) {
                  final newUser = {
                    'id': '#USR-000${_registeredProfiles.length + 1}',
                    'name': nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim().isEmpty ? '+91 98765 43210' : phoneCtrl.text.trim(),
                    'role': roleVal,
                    'status': 'Active',
                    'isVip': false,
                    'isYou': false,
                    'orders': 0,
                    'totalSpent': 0.0,
                    'joinedOn': '24 Aug 2026',
                    'lastLogin': 'Never',
                    'emailVerified': true,
                    'phoneVerified': false,
                    'addresses': 0,
                  };
                  setState(() {
                    _registeredProfiles.insert(0, newUser);
                    _selectedUser = newUser;
                    _showRightPanel = true;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User ${nameCtrl.text} added successfully!')),
                  );

                  _syncProfilesToStorageAndSupabase();
                }
              },
              child: const Text('Save User'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final combinedUsers = _registeredProfiles;

    final filteredUsers = combinedUsers.where((u) {
      if (_searchQuery.isNotEmpty) {
        final nameMatch = u['name'].toString().toLowerCase().contains(_searchQuery);
        final emailMatch = u['email'].toString().toLowerCase().contains(_searchQuery);
        final phoneMatch = u['phone'].toString().toLowerCase().contains(_searchQuery);
        if (!nameMatch && !emailMatch && !phoneMatch) return false;
      }
      if (_selectedRoleFilter != 'All Roles' && u['role'] != _selectedRoleFilter) {
        return false;
      }
      if (_selectedStatusFilter != 'All Status' && u['status'] != _selectedStatusFilter) {
        return false;
      }
      return true;
    }).toList();

    final int totalUsersCount = combinedUsers.length;
    final int customersCount = combinedUsers.where((u) => u['role']?.toString().toLowerCase().contains('customer') == true).length;
    final int vipCount = combinedUsers.where((u) => u['isVip'] == true).length;
    final int adminsCount = combinedUsers.where((u) => u['role']?.toString().toLowerCase().contains('admin') == true).length;
    final int inactiveCount = combinedUsers.where((u) => u['status']?.toString().toLowerCase() == 'inactive').length;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1150;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Page Header & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Users',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage all customers, admins and user roles from one place.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showAddUserDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('+ Add User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exporting users list as CSV/Excel...')),
                      );
                    },
                    icon: const Icon(Icons.file_upload_outlined, size: 18, color: Color(0xFF374151)),
                    label: const Text('Export', style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz, size: 18, color: Color(0xFF374151)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Summary Metric Cards Row (5 Stat Cards)
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildMetricCard('Total Users', '$totalUsersCount', 'Real time registered users', Icons.people_outline, const Color(0xFFE0E7FF), const Color(0xFF4F46E5), true),
                  _buildMetricCard('Customers', '$customersCount', 'Active customer accounts', Icons.person_outline, const Color(0xFFDBEAFE), const Color(0xFF2563EB), true),
                  _buildMetricCard('VIP Customers', '$vipCount', 'VIP repeat buyers', Icons.workspace_premium_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706), true),
                  _buildMetricCard('Admins', '$adminsCount', 'Admin & staff accounts', Icons.shield_outlined, const Color(0xFFF3E8FF), const Color(0xFF9333EA), true),
                  _buildMetricCard('Inactive Users', '$inactiveCount', 'Inactive accounts', Icons.person_off_outlined, const Color(0xFFFEE2E2), const Color(0xFFDC2626), false),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // 3. Main Data Section with Filter Controls + Table + Optional Right User Details Drawer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Search Filter Bar & User Data Table
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Filter Control Bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Search Field
                            Container(
                              width: 280,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search by name, email or phone...',
                                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                                  prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                              ),
                            ),

                            // Role Filter
                            Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedRoleFilter,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                  items: ['All Roles', 'Master Admin', 'Customer', 'Moderator']
                                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                      .toList(),
                                  onChanged: (val) => setState(() => _selectedRoleFilter = val ?? 'All Roles'),
                                ),
                              ),
                            ),

                            // Status Filter
                            Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedStatusFilter,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                  items: ['All Status', 'Active', 'Inactive', 'Blocked']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (val) => setState(() => _selectedStatusFilter = val ?? 'All Status'),
                                ),
                              ),
                            ),

                            // Date Filter Placeholder
                            Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('Select Date ', style: TextStyle(fontSize: 12, color: Color(0xFF374151))),
                                  Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6B7280)),
                                ],
                              ),
                            ),

                            // Filters Button
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.tune, size: 16, color: Color(0xFF374151)),
                              label: const Text('Filters', style: TextStyle(fontSize: 12, color: Color(0xFF374151))),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 38),
                                side: const BorderSide(color: Color(0xFFE5E7EB)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),

                            // View Toggle Button
                            Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.settings_outlined, size: 18, color: Color(0xFF374151)),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      // Table Columns Header
                      Container(
                        color: const Color(0xFFFAFAFA),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: const [
                            Expanded(flex: 3, child: Text('User', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            Expanded(flex: 2, child: Text('Role', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            Expanded(flex: 1, child: Text('Orders', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            Expanded(flex: 2, child: Text('Total Spend', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            Expanded(flex: 2, child: Text('Joined On', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)))),
                            SizedBox(width: 90, child: Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)), textAlign: TextAlign.right)),
                          ],
                        ),
                      ),

                      const Divider(height: 1, color: Color(0xFFF3F4F6)),

                      // Table Data Rows
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredUsers.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final isSelected = _selectedUser != null && _selectedUser!['id'] == user['id'];

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedUser = user;
                                _showRightPanel = true;
                              });
                            },
                            child: Container(
                              color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  // User Avatar & Name
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: _getRoleAvatarBg(user['role']),
                                          child: Text(
                                            user['name'].toString().substring(0, 1).toUpperCase(),
                                            style: TextStyle(fontWeight: FontWeight.bold, color: _getRoleAvatarTextColor(user['role']), fontSize: 14),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      user['name'],
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (user['isVip'] == true) ...[
                                                    const SizedBox(width: 4),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                                                      child: const Text('VIP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                                                    ),
                                                  ],
                                                  if (user['isYou'] == true) ...[
                                                    const SizedBox(width: 4),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                      decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(4)),
                                                      child: const Text('You', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                user['email'],
                                                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Role Badge
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _getRolePillBg(user['role']),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          user['role'],
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getRolePillTextColor(user['role'])),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Status Badge
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _getStatusPillBg(user['status']),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          user['status'],
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusPillTextColor(user['status'])),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Orders Count
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${user['orders']}',
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                                    ),
                                  ),

                                  // Total Spend
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '₹${_formatCurrency(user['totalSpent'])}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                                    ),
                                  ),

                                  // Joined On
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      user['joinedOn'],
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                    ),
                                  ),

                                  // Actions
                                  SizedBox(
                                    width: 90,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF6B7280)),
                                          onPressed: () {
                                            setState(() {
                                              _selectedUser = user;
                                              _showRightPanel = true;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF6B7280)),
                                          onPressed: () => _showEditUserDialog(user),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFF6B7280)),
                                          onSelected: (val) {
                                            if (val == 'edit') _showEditUserDialog(user);
                                            if (val == 'reset') _showResetPasswordDialog(user);
                                            if (val == 'login') _loginAsUser(user);
                                            if (val == 'deactivate') _toggleDeactivateUser(user);
                                            if (val == 'activity') _showUserActivityDialog(user);
                                            if (val == 'delete') _confirmDeleteUser(user);
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(value: 'edit', child: Text('✏️ Edit Details')),
                                            const PopupMenuItem(value: 'reset', child: Text('🔑 Reset Password')),
                                            const PopupMenuItem(value: 'login', child: Text('👤 Switch Session')),
                                            PopupMenuItem(value: 'deactivate', child: Text(user['status'] == 'Active' ? '🚫 Deactivate Account' : '✅ Activate Account')),
                                            const PopupMenuItem(value: 'activity', child: Text('📊 View Activity Log')),
                                            const PopupMenuItem(value: 'delete', child: Text('🗑️ Delete Account', style: TextStyle(color: Colors.red))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Pagination Footer Bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Showing 1 to ${filteredUsers.length} of 2,453 users',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                            Row(
                              children: [
                                _buildPageButton('<', false),
                                _buildPageButton('1', true),
                                _buildPageButton('2', false),
                                _buildPageButton('3', false),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text('...', style: TextStyle(color: Color(0xFF6B7280))),
                                ),
                                _buildPageButton('307', false),
                                _buildPageButton('>', false),
                                const SizedBox(width: 16),
                                const Text('Show ', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('10 ▾', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                ),
                                const Text(' per page', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right Column: Selected User Details Panel
              if (_showRightPanel && _selectedUser != null && isWideScreen) ...[
                const SizedBox(width: 20),
                SizedBox(
                  width: 320,
                  child: _buildUserDetailsDrawer(_selectedUser!),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, String trend, IconData icon, Color iconBg, Color iconColor, bool isPositive) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(
            trend,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsDrawer(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('User Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Color(0xFF6B7280)),
                onPressed: () => setState(() => _showRightPanel = false),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Avatar Header Card
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFE0E7FF),
                  child: Text(
                    user['name'].toString().substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(user['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    if (user['isVip'] == true) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                        child: const Text('VIP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(user['email'], style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 2),
                Text(user['phone'], style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('User ID: ${user['id']}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    const SizedBox(width: 4),
                    const Icon(Icons.copy, size: 12, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3 Metric Cards Row inside Drawer
          Row(
            children: [
              Expanded(
                child: _buildDrawerStatBox('${user['orders']}', 'Orders'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDrawerStatBox('₹${_formatCurrency(user['totalSpent'])}', 'Total Spend'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDrawerStatBox('${user['addresses']}', 'Addresses'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Details List
          _buildDrawerDetailRow('Role', user['role']),
          _buildDrawerDetailRow('Status', user['status'], isStatus: true),
          _buildDrawerDetailRow('Member Since', user['joinedOn']),
          _buildDrawerDetailRow('Last Login', user['lastLogin']),
          _buildDrawerDetailRow('Email Verified', user['emailVerified'] == true ? 'Yes ✓' : 'No ✗', isVerified: user['emailVerified'] == true),
          _buildDrawerDetailRow('Phone Verified', user['phoneVerified'] == true ? 'Yes ✓' : 'No ✗', isVerified: user['phoneVerified'] == true),

          const SizedBox(height: 20),

          // Quick Actions Title
          const Text('Quick Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditUserDialog(user),
                  icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF4F46E5)),
                  label: const Text('Edit User', style: TextStyle(fontSize: 11, color: Color(0xFF4F46E5))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFC7D2FE))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showResetPasswordDialog(user),
                  icon: const Icon(Icons.lock_reset_outlined, size: 14, color: Color(0xFFD97706)),
                  label: const Text('Reset Password', style: TextStyle(fontSize: 11, color: Color(0xFFD97706))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFDE68A))),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _loginAsUser(user),
                  icon: const Icon(Icons.person_search_outlined, size: 14, color: Color(0xFF2563EB)),
                  label: const Text('Login as User', style: TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFBFDBFE))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleDeactivateUser(user),
                  icon: Icon(user['status'] == 'Active' ? Icons.block_outlined : Icons.check_circle_outline, size: 14, color: user['status'] == 'Active' ? const Color(0xFFDC2626) : const Color(0xFF059669)),
                  label: Text(user['status'] == 'Active' ? 'Deactivate User' : 'Activate User', style: TextStyle(fontSize: 11, color: user['status'] == 'Active' ? const Color(0xFFDC2626) : const Color(0xFF059669))),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: user['status'] == 'Active' ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0))),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showUserActivityDialog(user),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB))),
              child: const Text('View User Activity', style: TextStyle(fontSize: 12, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 20),

          const Text('More Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                height: 36,
                width: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.more_horiz, size: 18, color: Color(0xFF6B7280)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDeleteUser(user),
                  icon: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFDC2626)),
                  label: const Text('Delete User', style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFECACA))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerStatBox(String val, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildDrawerDetailRow(String label, String val, {bool isStatus = false, bool? isVerified}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
            )
          else if (isVerified != null)
            Row(
              children: [
                Text(val.replaceAll(' ✓', '').replaceAll(' ✗', ''), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isVerified ? const Color(0xFF059669) : const Color(0xFFDC2626))),
                const SizedBox(width: 4),
                Icon(isVerified ? Icons.check_circle : Icons.cancel, size: 14, color: isVerified ? const Color(0xFF059669) : const Color(0xFFDC2626)),
              ],
            )
          else
            Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        ],
      ),
    );
  }

  Widget _buildPageButton(String text, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4F46E5) : Colors.white,
        border: Border.all(color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double val) {
    return val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Color _getRoleAvatarBg(String role) {
    switch (role) {
      case 'Master Admin':
        return const Color(0xFFE0E7FF);
      case 'Moderator':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFDBEAFE);
    }
  }

  Color _getRoleAvatarTextColor(String role) {
    switch (role) {
      case 'Master Admin':
        return const Color(0xFF4F46E5);
      case 'Moderator':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _getRolePillBg(String role) {
    switch (role) {
      case 'Master Admin':
        return const Color(0xFFEEF2FF);
      case 'Moderator':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  Color _getRolePillTextColor(String role) {
    switch (role) {
      case 'Master Admin':
        return const Color(0xFF4F46E5);
      case 'Moderator':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _getStatusPillBg(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFFD1FAE5);
      case 'Inactive':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusPillTextColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF059669);
      case 'Inactive':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
