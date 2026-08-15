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

class AdminMasterScreen extends ConsumerStatefulWidget {
  const AdminMasterScreen({super.key});

  @override
  ConsumerState<AdminMasterScreen> createState() => _AdminMasterScreenState();
}

class _AdminMasterScreenState extends ConsumerState<AdminMasterScreen> {
  int _activeViewIndex = 0; // 0: Dashboard, 1: Catalog, 2: Orders, 3: Customers, 4: Analytics, 5: Marketing, 6: Settings, 7: Homepage CMS, 8: Footer CMS

  // Expanded parent menus
  final Set<String> _expandedParentMenus = {'Catalog', 'Orders', 'Website'};

  final List<Map<String, dynamic>> _navigationItems = [
    {'title': 'Dashboard', 'icon': Icons.grid_view_outlined, 'viewIndex': 0, 'hasChild': false},
    {'title': 'Catalog', 'icon': Icons.inventory_2_outlined, 'viewIndex': 1, 'hasChild': true},
    {'title': 'Orders', 'icon': Icons.shopping_bag_outlined, 'viewIndex': 2, 'hasChild': true},
    {'title': 'Customers', 'icon': Icons.people_outline, 'viewIndex': 3, 'hasChild': false},
    {'title': 'Website', 'icon': Icons.web_outlined, 'viewIndex': 7, 'hasChild': true},
    {'title': 'Analytics', 'icon': Icons.bar_chart_outlined, 'viewIndex': 4, 'hasChild': false},
    {'title': 'Marketing', 'icon': Icons.campaign_outlined, 'viewIndex': 5, 'hasChild': false},
    {'title': 'Settings', 'icon': Icons.settings_outlined, 'viewIndex': 6, 'hasChild': false},
  ];

  final List<Widget> _views = const [
    AdminDashboardScreen(),
    AdminCatalogView(),
    AdminOrdersView(),
    AdminCustomersView(),
    Center(child: Text('Analytics View (Coming Soon)', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)))),
    Center(child: Text('Marketing & Discounts View (Coming Soon)', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)))),
    Center(child: Text('Store Settings View (Coming Soon)', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)))),
    AdminHomepageCmsView(),
    AdminFooterCmsView(),
  ];

  Future<void> _handleAdminLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Admin Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text('Are you sure you want to log out from the Master Admin Console?'),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (!isWide)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFF374151)),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),

              // Search Bar in Top Bar
              if (isWide)
                Container(
                  width: 320,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products, orders, settings...',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),

              const Spacer(),

              // Right Top Controls: Notifications, User Profile Menu, Storefront & Dedicated Logout Button
              Row(
                children: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Color(0xFF4B5563)),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                          child: const Text('5', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // Admin Profile Dropdown Popup Menu
                  PopupMenuButton<String>(
                    tooltip: 'Admin Account Options',
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await _handleAdminLogout(context);
                      } else if (value == 'storefront') {
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
                            Text(adminName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                            Text(adminEmail, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
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
                            Text('View Live Storefront', style: TextStyle(fontSize: 12)),
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
                            style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isWide)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(adminName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                              const Text('Master Admin ▾', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Storefront Link Button
                  TextButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF4F46E5)),
                    label: const Text('Storefront', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),

                  const SizedBox(width: 10),

                  // Dedicated Logout Admin Button
                  ElevatedButton.icon(
                    onPressed: () => _handleAdminLogout(context),
                    icon: const Icon(Icons.logout, size: 14),
                    label: const Text('Logout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            child: _views[_activeViewIndex >= 0 && _activeViewIndex < _views.length ? _activeViewIndex : 0],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({bool isDrawer = false}) {
    return Container(
      color: const Color(0xFF111827), // Sleek Dark Charcoal Sidebar
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
                  'Cosmyra Admin',
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
                final String title = item['title'] as String;
                final int defaultViewIndex = item['viewIndex'] as int;

                final bool isExpanded = _expandedParentMenus.contains(title);
                final bool isParentActive = _activeViewIndex == defaultViewIndex ||
                    (title == 'Website' && (_activeViewIndex == 7 || _activeViewIndex == 8));

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isParentActive ? const Color(0xFF4F46E5) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          leading: Icon(
                            item['icon'] as IconData,
                            size: 18,
                            color: isParentActive ? Colors.white : const Color(0xFF9CA3AF),
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isParentActive ? FontWeight.bold : FontWeight.w500,
                              color: isParentActive ? Colors.white : const Color(0xFFD1D5DB),
                            ),
                          ),
                          trailing: item['hasChild'] == true
                              ? Icon(
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: isParentActive ? Colors.white : const Color(0xFF9CA3AF),
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              if (item['hasChild'] == true) {
                                if (isExpanded) {
                                  _expandedParentMenus.remove(title);
                                } else {
                                  _expandedParentMenus.add(title);
                                }
                              }
                              _activeViewIndex = defaultViewIndex;
                            });
                            if (isDrawer) Navigator.pop(context);
                          },
                        ),
                      ),
                    ),

                    // Expanded Sub-menu for Catalog
                    if (title == 'Catalog' && isExpanded) ...[
                      _buildSubMenuItem('All Products', _activeViewIndex == 1, onTap: () => setState(() => _activeViewIndex = 1)),
                      _buildSubMenuItem('Categories', false),
                      _buildSubMenuItem('Collections', false),
                      _buildSubMenuItem('Inventory', false),
                      _buildSubMenuItem('Gift Cards', false),
                      const SizedBox(height: 4),
                    ],

                    // Expanded Sub-menu for Orders
                    if (title == 'Orders' && isExpanded) ...[
                      _buildSubMenuItem('All Orders', _activeViewIndex == 2, onTap: () => setState(() => _activeViewIndex = 2)),
                      _buildSubMenuItem('Unfulfilled', false),
                      _buildSubMenuItem('Processing', false),
                      _buildSubMenuItem('Shipped', false),
                      _buildSubMenuItem('Delivered', false),
                      _buildSubMenuItem('Cancelled', false),
                      _buildSubMenuItem('Returned / Refunds', false),
                      const SizedBox(height: 4),
                    ],

                    // Expanded Sub-menu for Website
                    if (title == 'Website' && isExpanded) ...[
                      _buildSubMenuItem('Homepage', _activeViewIndex == 7, onTap: () => setState(() => _activeViewIndex = 7)),
                      _buildSubMenuItem('Pages', false),
                      _buildSubMenuItem('Navigation', false),
                      _buildSubMenuItem('Blog', false),
                      _buildSubMenuItem('Popup Manager', false),
                      _buildSubMenuItem('Footer Manager', _activeViewIndex == 8, onTap: () => setState(() => _activeViewIndex = 8)),
                      const SizedBox(height: 4),
                    ],
                  ],
                );
              },
            ),
          ),

          // Bottom Logout & Support Bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => _handleAdminLogout(context),
                  child: Row(
                    children: const [
                      Icon(Icons.logout, size: 18, color: Color(0xFFEF4444)),
                      SizedBox(width: 10),
                      Text('Logout Admin', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildSubMenuItem(String title, bool isActive, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
