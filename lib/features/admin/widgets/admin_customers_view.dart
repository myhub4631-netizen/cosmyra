import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/supabase_config.dart';
import '../../../config/theme/app_colors.dart';

class AdminCustomersView extends ConsumerStatefulWidget {
  const AdminCustomersView({super.key});

  @override
  ConsumerState<AdminCustomersView> createState() => _AdminCustomersViewState();
}

class _AdminCustomersViewState extends ConsumerState<AdminCustomersView> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _registeredProfiles = [];
  bool _isLoadingProfiles = true;

  final List<Map<String, dynamic>> _defaultCustomers = [
    {
      'id': 'CUST-100',
      'name': 'Mahboob Hasan',
      'email': '1mdollar2027@gmail.com',
      'phone': '+91 94730 40903',
      'role': 'Master Admin',
      'isVip': true,
      'totalOrders': 18,
      'totalSpent': 15450.0,
      'activeSubscriptions': 2,
      'city': 'New Delhi, DL',
      'joinedDate': '2026-08-15',
    },
    {
      'id': 'CUST-101',
      'name': 'Priya Verma',
      'email': 'priya.verma@example.com',
      'phone': '+91 98765 43210',
      'role': 'Customer',
      'isVip': true,
      'totalOrders': 5,
      'totalSpent': 2890.0,
      'activeSubscriptions': 1,
      'city': 'Mumbai, MH',
      'joinedDate': '2026-03-12',
    },
    {
      'id': 'CUST-102',
      'name': 'Ananya Roy',
      'email': 'ananya.roy@gmail.com',
      'phone': '+91 98123 45678',
      'role': 'Customer',
      'isVip': false,
      'totalOrders': 3,
      'totalSpent': 1480.0,
      'activeSubscriptions': 1,
      'city': 'Bengaluru, KA',
      'joinedDate': '2026-04-05',
    },
    {
      'id': 'CUST-103',
      'name': 'Rahul Sharma',
      'email': 'rahul.s@outlook.com',
      'phone': '+91 97654 32109',
      'role': 'Customer',
      'isVip': true,
      'totalOrders': 8,
      'totalSpent': 4950.0,
      'activeSubscriptions': 1,
      'city': 'Delhi, NCR',
      'joinedDate': '2026-01-20',
    },
    {
      'id': 'CUST-104',
      'name': 'Dr. Rajesh Vaidya',
      'email': 'admin@cosmyra.com',
      'phone': '+91 99000 11223',
      'role': 'Master Admin',
      'isVip': true,
      'totalOrders': 12,
      'totalSpent': 8900.0,
      'activeSubscriptions': 0,
      'city': 'Pune, MH',
      'joinedDate': '2026-01-01',
    },
  ];

  @override
  void initState() {
    super.initState();
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
        for (final row in data) {
          final email = row['email'] ?? '';
          final name = row['full_name'] ?? (email.contains('@') ? email.split('@').first : 'User');
          final role = (email.toLowerCase() == '1mdollar2027@gmail.com')
              ? 'Master Admin'
              : (row['role']?.toString().toUpperCase() ?? 'CUSTOMER');
          fetched.add({
            'id': 'SUPA-${row['id']?.toString().substring(0, 5) ?? '00'}',
            'name': name,
            'email': email,
            'phone': row['phone'] ?? '+91 94730 40903',
            'role': role,
            'isVip': role == 'Master Admin',
            'totalOrders': row['total_orders'] ?? 1,
            'totalSpent': (row['total_spent'] ?? 999.0).toDouble(),
            'activeSubscriptions': 0,
            'city': row['city'] ?? 'India',
            'joinedDate': row['created_at']?.toString().substring(0, 10) ?? '2026-08-15',
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final combinedCustomers = [
      ..._registeredProfiles,
      ..._defaultCustomers.where((def) => !_registeredProfiles.any((reg) => reg['email']?.toString().toLowerCase() == def['email']?.toString().toLowerCase())),
    ];

    final filteredCustomers = combinedCustomers.where((c) {
      if (_searchQuery.isNotEmpty) {
        final nameMatch = c['name'].toString().toLowerCase().contains(_searchQuery);
        final emailMatch = c['email'].toString().toLowerCase().contains(_searchQuery);
        final phoneMatch = c['phone'].toString().toLowerCase().contains(_searchQuery);
        return nameMatch || emailMatch || phoneMatch;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer CRM & User Roles',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customer directory, lifetime spend metrics, subscription history & permissions.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search Bar
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by Customer Name, Email, or Phone...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Customers List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredCustomers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cust = filteredCustomers[index];
              final isVip = cust['isVip'] == true;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.forestSage.withValues(alpha: 0.15),
                        child: Text(
                          cust['name'].toString().substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.forestSage, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  cust['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(width: 8),
                                if (isVip)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.goldAccent.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('VIP CLUB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.goldAccent)),
                                  ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.forestSage.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(cust['role'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.forestSage)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${cust['email']} • ${cust['phone']} • Location: ${cust['city']}',
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total Orders: ${cust['totalOrders']} • Active Subscriptions: ${cust['activeSubscriptions']} • Joined: ${cust['joinedDate']}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Lifetime Spend',
                            style: TextStyle(fontSize: 11, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                          ),
                          Text(
                            '₹${cust['totalSpent'].toInt()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? AppColors.goldAccent : AppColors.forestSageDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
