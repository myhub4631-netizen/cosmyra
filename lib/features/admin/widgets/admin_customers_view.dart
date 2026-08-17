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

  final List<Map<String, dynamic>> _defaultUsers = [
    {
      'id': '#USR-0002453',
      'name': 'Mahboob Hasan',
      'email': '1mdollar2027@gmail.com',
      'phone': '+91 98765 43210',
      'role': 'Master Admin',
      'status': 'Active',
      'isVip': true,
      'isYou': true,
      'orders': 18,
      'totalSpent': 15450.0,
      'joinedOn': '15 Aug 2026 10:30 AM',
      'lastLogin': '15 Aug 2026, 06:15 PM',
      'emailVerified': true,
      'phoneVerified': true,
      'addresses': 2,
    },
    {
      'id': '#USR-0002454',
      'name': 'Priya Verma',
      'email': 'priya.verma@example.com',
      'phone': '+91 98765 43210',
      'role': 'Customer',
      'status': 'Active',
      'isVip': true,
      'isYou': false,
      'orders': 5,
      'totalSpent': 2890.0,
      'joinedOn': '12 Mar 2026 04:15 PM',
      'lastLogin': '14 Aug 2026, 11:20 AM',
      'emailVerified': true,
      'phoneVerified': true,
      'addresses': 1,
    },
    {
      'id': '#USR-0002455',
      'name': 'Ananya Roy',
      'email': 'ananya.roy@gmail.com',
      'phone': '+91 98123 45678',
      'role': 'Customer',
      'status': 'Active',
      'isVip': false,
      'isYou': false,
      'orders': 3,
      'totalSpent': 1480.0,
      'joinedOn': '05 Apr 2026 11:20 AM',
      'lastLogin': '10 Aug 2026, 02:45 PM',
      'emailVerified': true,
      'phoneVerified': true,
      'addresses': 1,
    },
    {
      'id': '#USR-0002456',
      'name': 'Rahul Sharma',
      'email': 'rahul.s@outlook.com',
      'phone': '+91 97654 32109',
      'role': 'Customer',
      'status': 'Active',
      'isVip': true,
      'isYou': false,
      'orders': 8,
      'totalSpent': 4950.0,
      'joinedOn': '20 Jan 2026 09:45 AM',
      'lastLogin': '12 Aug 2026, 09:10 AM',
      'emailVerified': true,
      'phoneVerified': false,
      'addresses': 3,
    },
    {
      'id': '#USR-0002457',
      'name': 'Dr. Rajesh Vaidya',
      'email': 'admin@cosmyra.com',
      'phone': '+91 99000 11223',
      'role': 'Master Admin',
      'status': 'Active',
      'isVip': false,
      'isYou': false,
      'orders': 12,
      'totalSpent': 8900.0,
      'joinedOn': '01 Jan 2026 08:00 AM',
      'lastLogin': '15 Aug 2026, 08:00 AM',
      'emailVerified': true,
      'phoneVerified': true,
      'addresses': 1,
    },
    {
      'id': '#USR-0002458',
      'name': 'Neha Kapoor',
      'email': 'neha.kapoor@example.com',
      'phone': '+91 98989 12345',
      'role': 'Customer',
      'status': 'Inactive',
      'isVip': false,
      'isYou': false,
      'orders': 1,
      'totalSpent': 450.0,
      'joinedOn': '28 Feb 2026 02:30 PM',
      'lastLogin': '01 Mar 2026, 10:00 AM',
      'emailVerified': false,
      'phoneVerified': false,
      'addresses': 1,
    },
    {
      'id': '#USR-0002459',
      'name': 'Aman Singh',
      'email': 'aman.singh@example.com',
      'phone': '+91 97111 22334',
      'role': 'Moderator',
      'status': 'Active',
      'isVip': false,
      'isYou': false,
      'orders': 7,
      'totalSpent': 3250.0,
      'joinedOn': '18 May 2026 06:10 PM',
      'lastLogin': '14 Aug 2026, 04:30 PM',
      'emailVerified': true,
      'phoneVerified': true,
      'addresses': 2,
    },
    {
      'id': '#USR-0002460',
      'name': 'Saurabh Mehta',
      'email': 'saurabh.mehta@example.com',
      'phone': '+91 96543 87654',
      'role': 'Customer',
      'status': 'Blocked',
      'isVip': false,
      'isYou': false,
      'orders': 0,
      'totalSpent': 0.0,
      'joinedOn': '10 Dec 2025 01:00 PM',
      'lastLogin': '10 Dec 2025, 01:05 PM',
      'emailVerified': false,
      'phoneVerified': false,
      'addresses': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedUser = _defaultUsers[0];
    _fetchSupabaseProfiles();
  }

  Future<void> _fetchSupabaseProfiles() async {
    if (!SupabaseConfig.isConfigured) {
      setState(() => _isLoadingProfiles = false);
      return;
    }
    try {
      final data = await supabase.from('profiles').select('*');
      if (mounted && data is List && data.isNotEmpty) {
        final List<Map<String, dynamic>> fetched = [];
        for (int i = 0; i < data.length; i++) {
          final row = data[i];
          final email = row['email'] ?? '';
          final name = row['full_name'] ?? (email.contains('@') ? email.split('@').first : 'User');
          final isMaster = email.toLowerCase() == '1mdollar2027@gmail.com';
          final role = isMaster ? 'Master Admin' : (row['role']?.toString().toUpperCase() ?? 'Customer');
          fetched.add({
            'id': '#USR-${1000 + i}',
            'name': name,
            'email': email,
            'phone': row['phone'] ?? '+91 98765 43210',
            'role': role,
            'status': 'Active',
            'isVip': isMaster || (row['is_vip'] == true),
            'isYou': isMaster,
            'orders': row['total_orders'] ?? (isMaster ? 18 : 1),
            'totalSpent': (row['total_spent'] ?? (isMaster ? 15450.0 : 999.0)).toDouble(),
            'joinedOn': row['created_at']?.toString().substring(0, 10) ?? '15 Aug 2026',
            'lastLogin': '15 Aug 2026, 06:15 PM',
            'emailVerified': true,
            'phoneVerified': true,
            'addresses': 2,
          });
        }
        setState(() {
          _registeredProfiles = fetched;
          _isLoadingProfiles = false;
        });
      } else {
        setState(() => _isLoadingProfiles = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingProfiles = false);
    }
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
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty && emailCtrl.text.trim().isNotEmpty) {
                  final newUser = {
                    'id': '#USR-000${_defaultUsers.length + 2500}',
                    'name': nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim().isEmpty ? '+91 98765 43210' : phoneCtrl.text.trim(),
                    'role': roleVal,
                    'status': 'Active',
                    'isVip': false,
                    'isYou': false,
                    'orders': 0,
                    'totalSpent': 0.0,
                    'joinedOn': '15 Aug 2026 06:30 PM',
                    'lastLogin': 'Never',
                    'emailVerified': true,
                    'phoneVerified': false,
                    'addresses': 0,
                  };
                  setState(() {
                    _defaultUsers.insert(0, newUser);
                    _selectedUser = newUser;
                    _showRightPanel = true;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User ${nameCtrl.text} added successfully!')),
                  );
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

    final combinedUsers = [
      ..._registeredProfiles,
      ..._defaultUsers.where((def) => !_registeredProfiles.any((reg) => reg['email']?.toString().toLowerCase() == def['email']?.toString().toLowerCase())),
    ];

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
                  _buildMetricCard('Total Users', '2,453', '↑ 12.5% this month', Icons.people_outline, const Color(0xFFE0E7FF), const Color(0xFF4F46E5), true),
                  _buildMetricCard('Customers', '2,120', '↑ 9.3% this month', Icons.person_outline, const Color(0xFFDBEAFE), const Color(0xFF2563EB), true),
                  _buildMetricCard('VIP Customers', '156', '↑ 15.8% this month', Icons.workspace_premium_outlined, const Color(0xFFFEF3C7), const Color(0xFFD97706), true),
                  _buildMetricCard('Admins', '24', '↑ 4.2% this month', Icons.shield_outlined, const Color(0xFFF3E8FF), const Color(0xFF9333EA), true),
                  _buildMetricCard('Inactive Users', '153', '↓ 3.1% this month', Icons.person_off_outlined, const Color(0xFFFEE2E2), const Color(0xFFDC2626), false),
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
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFF6B7280)),
                                          onPressed: () {},
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
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF4F46E5)),
                  label: const Text('Edit User', style: TextStyle(fontSize: 11, color: Color(0xFF4F46E5))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFC7D2FE))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
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
                  onPressed: () {},
                  icon: const Icon(Icons.person_search_outlined, size: 14, color: Color(0xFF2563EB)),
                  label: const Text('Login as User', style: TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFBFDBFE))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.block_outlined, size: 14, color: Color(0xFFDC2626)),
                  label: const Text('Deactivate User', style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFECACA))),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
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
                  onPressed: () {},
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
