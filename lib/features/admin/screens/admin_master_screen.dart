import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/controllers/auth_controller.dart';
import '../widgets/admin_analytics_view.dart';
import '../widgets/admin_auth_dialog.dart';
import '../widgets/admin_catalog_view.dart';
import '../widgets/admin_customers_view.dart';
import '../widgets/admin_orders_view.dart';
import '../widgets/admin_promotions_view.dart';
import '../widgets/admin_settings_view.dart';
import '../widgets/admin_subscriptions_view.dart';

class AdminMasterScreen extends ConsumerStatefulWidget {
  const AdminMasterScreen({super.key});

  @override
  ConsumerState<AdminMasterScreen> createState() => _AdminMasterScreenState();
}

class _AdminMasterScreenState extends ConsumerState<AdminMasterScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navigationItems = [
    {'title': 'Dashboard', 'icon': Icons.grid_view_rounded, 'hasChild': false, 'viewIndex': 0},
    {'title': 'Users', 'icon': Icons.people_outline, 'hasChild': true, 'viewIndex': 4},
    {'title': 'Products', 'icon': Icons.inventory_2_outlined, 'hasChild': true, 'viewIndex': 1},
    {'title': 'Orders', 'icon': Icons.shopping_bag_outlined, 'hasChild': true, 'viewIndex': 2},
    {'title': 'Categories', 'icon': Icons.category_outlined, 'hasChild': false, 'viewIndex': 1},
    {'title': 'Brands', 'icon': Icons.storefront_outlined, 'hasChild': false, 'viewIndex': 1},
    {'title': 'Coupons', 'icon': Icons.local_offer_outlined, 'hasChild': true, 'viewIndex': 5},
    {'title': 'Banners', 'icon': Icons.image_outlined, 'hasChild': true, 'viewIndex': 5},
    {'title': 'Reviews', 'icon': Icons.star_outline, 'hasChild': true, 'viewIndex': 4},
    {'title': 'Withdrawals', 'icon': Icons.account_balance_wallet_outlined, 'hasChild': false, 'viewIndex': 3},
    {'title': 'Reports', 'icon': Icons.bar_chart_outlined, 'hasChild': false, 'viewIndex': 0},
    {'title': 'Settings', 'icon': Icons.settings_outlined, 'hasChild': false, 'viewIndex': 6},
    {'title': 'System Logs', 'icon': Icons.list_alt_outlined, 'hasChild': false, 'viewIndex': 6},
  ];

  final List<Widget> _views = const [
    AdminAnalyticsView(),
    AdminCatalogView(),
    AdminOrdersView(),
    AdminSubscriptionsView(),
    AdminCustomersView(),
    AdminPromotionsView(),
    AdminSettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SafeArea(
            child: Row(
              children: [
                if (!isWide)
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFF111827)),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),

                const Text(
                  'Master Admin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),

                const Spacer(),

                // Search Bar Input
                Container(
                  width: 320,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search anything...',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Language Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Text('English ', style: TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500)),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF6B7280)),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Notifications Bell with Badge
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF374151), size: 22),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('5', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // Admin Profile Chip
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AdminAuthDialog(),
                    );
                  },
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF6366F1),
                        child: Icon(Icons.person, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Builder(
                        builder: (context) {
                          final currentUser = ref.watch(currentUserProvider);
                          final email = currentUser?.email ?? '1mdollar2027@gmail.com';
                          final name = currentUser?.userMetadata?['full_name'] ??
                              (email == '1mdollar2027@gmail.com' ? 'Mahboob Hasan' : email.split('@').first);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                              Text(email, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.store, size: 16, color: Color(0xFF4F46E5)),
                  label: const Text('Storefront', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                ),
              ],
            ),
          ),
        ),
      ),

      drawer: !isWide ? Drawer(child: _buildSidebar(isDrawer: true)) : null,

      body: Row(
        children: [
          if (isWide)
            SizedBox(
              width: 240,
              child: _buildSidebar(isDrawer: false),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: _views[_navigationItems[_selectedIndex]['viewIndex'] as int],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({required bool isDrawer}) {
    return Container(
      color: const Color(0xFF0B132B), // Dark Navy Blue background matching screenshot
      child: Column(
        children: [
          // Sidebar Brand Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Commerce Admin',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Menu Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                final item = _navigationItems[index];
                final isSelected = _selectedIndex == index;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          leading: Icon(
                            item['icon'] as IconData,
                            size: 18,
                            color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                          ),
                          title: Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFFD1D5DB),
                            ),
                          ),
                          trailing: item['hasChild'] == true
                              ? Icon(
                                  isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                                )
                              : null,
                          onTap: () {
                            setState(() => _selectedIndex = index);
                            if (isDrawer) Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),

                    // Expanded Sub-menu for Users
                    if (item['title'] == 'Users' && isSelected) ...[
                      _buildSubMenuItem('All Users', true),
                      _buildSubMenuItem('User Roles', false),
                      _buildSubMenuItem('Permissions', false),
                      const SizedBox(height: 4),
                    ],
                  ],
                );
              },
            ),
          ),

          // Bottom Contact Support Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 20, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Need Help?', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Contact Support', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem(String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(left: 36, bottom: 2, right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
