import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/controllers/auth_controller.dart';
import '../widgets/admin_catalog_view.dart';
import '../widgets/admin_customers_view.dart';
import '../widgets/admin_footer_cms_view.dart';
import '../widgets/admin_homepage_cms_view.dart';
import '../widgets/admin_orders_view.dart';
import 'admin_dashboard_screen.dart';

import '../widgets/admin_branding_view.dart';
import '../widgets/admin_coupons_view.dart';

class AdminMasterScreen extends ConsumerStatefulWidget {
  const AdminMasterScreen({super.key});

  @override
  ConsumerState<AdminMasterScreen> createState() => _AdminMasterScreenState();
}

class _AdminMasterScreenState extends ConsumerState<AdminMasterScreen> {
  int _activeViewIndex = 0; // 0: Dashboard, 1: Catalog, 2: Orders, 3: Customers, 4: Marketing, 5: Analytics, 6: Reports, 7: Website (Homepage), 8: Website (Footer), 9: Logo & Branding

  // Expanded parent menus
  final Set<String> _expandedParentMenus = {'Catalog', 'Orders', 'Website'};

  Future<void> _handleAdminLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Admin Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text('Are you sure you want to log out from the Cosmyra Admin Console?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin logged out successfully.')),
                );
                context.go('/login');
              }
            },
            child: const Text('Logout Admin'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final auth = ref.watch(authControllerProvider);

    final String adminName = auth.userName ?? user?.userMetadata?['full_name'] ?? 'Mahboob Hasan';
    final String adminEmail = auth.userEmail ?? user?.email ?? '1mdollar2027@gmail.com';

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    final List<Widget> views = [
      const AdminDashboardScreen(),
      const AdminCatalogView(),
      const AdminOrdersView(),
      const AdminCustomersView(),
      const AdminCouponsView(),
      const Center(child: Text('Analytics View (Coming Soon)', style: TextStyle(fontSize: 16, color: Color(0xFF64748B)))),
      const Center(child: Text('Reports View (Coming Soon)', style: TextStyle(fontSize: 16, color: Color(0xFF64748B)))),
      const AdminHomepageCmsView(),
      const AdminFooterCmsView(),
      const AdminBrandingView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // ── TOP HEADER BAR ──
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (!isWide)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFF334155)),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),

              // Left Brand Title Header (Console Switcher)
              Row(
                children: [
                  const Icon(Icons.storefront, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'COSMYRA ADMIN CONSOLE',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 24),

              // Search Bar in Center Header
              if (isWide)
                Container(
                  width: 380,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.search, size: 16, color: Color(0xFF94A3B8)),
                      ),
                      const Expanded(
                        child: TextField(
                          style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            hintText: 'Search orders, customers, products, SKUs...',
                            hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('⌘K', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Right Actions Group: Notifications, Help, Profile Avatar & Storefront Link
              Row(
                children: [
                  // Bell Notification Icon
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Color(0xFF475569), size: 22),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                          child: const Text('12', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),

                  // Help Support Icon
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: Color(0xFF475569), size: 22),
                    onPressed: () {},
                  ),

                  const SizedBox(width: 8),

                  // User Profile Avatar Menu
                  PopupMenuButton<String>(
                    tooltip: 'Account Options',
                    onSelected: (val) async {
                      if (val == 'logout') {
                        await _handleAdminLogout(context);
                      } else if (val == 'storefront') {
                        context.go('/');
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(adminName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                            Text(adminEmail, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(4)),
                              child: const Text('MASTER ADMIN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'storefront',
                        child: Row(
                          children: [
                            Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF4F46E5)),
                            SizedBox(width: 8),
                            Text('Shopper Storefront', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Logout Admin', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFEEF2FF),
                          child: Text(
                            adminName.isNotEmpty ? adminName[0].toUpperCase() : 'M',
                            style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isWide)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(adminName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const Text('Master Admin ▾', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Shopper Storefront Button Link
                  InkWell(
                    onTap: () => context.go('/'),
                    child: Row(
                      children: const [
                        Text('Shopper Storefront', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                        SizedBox(width: 4),
                        Icon(Icons.open_in_new, size: 14, color: Color(0xFF4F46E5)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: !isWide ? Drawer(child: _buildSidebar(isDrawer: true)) : null,
      body: Row(
        children: [
          if (isWide)
            SizedBox(
              width: 240,
              child: _buildSidebar(),
            ),
          Expanded(
            child: views[_activeViewIndex >= 0 && _activeViewIndex < views.length ? _activeViewIndex : 0],
          ),
        ],
      ),
    );
  }

  // ── LEFT SIDEBAR NAVIGATION ──
  Widget _buildSidebar({bool isDrawer = false}) {
    return Container(
      color: const Color(0xFF0F172A), // Dark Midnight Blue
      child: Column(
        children: [
          // Brand Title Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_florist, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cosmyra Admin',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.menu, color: Color(0xFF64748B), size: 18),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Menu List Groups
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _groupHeader('MAIN'),
                _navItem('Dashboard', Icons.grid_view_outlined, 0, badgeCount: 0),
                _navItem('Catalog', Icons.inventory_2_outlined, 1, hasChildren: true),
                if (_expandedParentMenus.contains('Catalog')) ...[
                  _subNavItem('All Products', 1, () => setState(() => _activeViewIndex = 1)),
                  _subNavItem('Categories', -1, null),
                  _subNavItem('Collections', -1, null),
                ],
                _navItem('Orders', Icons.shopping_bag_outlined, 2, badgeCount: 24, hasChildren: true),
                if (_expandedParentMenus.contains('Orders')) ...[
                  _subNavItem('All Orders', 2, () => setState(() => _activeViewIndex = 2)),
                  _subNavItem('Unfulfilled', -1, null),
                  _subNavItem('Shipped', -1, null),
                  _subNavItem('Delivered', -1, null),
                ],
                _navItem('Customers', Icons.people_outline, 3),
                _navItem('Marketing', Icons.campaign_outlined, 4),
                _navItem('Analytics', Icons.bar_chart_outlined, 5),
                _navItem('Reports', Icons.assessment_outlined, 6),

                const SizedBox(height: 16),
                _groupHeader('SALES CHANNELS'),
                _navItem('Website', Icons.web_outlined, 7, hasChildren: true),
                if (_expandedParentMenus.contains('Website')) ...[
                  _subNavItem('Homepage', 7, () => setState(() => _activeViewIndex = 7)),
                  _subNavItem('Footer Manager', 8, () => setState(() => _activeViewIndex = 8)),
                  _subNavItem('Logo & Brand Assets 🎨', 9, () => setState(() => _activeViewIndex = 9)),
                ],

                const SizedBox(height: 16),
                _groupHeader('TOOLS'),
                _navItem('Inventory', Icons.inventory_outlined, -1),
                _navItem('Fulfillment', Icons.local_shipping_outlined, -1),
                _navItem('Shipping', Icons.directions_boat_outlined, -1),
                _navItem('Payments', Icons.payment_outlined, -1),
                _navItem('Returns', Icons.published_with_changes, -1),

                const SizedBox(height: 16),
                _groupHeader('SETTINGS'),
                _navItem('Brand & Logo 🎨', Icons.palette_outlined, 9),
                _navItem('Settings', Icons.settings_outlined, -1),
                _navItem('System Logs', Icons.article_outlined, -1),
              ],
            ),
          ),

          // Bottom Logout Button (Red Outline Container)
          Container(
            margin: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => _handleAdminLogout(context),
              icon: const Icon(Icons.logout, size: 16, color: Color(0xFFEF4444)),
              label: const Text(
                'Logout Admin',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.8),
      ),
    );
  }

  Widget _navItem(
    String title,
    IconData icon,
    int index, {
    int badgeCount = 0,
    bool hasChildren = false,
  }) {
    final bool isActive = _activeViewIndex == index;
    final bool isExpanded = _expandedParentMenus.contains(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(icon, size: 18, color: isActive ? Colors.white : const Color(0xFF94A3B8)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFFCBD5E1),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            if (hasChildren) ...[
              const SizedBox(width: 6),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
            ],
          ],
        ),
        onTap: () {
          setState(() {
            if (hasChildren) {
              if (isExpanded) {
                _expandedParentMenus.remove(title);
              } else {
                _expandedParentMenus.add(title);
              }
            }
            if (index >= 0) {
              _activeViewIndex = index;
            }
          });
        },
      ),
    );
  }

  Widget _subNavItem(String title, int targetIndex, VoidCallback? onTap) {
    final bool isActive = _activeViewIndex == targetIndex;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 36, bottom: 2, right: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }
}
